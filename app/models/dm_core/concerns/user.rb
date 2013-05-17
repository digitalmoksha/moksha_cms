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
                                  :user_profile_attributes
        attr_accessible         :role_ids, :email, :password, :password_confirmation, :remember_me,
                                  :user_profile, :user_profile_attributes,
                                  :as => :admin

        belongs_to              :country, :class_name => 'DmCore::Country'
        has_one                 :user_profile, :dependent => :destroy
        accepts_nested_attributes_for :user_profile
        
        validates_presence_of   :email

        after_create            :add_account
        # after_initialize        :initialize_profile
        
        delegate                :first_name, :last_name, :full_name, :display_name, :country, :last_access_at,
                                :to => :user_profile
        
        scope                   :online, lambda { where('last_access_at >= ?', 10.minutes.ago.utc) }
        

        # make sure a new profile is built for a new record
        #------------------------------------------------------------------------------
        def initialize_profile
          if new_record?
            self.build_user_profile
          end
        end
        
        # When a user is created, attach it to the current account
        #------------------------------------------------------------------------------
        def add_account
          self.skip_reconfirmation!  # make sure a second confirmation email is not sent
          self.update_attribute(:account_id, Account.current.id)
        end
        
        # Determine if this user has the Admin role
        #------------------------------------------------------------------------------
        def is_admin?
          has_role?(:admin)
        end
        
        #------------------------------------------------------------------------------
        def update_last_access
          user_profile.update_attribute(:last_access_at, Time.now.utc) if user_profile.last_access_at.nil? || (user_profile.last_access_at <= 10.minutes.ago)
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

        # Query for users that don't have a specific role.  Useful for getting users
        # are not :admin
        #------------------------------------------------------------------------------
        def without_role(role)
          self.where("id NOT IN (?)", self.with_role(role))
        end
      end
    end
  end
end

