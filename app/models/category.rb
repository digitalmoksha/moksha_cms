#------------------------------------------------------------------------------
class Category < ActiveRecord::Base

  self.table_name       = 'core_categories'
  attr_accessible       :name, :description

  include RankedModel
  ranks                 :row_order, :with_same => :account_id

  default_scope         { where(account_id: Account.current.id) }
  scope                 :ordered, order('row_order ASC')

  # --- globalize
  translates            :name, :description, :fallbacks_for_empty_translations => true
  globalize_accessors   :locales => DmCore::Language.language_array

  validates_presence_of :name

end
