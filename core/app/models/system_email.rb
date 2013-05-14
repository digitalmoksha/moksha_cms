# Generated from acts_as_commentable
#------------------------------------------------------------------------------
class SystemEmail < ActiveRecord::Base

  self.table_name       = 'core_system_emails'
  attr_accessible       :email_type

  belongs_to            :emailable, :polymorphic => true

  default_scope         { where(account_id: Account.current.id) }

  # --- globalize
  translates            :subject, :body, :fallbacks_for_empty_translations => true
  globalize_accessors   :locales => DmCore::Language.language_array

end
