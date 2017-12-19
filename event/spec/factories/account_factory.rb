FactoryBot.define do
  factory :account do
    domain              'test.example.com'
    account_prefix      'test'
    preferred_locales   'en, de'
  end
end