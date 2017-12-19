FactoryBot.define do

  factory :course, class: Course do
    # let the slug get auto-generated
    title           'Test Course'
    published       true

    factory :training_course do
      slug          'training-course'
      title         'Training Course'
      published     true
    end
  end

end