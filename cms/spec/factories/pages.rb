FactoryBot.define do

  factory :page, class: CmsPage do
    slug            'test-page'
    title           'Test Page'
    template        'index'
    published       true
    requires_login  false

    factory :page_internal_pagelink do
      slug          'test-pagelink'
      link          'test-page'    # redirects to another page
    end

    factory :page_external_link do
      slug          'test-external-link'
      link          'http://another.example.com/en/test-page'  # redirects to another page
    end

    factory :page_external_link_new_window do
      slug          'test-external-link-new-window'
      link          'http://another.example.com/en/test-page'  # redirects to another page
      preferred_open_in_new_window  true
    end

    factory :page_divider do
      slug               'test-divider'
      preferred_divider  true
    end
  end

end