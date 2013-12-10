FactoryGirl.define do
  factory :workshop do
    account
    title_en        'Test Workshop'
    slug            'test-workshop'
    country_id      55
    base_currency   'EUR'
    event_style     'workshop'
    starting_on     '2014-12-01'
    ending_on       '2014-12-02'
    contact_email   'email@example.com'
    
  end
end