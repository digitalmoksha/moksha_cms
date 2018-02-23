#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module HasCustomFields
      extend ActiveSupport::Concern

      included do
        has_many :custom_fields, as: :owner, dependent: :destroy
        accepts_nested_attributes_for :custom_fields

        # Given an object that defines all the custom fields, builds any missing fields
        # onto the custom_fields association.
        #------------------------------------------------------------------------------
        def build_missing_fields(defining_object)
          existing_def_ids   = custom_fields.map(&:custom_field_def_id) # can't use pluck
          missing_field_defs = defining_object.custom_field_defs.reject {|x| existing_def_ids.include? x.id}
          missing_field_defs.each do |field_def|
            custom_fields.build(custom_field_def_id: field_def.id)
          end
        end
      end

      module ClassMethods
      end
    end
  end
end
