#------------------------------------------------------------------------------
class CmsPage < ActiveRecord::Base
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  attr_accessible         :slug, :pagetype, :published, :template, :link, :menuimage, :requires_login, :title, :title_en, :menutitle

  # --- globalize
  translates              :title, :menutitle, :fallbacks_for_empty_translations => true, :versioning => true
  globalize_accessors     :locals => DmCore::Language.language_array
    
  # --- versioning - skip anything translated
  has_paper_trail         :skip => [:title, :menutitle]
  
  # --- associations
  has_many                :cms_contentitems, :order => :position, :dependent => :destroy
  has_ancestry            :cache_depth => true
  acts_as_list            :scope => 'ancestry = \'#{ancestry}\''

  default_scope           { where(account_id: Account.current.id).order("ancestry_depth, position ASC") }
  
  # --- validations
  validates_length_of     :slug, :maximum => 50
  validates_presence_of   :slug
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
  
  # Create a default site
  #------------------------------------------------------------------------------
  def self.create_default_site
    site        = CmsPage.create( :slug => 'index', :pagetype => 'content', :template => 'site_frontpage', 
                                  :published => true, :title => 'Front Page')
    missing     = site.children.create(:slug => 'missing', :pagetype => 'content', :published => true, :title => 'Page Missing')
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
  
  #------------------------------------------------------------------------------
  def deep_clone(new_site, new_parent_id)
    new_page                  = self.clone
    new_page.account_site_id  = new_site.id
    new_page.parent_id        = new_parent_id

    DmCore::Language.language_array.each do |locale|
      eval("new_page.title_#{locale[:lang]}       = title_#{locale[:lang]} unless title_#{locale[:lang]}.nil?")
      eval("new_page.menutitle_#{locale[:lang]}   = menutitle_#{locale[:lang]} unless menutitle_#{locale[:lang]}.nil?")
    end
    new_page.save

    cms_contentitems.each do |content|
      content.deep_clone(new_page.id)
    end
    
    children.each do |child|
      child.deep_clone(new_site, new_page.id)
    end
  end
=end
end
