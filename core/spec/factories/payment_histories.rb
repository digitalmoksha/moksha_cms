require 'faker'

FactoryBot.define do
  factory :payment_history do
    anchor_id       'test-1234'
    total_cents     5000
    total_currency  'EUR'
    item_ref        'ref'
    cost            "50.0"
    quantity        1
    discount        "0"
    payment_method  'paypal'
    payment_date    Time.now
    # expect(history).to have_attributes(bill_to_name: nil, notify_data: options[:notify_data], transaction_id: options[:transaction_id])
    # expect(history).to have_attributes(user_profile_id: user_profile.id, status: 'Completed')
  end
end