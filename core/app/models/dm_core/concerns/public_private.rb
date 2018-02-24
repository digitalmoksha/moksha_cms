# Implementation for public/protected/private and membership objects.
# "public"        means it is available for everyone to see, login not required
# "protected"     means it is available to anyone that is logged in
# "private"       means it is hidden unless you are an explicit member of the object
# "subscription"  means a paid subscription is required
#
# needs these in the table:
#  is_public: boolean
#  requires_login: boolean
#  requires_subscription: boolean
#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module PublicPrivate
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be
      # executed in the module's context (blorgh/concerns/models/post).
      included do
        scope :all_public,      -> { where(is_public: true) } # includes public and protected
        scope :by_public,       -> { where(is_public: true, requires_login: false) }
        scope :by_protected,    -> { where(is_public: true, requires_login: true) }
        scope :all_private,     -> { where(is_public: false) } # includes private and subscription
        scope :by_private,      -> { where(is_public: false, requires_subscription: false) }
        scope :by_subscription, -> { where(requires_subscription: true) }

        # check if public (does not require login)
        #------------------------------------------------------------------------------
        def is_public?
          is_public == true && requires_login == false
        end

        # check if protected (public and requires login)
        #------------------------------------------------------------------------------
        def is_protected?
          is_public == true && requires_login == true
        end

        # check if private (not public and does not require login, or requires a subscription)
        # we consider a requires subscription as private in this context
        #------------------------------------------------------------------------------
        def is_private?
          is_public == false || (is_public == false && requires_subscription == true)
        end

        #------------------------------------------------------------------------------
        def is_subscription_only?
          requires_subscription == true
        end

        #------------------------------------------------------------------------------
        def visibility_to_s
          is_public? ? 'public' : is_subscription_only? ? 'subscription' : is_private? ? 'private' : 'protected'
        end

        # add user as a member. duplicates are not added automatically
        #------------------------------------------------------------------------------
        def add_member(user)
          user.add_role(:member, self)
        end

        #------------------------------------------------------------------------------
        def remove_member(user)
          user.remove_role(:member, self)
        end

        # Is the user a member of this object?
        #------------------------------------------------------------------------------
        def member?(user)
          user.has_role?(:member, self) || self.owner.try('member?', user)
        end

        #------------------------------------------------------------------------------
        def member_count(which_ones = :all)
          case which_ones
          when :manual
            ::User.with_role(:member, self).count
          when :automatic
            if is_subscription_only?
              ::User.paid_subscribers.count
            else
              self.owner ? self.owner.member_count : 0
            end
          when :all
            member_count(:manual) + member_count(:automatic)
          end
        end

        # Return a list of users that have access
        #------------------------------------------------------------------------------
        def member_list(which_ones = :all)
          case which_ones
          when :manual
            ::User.with_role(:member, self).includes(user_profile: [:country]).sort_by { |u| u.full_name.downcase }
          when :automatic
            if is_subscription_only?
              ::User.paid_subscribers
            else
              self.owner ? self.owner.member_list : []
            end
          when :all
            member_list(:manual) + member_list(:automatic)
          end
        end

        # Can this object be read by a user
        #------------------------------------------------------------------------------
        def can_be_read_by?(attempting_user)
          if attempting_user
            self.published? && (self.is_public? || self.is_protected? || self.member?(attempting_user) || attempting_user.is_admin? ||
                  (self.is_subscription_only? && attempting_user.is_paid_subscriber?) )
          else
            self.published? && self.is_public?
          end
        end

        # Can this object be replied to by user
        #------------------------------------------------------------------------------
        def can_be_replied_by?(attempting_user)
          if attempting_user
            self.published? && (self.is_public? || self.is_protected? || self.member?(attempting_user) || attempting_user.is_admin? ||
                  (self.is_subscription_only? && attempting_user.is_paid_subscriber?) )
          else
            false # must be logged in to make a reply
          end
        end
      end

      module ClassMethods
        # Get list of available objects for user
        #------------------------------------------------------------------------------
        def available_to_user(user)
          include_translations = self.method_defined?(:translations)
          if user.nil?
            #--- not logged in, only public
            objects = self.by_public.published
            objects = objects.includes(:translations) if include_translations
          elsif user.is_admin?
            objects = self.all
            objects = objects.includes(:translations) if include_translations
          else
            #--- all public/protected, as well as private that they are a member and subscriptions
            public_objs     = self.all_public.published
            private_objs    = self.by_private.published
            subscribed_objs = self.by_subscription.published if user.is_paid_subscriber?
            if include_translations
              public_objs     = public_objs.includes(:translations)
              private_objs    = private_objs.includes(:translations)
              subscribed_objs = subscribed_objs.includes(:translations) if user.is_paid_subscriber?
            end
            objects  = public_objs
            objects += private_objs.with_role(:member, user)
            private_objs.where('owner_id IS NOT NULL').each do |item|
              objects << item if item.owner.member?(user)
            end
            objects += subscribed_objs if user.is_paid_subscriber?
          end
          return objects
        end
      end
    end
  end
end

