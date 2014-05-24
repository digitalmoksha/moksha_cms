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

        belongs_to              :country, :class_name => 'DmCore::Country'
        has_one                 :user_profile, :dependent => :destroy
        has_many                :user_site_profiles, :dependent => :destroy
        has_one                 :current_site_profile, -> { where(account_id: Account.current.id) }, class_name: 'UserSiteProfile'
        has_many                :comments, :dependent => :destroy

        #--- this allows us to use @user.voting.likes(@post) and it will be stored with the site specific user profile
        has_one                 :voting, -> { where(account_id: Account.current.id) }, class_name: 'UserSiteProfile'

        #--- this allows us to use @user.following.follow(@post) and it will be stored with the site specific user profile
        has_one                 :following, -> { where(account_id: Account.current.id) }, class_name: 'UserSiteProfile'

        accepts_nested_attributes_for :user_profile

        validates_presence_of   :email

        after_create            :add_account
        after_update            :update_profile_email

        delegate                :first_name, :last_name, :full_name, :display_name, :name, :country, :to => :user_profile
        delegate                :last_access_at, :to => :current_site_profile

        scope                   :current_account_users, -> { includes(:user_site_profiles).references(:user_site_profiles).where("user_site_profiles.account_id = #{Account.current.id}") }
        scope                   :online, -> { includes(:user_site_profiles).where('user_site_profiles.last_access_at >= ?', 10.minutes.ago.utc) }

        # Keep the profile email in sync with the user's email
        #------------------------------------------------------------------------------
        def update_profile_email
          user_profile.update_attribute(:email, email) if self.email_changed?
        end
        
        # When a user is created, attach it to the current account
        #------------------------------------------------------------------------------
        def add_account
          self.skip_reconfirmation!  # make sure a second confirmation email is not sent
          self.update_attribute(:account_id, Account.current.id)
          ensure_site_profile_exists
        end
        
        #------------------------------------------------------------------------------
        def ensure_site_profile_exists
          if current_site_profile.nil?
            user_site_profiles.create().update_attribute(:account_id, Account.current.id)
            self.reload
          end
        end
        
        # Determine if this user has the Admin role
        #------------------------------------------------------------------------------
        def is_admin?
          @is_admin ||= (has_role?(:admin) || is_sysadmin?)
        end
        
        # Determine if this user has the sysadmin role.  It spans the entire system,
        # not limited to one account.
        #------------------------------------------------------------------------------
        def is_sysadmin?
          @is_sysadmin ||= (self.roles.where(name: 'sysadmin', account_id: 0).size > 0)
        end
        
        # does the user have a paid subscription
        #------------------------------------------------------------------------------
        def is_paid_subscriber?
          has_role? :paid_subscription
        end
        
        #------------------------------------------------------------------------------
        def update_last_access
          ensure_site_profile_exists
          current_site_profile.update_attribute(:last_access_at, Time.now.utc) if current_site_profile.last_access_at.nil? || (current_site_profile.last_access_at <= 10.minutes.ago)
        end
        
        #------------------------------------------------------------------------------
        def to_liquid
          { 'user' => { 'first_name'          => h(first_name),
                        'last_name'           => h(last_name),
                        'paid_subscription?'  => is_paid_subscriber?
                      }
          }
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
