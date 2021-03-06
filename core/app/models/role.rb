# Dynamic shortcuts should NOT be enabled for this application, as it conflicts with
# default account scoping
#------------------------------------------------------------------------------
class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to              :resource, polymorphic: true, optional: true

  scopify

  default_scope { where(account_id: Account.current.id) }
end
