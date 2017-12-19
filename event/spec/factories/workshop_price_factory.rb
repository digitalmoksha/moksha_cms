# frozen_string_literal: true
FactoryBot.define do
  factory :workshop_price do
    price_description "Sample Price"
    price_cents       50000
    price_currency    'EUR'

    trait :with_workshop do
      association :workshop
    end

    trait :with_recurring do
      recurring_amount 10000
      recurring_period 30  # days
      recurring_number 5
    end
  end

end
