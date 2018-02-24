# Implementation Note: if the 'menutitle' is blank, that indicates the page should
# not be shown in menus.  It can still be published and directly linked to, but
# it should not show up in any auto-generated menus.  This gives the ability
# to have many pages in a section, with some of them 'hidden' from the main menu
# lists, but can still be linked to and shown.
#------------------------------------------------------------------------------
class CmsPage < ApplicationRecord
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  #--- NOTE: if you add any new fields, then update the duplicate_with_associations method

  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :menutitle, :fallbacks_for_empty_translations => true # , :versioning => true
  globalize_accessors     locales: I18n.available_locales

  # --- versioning - skip anything translated
  has_paper_trail         :skip => [:title, :menutitle]

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  acts_as_taggable

  # --- associations
  has_many                :cms_contentitems, -> { order(:row_order) }, :dependent => :destroy
  has_ancestry            :cache_depth => true
  before_save             :cache_depth # fixes bug where depth not recalculated when subtree moved

  include RankedModel
  ranks                   :row_order, :with_same => [:account_id, :ancestry]

  default_scope           { where(account_id: Account.current.id).order("ancestry, row_order ASC") }
  scope                   :welcome_pages, -> { where(welcome_page: true) }

  preference              :show_social_buttons,  :boolean, default: false
  preference              :header_accent_color,  :string
  preference              :open_in_new_window,   :boolean, default: false
  preference              :divider,              :boolean, default: false

  amoeba do
    enable
  end

  # --- validations
  validates_presence_of   :slug
  validates_length_of     :slug, maximum: 255
  validates_uniqueness_of :slug, scope: :account_id
  validates_length_of     :template, maximum: 50
  validates_length_of     :link, maximum: 255
  validates_length_of     :menuimage, maximum: 255
  validates_length_of     :featured_image, maximum: 255
  validates_length_of     :header_image, maximum: 255
  I18n.available_locales.each do |locale|
    validates_length_of     :"title_#{locale}", maximum: 255
    validates_length_of     :"menutitle_#{locale}", maximum: 255
  end

  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def model_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  # is the page published, based on the publish flag and the publish dates
  #------------------------------------------------------------------------------
  def is_published?
    # --- {todo} need to hook in the publish dates
    published
  end

  #------------------------------------------------------------------------------
  def show_social_buttons?
    preferred_show_social_buttons?
  end

  # is this a special divider page - which doesn't get rendered, it's for adding
  # categories in a sub menu
  #------------------------------------------------------------------------------
  def divider?
    preferred_divider?
  end

  #------------------------------------------------------------------------------
  def content_page?
    !divider? && link.blank?
  end

  #------------------------------------------------------------------------------
  def redirect_page?
    !divider? && !link.blank?
  end

  #------------------------------------------------------------------------------
  def pagetype_name
    content_page? ? 'Content' : (redirect_page? ? 'Redirect' : 'Divider')
  end

  # Return the template name. If it's empty, the go to each parent until one
  # is found.
  # raise an exception if there is no page template - otherwise error is hidden
  #------------------------------------------------------------------------------
  def page_template
    page = self
    page = page.parent while page.template.blank? && !page.is_root?
    raise "No template available for page #{slug}" if page.template.blank?

    page.template
  end

  # Return a list of published children pages
  # => user, to check for permissions
  # => include_blank_titles to true to include pages with blank titles.
  #      do not include by default
  #------------------------------------------------------------------------------
  def published_children(user, options = { include_blank_titles: false })
    pages = []
    if has_children?
      children.each do |child|
        if child.is_published? || (user&.is_admin?)
          pages << child unless child[:menutitle].blank? && !options[:include_blank_titles]
        end
      end
    end
    pages
  end

  # Return the header image, or a default if not specified
  #------------------------------------------------------------------------------
  def header_image(default = nil)
    attributes['header_image'] || default
  end

  #------------------------------------------------------------------------------
  def header_accent_color(default = '')
    preferred_header_accent_color || default
  end

  # return a list of tags for all Page objects
  #------------------------------------------------------------------------------
  def self.tag_list_all
    CmsPage.tag_counts_on(:tags).map(&:name).sort
  end

  # Generate any data to pass when rendering with Liquid
  #------------------------------------------------------------------------------
  def to_liquid
    { 'page' =>
      {
        'title'     => title,
        'menutitle' => menutitle,
        'slug'      => slug
      },
      'subscription' =>
      {
        'trial?'    => false,
        'active?'   => true
      } }
  end

  #------------------------------------------------------------------------------
  def self.liquid_help
    [
      { name: 'page.title',
        summary: "Page title",
        category: 'variables',
        example: '{{ page.title }}',
        description: "Display the page's title" },
      { name: 'page.menutitle',
        summary: "Page menutitle",
        category: 'variables',
        example: '{{ page.menutitle }}',
        description: "Display the page's menutitle" },
      { name: 'page.slug',
        summary: "Page slug",
        category: 'variables',
        example: '{{ page.slug }}',
        description: "Display the page's slug" }
    ]
  end

  # Check if this page has been cookied.  If needed, we will set a cookie, using
  # the page's slug, to a value of 1.  This indicates that the page has
  # been visited.  This is only needed in cases where we want to ensure a page
  # has been visited before enabling some other function.
  #
  # If cookie_hash is empty, then we don't care if the page has been visited or not,
  # simply return true
  #------------------------------------------------------------------------------
  def visited?(cookie_hash)
    (cookie_hash.empty? || cookie_hash[slug] == "1" ? true : false)
  end

  #------------------------------------------------------------------------------
  def mark_as_welcome_page
    if welcome_page?
      update_attribute(:welcome_page, false)
    else
      prev_page = CmsPage.welcome_page
      prev_page&.update_attribute(:welcome_page, false)
      update_attribute(:welcome_page, true)
    end
  end

  #------------------------------------------------------------------------------
  def self.welcome_page
    welcome_pages.first
  end

  # Create a default site.  Check if pages exists first, so we can add missing
  # pages to already created sites.
  #------------------------------------------------------------------------------
  def self.create_default_site
    #--- index page
    unless (site = CmsPage.find_by_slug('index'))
      site = CmsPage.create(slug: 'index', template: 'index', published: true, title: 'Front Page')
    end

    unless (standard = CmsPage.find_by_slug('standard_pages'))
      standard = site.children.create(slug: 'standard_pages', published: false, title: 'Standard Pages')
    end

    unless CmsPage.find_by_slug('missing')
      standard.children.create(slug: 'missing', template: '404', published: true, title: 'Page Missing')
    end

    unless CmsPage.find_by_slug('coming_soon')
      standard.children.create(slug: 'coming_soon', template: 'coming_soon', published: true, title: 'Coming Soon')
    end
    unless CmsPage.find_by_slug('signup_success')
      standard.children.create(slug: 'signup_success', link: 'index', published: true, title: 'Signup Success')
    end
    unless CmsPage.find_by_slug('confirmation_success')
      standard.children.create(slug: 'confirmation_success', link: 'index', published: true, title: 'Confirmaton Success')
    end
  end

  # {todo} currently, this mostly works from the console.  However, when run
  # from the browser it hangs in some type of infinite loop, inside amoeba_dup.
  # Was unable to track it down, so this function is currently not called anywhere.
  #------------------------------------------------------------------------------
  def duplicate_with_associations
    new_page = nil
    new_slug = "duplicate-#{slug}"
    if CmsPage.find_by_slug(new_slug)
      #--- already a duplicate page, return nil
      return nil
    else
      CmsPage.paper_trail_off!
      CmsContentitem.paper_trail_off!
      CmsPage::Translation.paper_trail_off!
      CmsContentitem::Translation.paper_trail_off!
      new_page = amoeba_dup
      new_page.slug = new_slug

      # new_page.without_versioning do
      #   new_page.save
      # end
      new_page.save

      CmsPage.paper_trail_on!
      CmsContentitem.paper_trail_on!
      CmsPage::Translation.paper_trail_on!
      CmsContentitem::Translation.paper_trail_on!
    end

    new_page
  end
end
