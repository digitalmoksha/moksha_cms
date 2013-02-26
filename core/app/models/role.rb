# Dynamic shortcuts should NOT be enabled for this application, as it conflicts with
# default account scoping
#------------------------------------------------------------------------------
class Role < ActiveRecord::Base
  attr_accessible         :name, :account_id

  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to              :resource, :polymorphic => true
  
  scopify

  default_scope           { where(account_id: Account.current.id) }
end
