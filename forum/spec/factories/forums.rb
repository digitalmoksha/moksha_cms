FactoryBot.define do
  factory :forum, class: Forum do
    # let the slug get auto-generated
    name 'Test Forum'
    published true
  end
end