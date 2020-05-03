FactoryBot.define do
  factory :country, class: DmCore::Country do
    code         { 'US' }
    english_name { 'United States' }

    initialize_with { new(attributes) }
  end
end
