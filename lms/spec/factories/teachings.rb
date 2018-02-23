FactoryBot.define do
  factory :teaching, class: Teaching do
    title           'Teaching 1'
    content         'Lorem ipsum dolor...'

    factory :teaching_2 do
      title           'Teaching 2'
      content         'Lorem ipsum dolor...'
    end

    factory :teaching_3 do
      title           'Teaching 3'
      content         'Lorem ipsum dolor...'
    end
  end
end