require 'faker'

FactoryBot.define do
  factory :user_profile do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    public_name { Faker::Name.first_name }
    email       { Faker::Internet.email }
    country     { create(:country) }

    association :user
  end
end
