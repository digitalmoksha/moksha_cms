FactoryBot.define do
  factory :blog, class: CmsBlog do
    slug            'test-blog'
    title           'Test Blog'
    published       true
  end
end