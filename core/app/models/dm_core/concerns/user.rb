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

        validates_presence_of     :email
        validates_email_format_of :email, :message => 'does seem to be valid'

        after_create            :add_account
        after_update            :update_profile_email

        delegate                :first_name, :last_name, :full_name, :display_name, :name, :country, :locale, :to => :user_profile
        delegate                :last_access_at, :to => :current_site_profile

        scope                   :current_account_users, -> { includes(:user_site_profiles, :user_profile, :current_site_profile).references(:user_site_profiles).where("user_site_profiles.account_id = #{Account.current.id}") }
        scope                   :online, -> { includes(:user_site_profiles).where('user_site_profiles.last_access_at >= ?', 10.minutes.ago.utc) }
        scope                   :confirmed, -> { where.not(confirmed_at: nil) }

        # In a few cases, we need to be able to check an ability where we only have a
        # passed in User object.  This allows that
        # https://github.com/ryanb/cancan/wiki/ability-for-other-users
        #------------------------------------------------------------------------------
        def ability
          @ability ||= ::Ability.new(self)
        end
        delegate :can?, :cannot?, :to => :ability

        # Keep the profile email in sync with the user's email
        #------------------------------------------------------------------------------
        def update_profile_email
          user_profile.update_attribute(:email, email) if email_changed?
        end

        # When a user is created, attach it to the current account
        #------------------------------------------------------------------------------
        def add_account
          skip_reconfirmation! # make sure a second confirmation email is not sent
          update_attribute(:account_id, Account.current.id)
          ensure_site_profile_exists
        end

        #------------------------------------------------------------------------------
        def ensure_site_profile_exists
          if current_site_profile.nil?
            user_site_profiles.create.update_attribute(:account_id, Account.current.id)
            reload
          end
        end

        # Determine if this user has the Admin role
        #------------------------------------------------------------------------------
        def is_admin?
          @is_admin.nil? ? (@is_admin = (has_role?(:admin) || is_sysadmin?)) : @is_admin
        end

        # Determine if this user has the sysadmin role.  It spans the entire system,
        # not limited to one account.
        #------------------------------------------------------------------------------
        def is_sysadmin?
          if @is_sysadmin.nil?
            sysadmin_role = Role.unscoped.find_by_name('sysadmin')
            @is_sysadmin = sysadmin_role.nil? ? false : !sysadmin_role.users.where('user_id = ?', id).empty?
          else
            @is_sysadmin
          end
        end

        # does the user have a paid subscription
        #------------------------------------------------------------------------------
        def is_paid_subscriber?
          has_role? :paid_subscription
        end

        # Given a hash of roles and whether they are enabled or not, add or remove them
        # Typically used by the UsersController when updating possible permissions
        #------------------------------------------------------------------------------
        def update_roles(new_roles, authorized_admin = false)
          new_roles.delete('admin') unless authorized_admin
          new_roles.each { |name, value| value.as_boolean ? add_role(name) : remove_role(name) }
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
                        'full_name'           => h(full_name),
                        'email'               => h(email),
                        'paid_subscription?'  => is_paid_subscriber? } }
        end

        #------------------------------------------------------------------------------
        def self.liquid_help
          [
            { name: 'user.full_name',
              summary: "User's full name",
              category: 'variables',
              example: '{{ user.full_name }}',
              description: "Display the user's full name" },
            { name: 'user.first_name',
              summary: "User's first name",
              category: 'variables',
              example: '{{ user.first_name }}',
              description: "Display the user's first name" },
            { name: 'user.last_name',
              summary: "User's last name",
              category: 'variables',
              example: '{{ user.last_name }}',
              description: "Display the user's last name" },
            { name: 'user.email',
              summary: "User's email address",
              category: 'variables',
              example: '{{ user.email }}',
              description: "Display the user's email address" }
          ]
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
        # List of Users who have :paid_subscription role
        #------------------------------------------------------------------------------
        def paid_subscribers
          with_role(:paid_subscription)
        end

        # Setup the columns for exporting data as csv.
        #------------------------------------------------------------------------------
        def csv_columns
          column_definitions = []
          column_definitions <<     ['Full Name',         'item.full_name', 100]
          column_definitions <<     ['Last Name',         'item.last_name.capitalize', 100]
          column_definitions <<     ['First Name',        'item.first_name.capitalize', 100]
          column_definitions <<     ['Email',             'item.email.downcase', 150]
          column_definitions <<     ['Address',           'item.user_profile.address', 150]
          column_definitions <<     ['Address2',          'item.user_profile.address2']
          column_definitions <<     ['City',              'item.user_profile.city.capitalize', 100]
          column_definitions <<     ['State',             'item.user_profile.state.capitalize']
          column_definitions <<     ['Zipcode',           'item.user_profile.zipcode']
          column_definitions <<     ['Country',           'item.user_profile.country.code']
          column_definitions <<     ['Confirmed on',      'item.confirmed_at.to_date', 75, { type: 'DateTime', numberformat: 'd mmm, yyyy' }]

          column_definitions
        end
      end
    end
  end
end
