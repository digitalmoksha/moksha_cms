# Implementation for public/protected/private objects.
# "public"        means it is available for everyone to see, login not required
# "protected"     means it is available to anyone that is logged in
# "private"       means it is hidden unless you are an explicit member of the object
# "subscription"  means a paid subscription is required
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

        # Is the user a member of this object?
        #------------------------------------------------------------------------------
        def member?(user)
          user.has_role? :member, self
        end

        #------------------------------------------------------------------------------
        def member_list
          users = []
          roles.each do |role|
            users += role.users
          end
          return users.sort_by {|u| u.full_name.downcase}
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
            # must be logged in to make a reply
            false
          end
        end
      end

      module ClassMethods

        # Get list of available objects for user
        #------------------------------------------------------------------------------
        def available_to_user(user)
          if user.nil?
            #--- not logged in, only public
            objects = self.by_public.published
          elsif user.is_admin?
            objects = self.all
          else
            #--- all public/protected, as well as private that they are a member and subscriptions
            objects  = self.all_public.published
            objects += self.by_private.published.with_role(:member, user)
            objects += self.by_subscription.published if user.is_paid_subscriber?
            return objects
          end
        end
        
      end
    end
  end
end

