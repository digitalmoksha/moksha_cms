# Note: fragment caching is used during rendering.  The cache key is based
# on both the model and the current locale (because each model supports
# multiple translations).  The cache will be busted automatically since
# the updated_at attribute will be updated on save.
#------------------------------------------------------------------------------
class CmsSnippet < ApplicationRecord
  class Translation < ::Globalize::ActiveRecord::Translation
    has_paper_trail
  end

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  default_scope         { where(account_id: Account.current.id) }
  
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates            :content, :fallbacks_for_empty_translations => true
  globalize_accessors   :locales => DmCore::Language.language_array

  # --- versioning - skip anything translated
  has_paper_trail       :skip => :content
  
  # --- validations 
  validates_presence_of :itemtype, :slug
  validates_length_of   :itemtype,    :maximum => 30
  validates             :content, liquid: { :locales => true }, presence_default_locale: true

  # --- content types supported
  CONTENT_TYPES = [ 'Markdown', 'Textile', 'HTML' ]

  #------------------------------------------------------------------------------
  def is_published?
    published
  end
  
  #------------------------------------------------------------------------------
  def to_liquid
    {}
  end

end
