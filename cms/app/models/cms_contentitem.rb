class CmsContentitem < ActiveRecord::Base
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  attr_accessible       :itemtype, :container, :content, :cms_page_id, :enable_cache, :original_updated_on

  belongs_to            :cms_page
  acts_as_list          :scope => :cms_page
  default_scope         { where(account_id: Account.current.id).order("position ASC") }
  
  # --- globalize
  translates            :content, :fallbacks_for_empty_translations => true
  globalize_accessors   :locales => DmCore::Language.language_array

  # --- versioning - skip anything translated
  has_paper_trail       :skip => :content
  
  amoeba do
    enable
  end
  # --- validations 
  validates_presence_of :itemtype, :container
  validates_length_of   :itemtype,    :maximum => 30
  validates_length_of   :container,   :maximum => 30
  validate              :validate_conflict, only: :update
  #validate              :validate_default_content_present

  # --- content types supported
  CONTENT_TYPES = [ 'Markdown', 'Textile', 'HTML' ]

  after_update          :clear_cache
  before_destroy        :clear_cache

  #------------------------------------------------------------------------------
  def original_updated_on
    @original_updated_on || self.updated_on.to_f
  end
  attr_writer :original_updated_on
  
  # Try to see if the record has been changed by someone while being edited by someone
  # else.  If original_updated_on is not set, then don't check - allows acts_as_list
  # methods to update without causing a problem.
  #------------------------------------------------------------------------------
  def validate_conflict
    if @conflict || (!@original_updated_on.nil? && self.updated_on.to_f > @original_updated_on.to_f)
      @conflict             = true
      @original_updated_on  = nil
      errors.add :base, "This record was changed while you were editing."
      changes.each do |attribute, values|
        errors.add attribute, "was #{values.first}"
      end
    end
  end

  # [todo] does not check proper attribute
  #------------------------------------------------------------------------------
  def validate_default_content_present
    if attributes["content_#{Account.current.preferred_default_locale}"].blank?
      errors.add("content_#{Account.current.preferred_default_locale}", "should not be blank")
    end
  end
  
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
