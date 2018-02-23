# FriendlyID support methods
# In general,
# - extends FriendlyID
# - requires slug to be present
# - normalizes slug using Babosa gem.  Ensures normalized even if user inputed
# - indicates to generate a new slug if it's blank
#
# To use:
#   extend FriendlyId
#   include DmCore::Concerns::FriendlyId
#
#   def model_slug
#     send("title_#{Account.current.preferred_default_locale}")
#   end

#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module FriendlyId
      extend ActiveSupport::Concern

      included do
        friendly_id               :model_slug, use: :scoped, scope: :account_id
        validates_presence_of     :slug
        before_save               :normalize_slug

        # Override this to provide what the slug value should be based on
        #------------------------------------------------------------------------------
        def model_slug
          slug
        end

        # regenerate slug if it's blank
        #------------------------------------------------------------------------------
        def should_generate_new_friendly_id?
          self.slug.blank?
        end

        # If user set slug sepcifically, we need to make sure it's been normalized
        #------------------------------------------------------------------------------
        def normalize_slug
          self.slug = normalize_friendly_id(self.slug)
        end

        # use babosa gem (to_slug) to allow better handling of multi-language slugs
        #------------------------------------------------------------------------------
        def normalize_friendly_id(text)
          text.to_s.to_slug.normalize.to_s
        end
      end

      module ClassMethods
      end
    end
  end
end
