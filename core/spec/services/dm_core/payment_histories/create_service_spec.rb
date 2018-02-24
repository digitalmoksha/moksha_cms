require 'spec_helper'

describe DmCore::PaymentHistories::CreateService, type: :service do
  setup_account

  let(:user_profile) { create :user_profile }

  describe '#call' do
    let(:anchor_id) { 'test-1234' }
    let(:amount) { Money.new(5000, 'EUR') }
    let(:options) do
      { item_ref: 'item one', payment_method: 'paypal', payment_date: Time.now, notify_data: 'test', transaction_id: '1234' }
    end
    let!(:service) { described_class.new(anchor_id, amount, user_profile, options) }

    it 'creates a new PaymentHistory' do
      history = service.call

      expect(history).to be_a PaymentHistory
      expect(history).to have_attributes(anchor_id: anchor_id)
      expect(history).to have_attributes(total_cents: amount.cents, total_currency: amount.currency.iso_code)
      expect(history).to have_attributes(item_ref: options[:item_ref])
      expect(history).to have_attributes(cost: amount.to_f.to_s, quantity: 1, discount: "0")
      expect(history).to have_attributes(payment_method: options[:payment_method], payment_date: options[:payment_date])
      expect(history).to have_attributes(bill_to_name: nil, notify_data: options[:notify_data], transaction_id: options[:transaction_id])
      expect(history).to have_attributes(user_profile_id: user_profile.id, status: 'Completed')
    end
  end
end
