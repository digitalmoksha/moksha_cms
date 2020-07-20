require 'spec_helper'

describe MailchimpNewsletter do
  setup_account

  let(:api_key)      { '1234-us1' }
  let(:api_host)     { 'https://us1.api.mailchimp.com' }
  let(:api_endpoint) { "#{api_host}/3.0" }
  let(:email)        { 'test@example.com' }

  subject { described_class.new }

  before do
    allow(Account.current).to receive(:preferred_nms_api_key).and_return(api_key)
    Gibbon::Request.api_endpoint = api_host
  end

  describe '#api' do
    it 'creates a new Gibbon instance' do
      expect(subject.api).to be_an_instance_of(Gibbon::Request)
    end

    it 'does not create if key is empty' do
      allow(Account.current).to receive(:preferred_nms_api_key).and_return(nil)

      expect(subject.api).to be_nil
    end
  end

  describe '#validate_list_id' do
    let(:newsletter) { build(:mailchimp_newsletter) }

    it 'must have a list id' do
      newsletter.mc_id = nil

      expect(newsletter).not_to be_valid
      expect(newsletter.errors.messages[:mc_id]).to eq ['list id must be provided']
    end

    it 'must have a valid list id' do
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}?fields=id")
        .to_return(status: 200)

      expect(newsletter).to be_valid
    end

    it 'does not have a valid list id' do
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}?fields=id")
        .to_return(status: 404, body: { title: 'Resource Not Found' }.to_json)

      expect(newsletter).not_to be_valid
      expect(newsletter.errors.messages[:mc_id]).to eq ['Resource Not Found']
    end
  end

  describe '#groupings' do
    let(:newsletter) { create(:mailchimp_newsletter, :skip_validate) }
    let(:category_response_body) do
      {
        list_id: 'abc123',
        categories: [
          { list_id: 'abc123', id: '12', title: 'Interested In', display_order: 0, type: 'checkboxes' }
        ]
      }
    end

    let(:interests_response_body) do
      {
        interests: [
          {
            category_id: '12', list_id: 'abc123', id: '123abc',
            name: 'interest one',
            subscriber_count: '1202',
            display_order: 1
          }
        ]
      }
    end

    it 'returns an array of groups / categories' do
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}/interest-categories")
        .to_return(status: 200, body: category_response_body.to_json)
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}/interest-categories/12/interests")
        .to_return(status: 200, body: interests_response_body.to_json)

      expected = {
        display_order: 0,
        groups:
        [
          {
            category_id: "12",
            display_order: 1,
            id: "123abc",
            list_id: 'abc123',
            name: 'interest one',
            subscriber_count: '1202'
          }
        ],
        id: "12",
        list_id: "abc123",
        title: "Interested In",
        type: "checkboxes"
      }

      expect(newsletter.groupings).to contain_exactly(expected)
    end

    it 'returns an empty array if an error returned' do
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}/interest-categories")
        .to_return(status: 404, body: { title: 'Resource Not Found' }.to_json)

      expect(newsletter.groupings).to eq []
    end
  end

  describe '#subscribe' do
    let(:newsletter) { create(:mailchimp_newsletter, :skip_validate) }

    it 'fails if user or email is blank' do
      expect(newsletter.subscribe('')).to include({ success: false, code: 232 })
    end

    it 'subscribes a new email address' do
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(email)}")
        .to_return(status: 404)
      stub_request(:put, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(email)}")
        .with(body: { email_address: email, language: 'en', status: 'pending', merge_fields: { 'FNAME': '', 'LNAME': '', 'SPAMAPI': 1 } })
        .to_return(status: 200)

      expect(newsletter.subscribe(email)).to include({ success: true, code: 0 })
    end

    it 'subscribes a new email address with merge fields' do
      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(email)}")
        .to_return(status: 404)
      stub_request(:put, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(email)}")
        .with(body: { email_address: email, language: 'en', status: 'pending', merge_fields: { 'FNAME': 'Bob', 'LNAME': 'Tree', 'SPAMAPI': 1 } })
        .to_return(status: 200)

      expect(newsletter.subscribe(email, { FNAME: 'Bob', LNAME: 'Tree' }, new_subscription: true)).to include({ success: true, code: 0 })
    end

    it 'subscribes a new user' do
      user = create(:user)

      stub_request(:get, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(user.email)}")
        .to_return(status: 404)
      stub_request(:put, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(user.email)}")
        .with(body: { email_address: user.email, language: 'en', status: 'pending', merge_fields: { 'FNAME': user.first_name, 'LNAME': user.last_name, 'COUNTRY': 'United States of America', 'SPAMAPI': 1 } })
        .to_return(status: 200)

      expect(newsletter.subscribe(user, new_subscription: true)).to include({ success: true, code: 0 })
    end
  end

  describe '#unsubscribe' do
    let(:newsletter) { create(:mailchimp_newsletter, :skip_validate) }

    it 'returns false if email is blank' do
      expect(newsletter.unsubscribe('')).to be_falsey
    end

    it 'unsubscribes email address' do
      stub_request(:patch, "#{api_endpoint}/lists/#{newsletter.mc_id}/members/#{hash_email(email)}")
        .with(body: { status: 'unsubscribed' })
        .to_return(status: 200)

      expect(newsletter.unsubscribe(email)).to be_truthy
    end
  end

  def hash_email(email)
    Digest::MD5.hexdigest(email.downcase)
  end
end
