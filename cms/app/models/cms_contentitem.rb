class CmsContentitem < ActiveRecord::Base
  class Translation < ::Globalize::ActiveRecord::Translation
    attr_accessible     :locale, :content
  end

  attr_accessible       :itemtype, :container, :purpose, :content, :cms_page_id, :enable_cache

  # --- associations
  belongs_to            :cms_page
  
  # --- acts_as_tree  
  acts_as_list          :scope => :cms_page #'cms_page_id = #{cms_page_id}'
  default_scope         :order => "position ASC"

  # --- globalize
  translates            :content, :fallbacks_for_empty_translations => true
  globalize_accessors   :locales => DmCore::Language.language_array
  
  # --- validations 
  validates_length_of   :itemtype,    :maximum => 30
  validates_length_of   :purpose,     :maximum => 255,  :allow_nil => true
  validates_length_of   :container,   :maximum => 30

  # --- content types supported
  CONTENT_TYPES = [ 'Textile', 'Markdown', 'Erb' ]

  after_update          :clear_cache
  before_destroy        :clear_cache

  #------------------------------------------------------------------------------
  def deep_clone(new_cms_page_id)
    new_cms_contentitem                  = self.clone
    new_cms_contentitem.cms_page_id      = new_cms_page_id

    DmCore::Language.language_array.each do |locale|
      eval("new_cms_contentitem.content_#{locale[:lang]}     = content_#{locale[:lang]} unless content_#{locale[:lang]}.nil?")
    end
    new_cms_contentitem.save
  end

  #------------------------------------------------------------------------------
  def clear_cache
    ActionController::Base.new.expire_fragment("page/#{DmCore::Language.locale}/#{cms_page_id}/fragment/#{container}_#{id}" )
  end

end
