# Note: fragment caching is used during rendering.  The cache key is based
# on both the model and the current locale (because each model supports
# multiple translations).  The cache will be busted automatically since
# the updated_at attribute will be updated on save.
#------------------------------------------------------------------------------
class CmsContentitem < ApplicationRecord
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  belongs_to            :cms_page

  include RankedModel
  ranks                 :row_order, with_same: [:account_id, :cms_page_id]
  default_scope         { where(account_id: Account.current.id) }
  
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates            :content, fallbacks_for_empty_translations: true
  globalize_accessors   locales: I18n.available_locales

  # --- versioning - skip anything translated
  has_paper_trail       skip: :content
  
  amoeba do
    enable
  end
  # --- validations 
  validates_presence_of :itemtype,          :container
  validates_length_of   :itemtype,          maximum: 30
  validates_length_of   :container,         maximum: 30
  validate              :validate_conflict, on: :update
  validates             :content,           liquid: { locales: true }, presence_default_locale: true

  # --- content types supported
  CONTENT_TYPES = [ 'Markdown', 'Textile', 'HTML' ]

  #------------------------------------------------------------------------------
  def original_updated_on
    @original_updated_on || self.updated_on.to_f
  end
  attr_writer :original_updated_on
  
  # Try to see if the record has been changed by someone while being edited by someone
  # else.  If original_updated_on is not set, then don't check - allows acts_as_list
  # methods to update without causing a problem.
  # [todo] still needed since we don't use acts_as_list anymore?
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

  # Generate any data to pass when rendering with Liquid
  #------------------------------------------------------------------------------
  def to_liquid
    cms_page.to_liquid
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
  def self.liquid_help
    CmsPage.liquid_help + User.liquid_help
  end
end
