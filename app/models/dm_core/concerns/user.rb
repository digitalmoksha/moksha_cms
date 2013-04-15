module DmCore
  module Concerns
    module User
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be 
      # executed in the module's context (blorgh/concerns/models/post).
      included do
        rolify

        # Include default devise modules. Others available are:
        # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
        devise :database_authenticatable, :registerable, :confirmable,
               :recoverable, :rememberable, :trackable, :validatable

        # Setup accessible (or protected) attributes for your model
        attr_accessible         :email, :password, :password_confirmation, :remember_me,
                                  :first_name, :last_name, :country_id
        attr_accessible         :role_ids, :email, :password, :password_confirmation, :remember_me,
                                  :first_name, :last_name, :country_id,  
                                  :as => :admin

        belongs_to              :country, :class_name => 'DmCore::Country'

        validates_presence_of   :first_name, :if => :require_name?
        validates_presence_of   :last_name, :if => :require_name?
        validates_presence_of   :country_id, :if => :require_country?
        validates_presence_of   :email

        after_create            :add_account
        
        scope                   :online, lambda { where('last_access_at >= ?', 10.minutes.ago.utc) }
        
        # When a user is created, attach it to the current account
        #------------------------------------------------------------------------------
        def add_account
          self.skip_reconfirmation!  # make sure a second confirmation email is not sent
          self.update_attribute(:account_id, Account.current.id)
        end
        
        # Determin if this user has the Admin role
        #------------------------------------------------------------------------------
        def is_admin?
          has_role?(:admin)
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
        
        #------------------------------------------------------------------------------
        def display_name
          self.first_name.to_s + " " + self.last_name.to_s
        end
        
        #------------------------------------------------------------------------------
        def update_last_access
          update_attribute(:last_access_at, Time.now.utc) if self.last_access_at.nil? || (self.last_access_at <= 10.minutes.ago)
        end
        
        # check if a user is active
        # {todo} add in attribute or state machine for the users state
        #------------------------------------------------------------------------------
        def active?
          true
        end

        # check if a user is suspended
        # {todo} add in attribute or state machine for the users state
        #------------------------------------------------------------------------------
        def suspended?
          false
        end
        
        # Return the state of the user
        # {todo} add in attribute or state machine for the users state
        #------------------------------------------------------------------------------
        def state
          'active'
        end
      end

      module ClassMethods

        #------------------------------------------------------------------------------
        def new_last_30_days
          items = 27.step(0, -3).map do |date| 
            self.where('created_at <= ? AND created_at > ?', date.days.ago.to_datetime, (date + 3).days.ago.to_datetime).count
          end
          return { :total => items.inject(:+), :list => items.join(',') }
        end

        #------------------------------------------------------------------------------
        def access_last_30_days
          items = 27.step(0, -3).map do |date| 
            self.where('last_access_at <= ? AND last_access_at > ?', date.days.ago.to_datetime, (date + 3).days.ago.to_datetime).count
          end
          return { :total => items.inject(:+), :list => items.join(',') }
        end
        
      end
    end
  end
end

