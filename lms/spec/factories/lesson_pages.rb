FactoryBot.define do
  factory :lesson_page, class: LessonPage do
    slug            { 'lesson-page' }
    association     :lesson

    factory :lesson_page_2 do
      slug          { 'lesson-page-2' }
    end

    factory :lesson_page_3 do
      slug          { 'lesson-page-3' }
    end
  end
end
