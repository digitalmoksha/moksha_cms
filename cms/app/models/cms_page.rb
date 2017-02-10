# Implementation Note: if the 'menutitle' is blank, that indicates the page should
# not be shown in menus.  It can still be published and directly linked to, but
# it should not show up in any auto-generated menus.  This gives the ability
# to have many pages in a section, with some of them 'hidden' from the main menu
# lists, but can still be linked to and shown.
#------------------------------------------------------------------------------
class CmsPage < ActiveRecord::Base
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  #--- NOTE: if you add any new fields, then update the duplicate_with_associations method
  
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :menutitle, :fallbacks_for_empty_translations => true #, :versioning => true
  globalize_accessors     :locales => DmCore::Language.language_array
    
  # --- versioning - skip anything translated
  has_paper_trail         :skip => [:title, :menutitle]
  
  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  # --- associations
  has_many                :cms_contentitems, -> { order(:row_order) }, :dependent => :destroy
  has_ancestry            :cache_depth => true
  before_save             :cache_depth  # fixes bug where depth not recalculated when subtree moved

  include RankedModel
  ranks                   :row_order, :with_same => [:account_id, :ancestry]

  default_scope           { where(account_id: Account.current.id).order("ancestry, row_order ASC") }
  
  preference              :show_social_buttons,  :boolean, :default => false
  preference              :header_accent_color,  :string

  amoeba do
    enable
  end
  
  # --- validations
  validates_length_of     :slug, :maximum => 50
  validates_presence_of   :slug
  validates_uniqueness_of :slug, :scope => :account_id
  validates_length_of     :pagetype, :maximum => 20
  validates_presence_of   :pagetype
  validates_length_of     :template, :maximum => 50
  
  # --- list of pagetypes
  PAGETYPE = [['Regular content', 'content'], ["Link to interior page using it's slug", 'pagelink'], ['Link to external page with url', 'link'], ['Link to external page with url (open in new window)', 'link-new-window'], ['Menu divider (no content)', 'divider'], ['Controller/Action (rarely used)', 'controller/action']]

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
    pagetype == 'divider'
  end
  
  # Return the template name. If it's empty, the go to each parent until one
  # is found.
  # raise an exception if there is no page template - otherwise error is hidden
  #------------------------------------------------------------------------------
  def page_template
    page = self
    page = page.parent while page.template.blank? && !page.is_root?      
    raise "No template available for page #{self.slug}" if page.template.blank?
    return page.template
  end

  # Return a list of published children pages
  # => user, to check for permissions
  # => include_blank_titles to true to include pages with blank titles.  
  #      do not include by default
  #------------------------------------------------------------------------------
  def published_children(user, options = {include_blank_titles: false})
    pages = []
    if self.has_children?
      self.children.each do |child|
        if child.is_published? || (user && user.is_admin?)
          pages << child unless child[:menutitle].blank? && !options[:include_blank_titles]
        end
      end
    end
    return pages
  end
  
  # Return the header image, or a default if not specified
  #------------------------------------------------------------------------------
  def header_image(default = nil)
    self.attributes['header_image'] || default
  end

  #------------------------------------------------------------------------------
  def header_accent_color(default = '')
    self.preferred_header_accent_color || default
  end
  
  #------------------------------------------------------------------------------
  def self.page_types
    PAGETYPE
  end

  # Generate any data to pass when rendering with Liquid
  #------------------------------------------------------------------------------
  def to_liquid
    { 'page' => 
      {
        'title'     => self.title,
        'menutitle' => self.menutitle,
        'slug'      => self.slug
      },
      'subscription' =>
      {
        'trial?'    => false,
        'active?'   => true
      }
    }
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
    return ((cookie_hash.empty? || cookie_hash[slug] == "1") ? true : false)
  end
  
  # Create a default site.  Check if pages exists first, so we can add missing
  # pages to already created sites.
  #------------------------------------------------------------------------------
  def self.create_default_site
    #--- index page
    unless (site = CmsPage.find_by_slug('index'))
      site = CmsPage.create(:slug => 'index', :pagetype => 'content', :template => 'index', 
                            :published => true, :title => 'Front Page')
    end

    unless (standard = CmsPage.find_by_slug('standard_pages'))
      standard = site.children.create(slug: 'standard_pages', pagetype: 'pagelink',
                                      published: false, title: 'Standard Pages')
    end
    
    unless CmsPage.find_by_slug('missing')
      standard.children.create( :slug => 'missing', :pagetype => 'content', :template => '404',
                                :published => true, :title => 'Page Missing')
    end
    
    unless CmsPage.find_by_slug('coming_soon')
      standard.children.create( :slug => 'coming_soon', :pagetype => 'content', :template => 'coming_soon',
                                :published => true, :title => 'Coming Soon')
    end
    unless CmsPage.find_by_slug('signup_success')
      standard.children.create( :slug => 'signup_success', :pagetype => 'pagelink',
                                :link => 'index', :published => true, :title => 'Signup Success')
    end
    unless CmsPage.find_by_slug('confirmation_success')
      standard.children.create( :slug => 'confirmation_success', :pagetype => 'pagelink',
                                :link => 'index', :published => true, :title => 'Confirmaton Success')
    end
  end

  # {todo} currently, this mostly works from the console.  However, when run
  # from the browser it hangs in some type of infinite loop, inside amoeba_dup.
  # Was unable to track it down, so this function is currently not called anywhere.
  #------------------------------------------------------------------------------
  def duplicate_with_associations
    new_page = nil
    new_slug = "duplicate-#{self.slug}"
    if CmsPage.find_by_slug(new_slug)
      #--- already a duplicate page, return nil
      return nil
    else
      CmsPage.paper_trail_off!
      CmsContentitem.paper_trail_off!
      CmsPage::Translation.paper_trail_off!
      CmsContentitem::Translation.paper_trail_off!
      new_page = self.amoeba_dup
      new_page.slug = new_slug
      # new_page.without_versioning do
        new_page.save
      # end
      CmsPage.paper_trail_on!
      CmsContentitem.paper_trail_on!
      CmsPage::Translation.paper_trail_on!
      CmsContentitem::Translation.paper_trail_on!
#       new_page      = self.initialize_dup(self)
#       new_page.slug = new_slug
#       
#       DmCore::Language.language_array.each do |locale|
#         new_page.send("title_#{locale}=",     self.send("title_#{locale}"))     unless self.send("title_#{locale}").nil?
#         new_page.send("menutitle_#{locale}=", self.send("menutitle_#{locale}")) unless self.send("menutitle_#{locale}").nil?
#         new_page.save
#        end
# #      new_page.save
#       new_page.reload
#       
#       # cms_contentitems.each do |content|
#       #   content.deep_clone(new_page.id)
#       # end
    end
    return new_page
  end

end
