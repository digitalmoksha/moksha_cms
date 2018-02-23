FactoryBot.define do
  factory :account do
    domain                      'test.example.com'
    account_prefix              'local'
    preferred_default_currency  'EUR'
    preferred_locales           'en, de'
    preferred_site_enabled      true
    preferred_smtp_from_email   'no-reply@company.com'

    factory :second_account do
      domain                      'second.example.com'
      account_prefix              'second'
      preferred_default_currency  'USD'
    end
  end
end