#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module DefinesCustomFields
      extend ActiveSupport::Concern

      included do
        has_many :custom_field_defs, as: :owner, dependent: :destroy

        accepts_nested_attributes_for :custom_field_defs, allow_destroy: true
      end

      module ClassMethods
      end
    end
  end
end
