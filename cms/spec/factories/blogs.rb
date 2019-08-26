FactoryBot.define do
  factory :blog, class: CmsBlog do
    # let the slug get auto-generated
    title                   { 'Test Blog' }
    published               { true }

    factory :news_blog do
      slug          { 'news-blog' }
      title         { 'News Blog' }
      published     { true }
    end

    factory :invalid_blog do
      title               { nil }
    end
  end
end
