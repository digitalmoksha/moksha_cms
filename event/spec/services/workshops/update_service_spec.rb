require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe DmEvent::Workshops::UpdateService, type: :service do
  setup_account

  let(:workshop) { create :workshop_with_price }

  describe '#call' do
    let!(:service) { described_class.new(workshop, {}) }

    def update_workshop(opts)
      additional = opts.delete(:additional_configuration)
      result = DmEvent::Workshops::UpdateService.new(workshop, opts, {additional_configuration: additional}).call
      workshop.reload
      return result
    end

    context 'main panel' do
      it 'updates contact email' do
        expect(update_workshop(contact_email: 'another@example.com')).to be_truthy
        expect(workshop.contact_email).to eq 'another@example.com'
      end

      it 'updates contact phone' do
        expect(update_workshop(contact_phone: '987-654-0000')).to be_truthy
        expect(workshop.contact_phone).to eq '987-654-0000'
      end
    end

    context 'additional configuration panel' do
      it 'sets the social buttons' do
        expect(workshop.show_social_buttons).to be_falsey
        expect(update_workshop(show_social_buttons: true)).to be_truthy
        expect(workshop.show_social_buttons).to be_truthy
      end

      it 'sets the summary' do
        expect(workshop.summary_en).to eq nil
        expect(update_workshop(summary_en: 'Test data')).to be_truthy
        expect(workshop.summary_en).to eq 'Test data'
      end

      it 'sets the associated blog' do
        blog = create :blog
        expect(workshop.cms_blog).to eq nil
        expect(update_workshop(cms_blog: 1, additional_configuration: true)).to be_truthy
        expect(workshop.cms_blog).to eq blog
      end

      # TODO definition of custom fields needs to be extracted into it's own panel
      # and creation/management process
      # describe 'custom fields' do
      #   it 'adds a new custom field' do
      #     expect(workshop.custom_field_defs.count).to eq 0
      #     custom_field = {
      #         field_type: 'text_field', required: '0', label_en: 'Test Label',
      #         description_en: 'Sample Description', choice_list: '', name: ''
      #     }
      #     expect(update_workshop(custom_field_defs_attributes: custom_field, additional_configuration: true)).to be_truthy
      #   end
      # end
    end
  end

end
