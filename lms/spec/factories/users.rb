require 'faker'

FactoryGirl.define do
  factory :user do
    email           { Faker::Internet.email }
    password        "something"
    confirmed_at    Time.now
    user_profile
    
    factory :admin_user do
      email           'admin@example.com'
      password        'something_admin'

      after(:build) do |user|
        user.add_role :admin
      end
    end
  end
end