require 'spec_helper'

describe DmCore::PaymentHistories::UpdateService, type: :service do
  setup_account

  let(:user_profile) { create :user_profile }

  describe '#call' do
    let(:amount)    { Money.new(6000, 'USD') }
    let(:options)   { { item_ref: 'item two', payment_method: 'cash', payment_date: Time.now, bill_to_name: 'test' } }

    it 'udpate a PaymentHistory' do
      history = create(:payment_history)
      described_class.new(history, amount, user_profile, options).call

      expect(history).to have_attributes(total_cents: amount.cents, total_currency: amount.currency.iso_code)
      expect(history).to have_attributes(cost: amount.to_f.to_s)
      expect(history).to have_attributes(item_ref: options[:item_ref])
      expect(history).to have_attributes(payment_method: options[:payment_method], payment_date: options[:payment_date])
      expect(history).to have_attributes(bill_to_name: 'test')
    end
  end
end
