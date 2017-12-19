FactoryBot.define do

  factory :account do
    domain                      'test.example.com'
    account_prefix              'test'
    preferred_default_currency  'EUR'
  end

end