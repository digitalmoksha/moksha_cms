# frozen_string_literal: true
FactoryBot.define do
  factory :registration do
    amount_paid_cents     0
    amount_paid_currency  'EUR'
    discount_value        nil
    discount_use_percent  nil

    workshop
    workshop_price { workshop.workshop_prices.first }
  end
end
