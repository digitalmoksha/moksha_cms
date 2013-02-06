class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  
  scopify

  #--- [todo] don't know if this would interfere with the scopify above...
  #default_scope           { where(account_id: Account.current.id) }
end
