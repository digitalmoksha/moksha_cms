#------------------------------------------------------------------------------
class Activity < ActiveRecord::Base

  self.table_name   = 'core_activities'
  attr_accessible   :user_id, :browser, :session_id, :ip_address, :action, :params, :slug

  default_scope     { where(account_id: Account.current.id).order("created_at ASC") }

  belongs_to :user
  
end
