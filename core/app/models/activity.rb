#------------------------------------------------------------------------------
class Activity < ApplicationRecord

  self.table_name   = 'core_activities'

  default_scope     { where(account_id: Account.current.id).order("created_at ASC") }

  belongs_to :user
  
end
