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
    payment_date    { Time.now }
  end
end
