FactoryGirl.define do

  factory :post, class: CmsPost do
    slug            'test-post'
    title           'Test Post'
    summary         'Test Summary'
    content         'Test content'
    
    factory :news_post do
      slug          'news-post'
      title         'News Post'
      summary       'News Summary'
      content       'News content'
    end

    factory :invalid_post do
      title               nil
      summary             nil
      content             nil
    end
  end

end