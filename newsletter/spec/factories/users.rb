require 'faker'

FactoryGirl.define do
  factory :user do
    email           { Faker::Internet.email }
    password        "something"
    confirmed_at    Time.now
    user_profile
    
    factory :user_admin do

      after(:build) do |user|
        user.add_role :admin
      end
    end
  end
end