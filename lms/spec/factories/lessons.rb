FactoryBot.define do

  factory :lesson, class: Lesson do
    slug            'lesson-1'
    title           'Lesson 1'
    association     :course

    factory :lesson_2 do
      slug          'lesson-2'
      title         'Lesson 2'
    end

    factory :lesson_3 do
      slug          'lesson-3'
      title         'Lesson 3'
    end
  end

end