require 'faker'

FactoryBot.define do
  factory :mailchimp_newsletter do
    mc_id { 'abcd1234' }

    trait :skip_validate do
      to_create do |instance|
        instance.save!(validate: false)
      end
    end
  end
end
