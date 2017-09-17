# Generated from acts_as_commentable
#------------------------------------------------------------------------------
class SystemEmail < ApplicationRecord

  self.table_name       = 'core_system_emails'

  belongs_to            :emailable, :polymorphic => true

  default_scope         { where(account_id: Account.current.id) }

  # --- globalize
  translates            :subject, :body, :fallbacks_for_empty_translations => true
  globalize_accessors   locales: I18n.available_locales

end
