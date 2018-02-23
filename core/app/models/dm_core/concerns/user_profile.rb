module DmCore
  module Concerns
    module UserProfile
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be
      # executed in the module's context (blorgh/concerns/models/post).
      included do
        #--- for when a service (like event registration), needs to require a valid address
        #    can be set by the service to enable the validations
        attr_accessor           :address_required
        attr_accessor           :userless_registration

        belongs_to              :user
        belongs_to              :country, :class_name => 'DmCore::Country'

        #--- don't validate public_name if we're only updating the address
        #    (like with userless registration)
        validates_presence_of   :public_name,        :if => Proc.new { |p| !p.userless_registration }
        validates_uniqueness_of :public_name,        :case_sensitive => false, :if => Proc.new { |p| !p.userless_registration }

        #--- validates used for a registration that is not associated with a student account
        validates_presence_of   :first_name,        :if => :require_name?
        validates_presence_of   :last_name,         :if => :require_name?
        validates_presence_of   :country_id,        :if => :require_country?
        validates_presence_of   :email,             :if => Proc.new { |p| p.address_required }
        validates_presence_of   :address,           :if => Proc.new { |p| p.address_required }
        validates_presence_of   :city,              :if => Proc.new { |p| p.address_required }
        validates_presence_of   :zipcode,           :if => Proc.new { |p| p.address_required }

        validates_length_of     :address,           :maximum => 70
        validates_length_of     :address2,          :maximum => 70
        validates_length_of     :city,              :maximum => 20
        validates_length_of     :state,             :maximum => 30
        validates_length_of     :zipcode,           :maximum => 10
        validates_length_of     :phone,             :maximum => 20
        validates_length_of     :fax,               :maximum => 20
        validates_length_of     :cell,              :maximum => 20

        after_create            :add_account

        # Avatars
        # => public_avatar is for use in forums, blog comments, etc.
        # => private_avatar is for use in special events where building a group
        #    is important.
        # => use_private_avatar_for_public is currently NOT used
        #------------------------------------------------------------------------------
        mount_uploader          :public_avatar,  AvatarUploader
        mount_uploader          :private_avatar, AvatarUploader

        #------------------------------------------------------------------------------
        def address_required=(value)
          @address_required = (value == true || value.as_boolean)
        end

        #------------------------------------------------------------------------------
        def userless_registration=(value)
          @userless_registration = (value == true || value.as_boolean)
        end

        # When a profile is created, attach it to the current account
        #------------------------------------------------------------------------------
        def add_account
          self.update_attribute(:account_id, Account.current.id)
        end

        #------------------------------------------------------------------------------
        def full_name
          I18n.t('core.profile_full_name', firstname: first_name.to_s, lastname: last_name.to_s)
        end
        alias :name :full_name

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

        # Check if the address fields are filled in.  Useful for determining if the
        # fields need to be dislpayed to be filled in or not.
        #------------------------------------------------------------------------------
        def address_valid?
          not_valid = email.blank? || first_name.blank? || last_name.blank? || address.blank? || city.blank? ||
            zipcode.blank? || country.blank?
          return !not_valid
        end

        # Returns the users preferred locale, which could be different from what the site
        # supports
        #------------------------------------------------------------------------------
        def locale
          self.favored_locale
        end
      end
    end
  end
end

