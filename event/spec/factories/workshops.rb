FactoryBot.define do
  factory :workshop do
    title_en        { 'Test Workshop' }
    description_en  { 'This is a test workshop' }
    slug            { 'test-workshop' }
    country_id      { 55 }
    base_currency   { 'EUR' }
    event_style     { 'workshop' }
    starting_on     { '2014-12-01' }
    ending_on       { '2014-12-02' }
    contact_email   { 'email@example.com' }
    country         { create(:country) }

    factory :workshop_with_price do
      after(:create) do |workshop, evaluator|
        create_list(:workshop_price, 1, workshop: workshop)
      end
    end

    factory :workshop_with_recurring_price do
      after(:create) do |workshop, evaluator|
        create_list(:workshop_price, 1, :with_recurring, workshop: workshop)
      end
    end
  end
end
