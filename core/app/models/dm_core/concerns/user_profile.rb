module DmCore
  module Concerns
    module UserProfile
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be 
      # executed in the module's context (blorgh/concerns/models/post).
      included do
        attr_accessible         :first_name, :last_name, :country_id, :public_name

        belongs_to              :user
        belongs_to              :country, :class_name => 'DmCore::Country'

        validates_presence_of   :public_name
        validates_uniqueness_of :public_name
        validates_presence_of   :first_name, :if => :require_name?
        validates_presence_of   :last_name, :if => :require_name?
        validates_presence_of   :country_id, :if => :require_country?

        after_create            :add_account

        # When a profile is created, attach it to the current account
        #------------------------------------------------------------------------------
        def add_account
          self.update_attribute(:account_id, Account.current.id)
        end
        
        #------------------------------------------------------------------------------
        def full_name
          first_name.to_s + " " + last_name.to_s
        end

        # for displaying their displayable profile name
        #------------------------------------------------------------------------------
        def display_name
          public_name
        end

        # Override this method if you don't want to require the first/last name
        #------------------------------------------------------------------------------
        def require_name?
          true
        end
        
        # Override this method if you don't want to require country
        #------------------------------------------------------------------------------
        def require_country?
          true
        end


      end

      module ClassMethods
        #------------------------------------------------------------------------------
        def access_last_30_days
          items = 27.step(0, -3).map do |date| 
            where('last_access_at <= ? AND last_access_at > ?', date.days.ago.to_datetime, (date + 3).days.ago.to_datetime).count
          end
          return { :total => items.inject(:+), :list => items.join(',') }
        end

      end
    end
  end
end

