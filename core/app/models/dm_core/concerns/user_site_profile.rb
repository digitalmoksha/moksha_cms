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
        
        #--- allows following posts, forum topics, etc
        acts_as_follower
        
        #   Note: don't use a default account scope as it makes some of the User 
        #   associations a little more difficult
        scope                   :this_site, -> { where(account_id: Account.current.id) }

        before_create           :create_uuid

        #------------------------------------------------------------------------------
        def create_uuid
          self.uuid = SecureRandom.uuid
        end
      end

      module ClassMethods

        # Count the number of new users in the last 30 days.  returns a hash
        # with the total, and a json list of 15 values indicating how many were created
        # every 2 days
        # eg: { total: 36, list: "0,0,0,0,0,0,0,0,0,2,13,10,6,1,4" }
        #------------------------------------------------------------------------------
        def new_last_30_days
          items = 28.step(0, -2).map do |date| 
            self.where('created_at <= ? AND created_at > ? AND account_id = ?', date.days.ago.to_datetime, (date + 2).days.ago.to_datetime, Account.current.id).count
          end
          return { total: items.inject(:+), list: items.join(',') }
        end

        # Count the number of accessing users in the last 30 days.  returns a hash
        # with the total, and a json list of 15 values indicating how many were accessed
        # every 2 days
        # eg: { total: 35, list: "0,0,0,0,0,0,0,0,0,0,2,4,2,5,22" }
        #------------------------------------------------------------------------------
        def access_last_30_days
          items = 28.step(0, -2).map do |date| 
            where('last_access_at <= ? AND last_access_at > ? AND account_id = ?', date.days.ago.to_datetime, (date + 2).days.ago.to_datetime, Account.current.id).count
          end
          return { total: items.inject(:+), list: items.join(',') }
        end

      end
    end
  end
end

