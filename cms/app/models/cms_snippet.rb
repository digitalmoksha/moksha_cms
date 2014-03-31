class CmsSnippet < ActiveRecord::Base
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

  after_update          :clear_cache
  before_destroy        :clear_cache

  #------------------------------------------------------------------------------
  def is_published?
    published
  end
  
  #------------------------------------------------------------------------------
  def to_liquid
    {}
  end

  #------------------------------------------------------------------------------
  def clear_cache
    ActionController::Base.new.expire_fragment("snippet/#{DmCore::Language.locale}/fragment/#{slug}_#{id}" )
  end

end
