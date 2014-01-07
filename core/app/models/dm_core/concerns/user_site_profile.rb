# This holds a site profile for a user.  This is any data that is needed for
# a user, on a per site/account basis, such as site specific preferences, login times,
# etc.
#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module UserSiteProfile
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be 
      # executed in the module's context (blorgh/concerns/models/post).
      included do

        belongs_to              :user

        #--- votability on a per site basis
        acts_as_voter
  
        #   Note: don't use a default account scope as it makes some of the User 
        #   associations a little more difficult
        scope                   :this_site, lambda { where(account_id: Account.current.id) }
      end

      module ClassMethods

        #------------------------------------------------------------------------------
        def new_last_30_days
          items = 27.step(0, -3).map do |date| 
            self.where('created_at <= ? AND created_at > ? AND account_id = ?', date.days.ago.to_datetime, (date + 3).days.ago.to_datetime, Account.current.id).count
          end
          return { :total => items.inject(:+), :list => items.join(',') }
        end

        #------------------------------------------------------------------------------
        def access_last_30_days
          items = 27.step(0, -3).map do |date| 
            where('last_access_at <= ? AND last_access_at > ? AND account_id = ?', date.days.ago.to_datetime, (date + 3).days.ago.to_datetime, Account.current.id).count
          end
          return { :total => items.inject(:+), :list => items.join(',') }
        end

      end
    end
  end
end

