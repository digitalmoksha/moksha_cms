#------------------------------------------------------------------------------
class CmsPage < ActiveRecord::Base
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  #--- NOTE: if you add any new fields, then update the duplicate_with_associations method
  
  attr_accessible         :slug, :pagetype, :published, :template, :link, :menuimage, :requires_login,
                          :title, :title_en, :menutitle, :parent_id

  # --- globalize
  translates              :title, :menutitle, :fallbacks_for_empty_translations => true, :versioning => true
  globalize_accessors     :locals => DmCore::Language.language_array
    
  # --- versioning - skip anything translated
  has_paper_trail         :skip => [:title, :menutitle]
  
  # --- associations
  has_many                :cms_contentitems, :order => :position, :dependent => :destroy
  has_ancestry            :cache_depth => true
  before_save             :cache_depth  # fixes bug where depth not recalculated when subtree moved
  acts_as_list            :scope => 'ancestry = \'#{ancestry}\''

  default_scope           { where(account_id: Account.current.id).order("ancestry_depth, position ASC") }
  
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
  PAGETYPE = ['content', 'pagelink', 'controller/action', 'link', 'divider']

  # is the page published, based on the publish flag and the publish dates
  #------------------------------------------------------------------------------
  def is_published?
    # --- {todo} need to hook in the publish dates
    published
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

  #------------------------------------------------------------------------------
  def self.page_types
    PAGETYPE
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
      standard.children.create( :slug => 'signup_success', :pagetype => 'content',
                                :published => true, :title => 'Signup Success')
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
      CmsPage.paper_trail_off
      CmsContentitem.paper_trail_off
      CmsPage::Translation.paper_trail_off
      CmsContentitem::Translation.paper_trail_off
      new_page = self.amoeba_dup
      new_page.slug = new_slug
      # new_page.without_versioning do
        new_page.save
      # end
      CmsPage.paper_trail_on
      CmsContentitem.paper_trail_on
      CmsPage::Translation.paper_trail_on
      CmsContentitem::Translation.paper_trail_on
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

=begin
  # Get the page id of the parent at item a specific level
  #------------------------------------------------------------------------------
  def parent_at_level(level)
    if level >= self.level
      return self.id
    end
    
    # --- maybe the level we're looking for is one back - saves a query
    return self.parent_id if level == self.level - 1

    tempPage = CmsPage.find(self.parent_id)
    while tempPage.level > level
      tempPage = CmsPage.find(tempPage.parent_id)
    end

    return tempPage.id
  end
  
=end
end
