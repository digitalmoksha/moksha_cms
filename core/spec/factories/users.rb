require 'faker'

FactoryBot.define do
  factory :user do
    email           { Faker::Internet.email }
    password        { 'something' }
    confirmed_at    { Time.now }

    after(:build) do |user|
      build(:user_profile, user: user)
    end

    factory :admin_user do
      email           { 'admin@example.com' }
      password        { 'something_admin' }

      after(:create) do |user|
        user.add_role :admin
      end
    end
  end
end
