# This fixes an issue where changing a translated field *and* a non-translated
# field at the same time caused the translated field in other locales to be
# replaced with the data of the changed translated field (it's previous data).
# Fix was outlined here: https://github.com/globalize/globalize/issues/117
# They say it is fixed in later versions, will have to try that later.
# For now, this is a critical fix.
#------------------------------------------------------------------------------
module PaperTrail
  module Model
    module InstanceMethods
      def initialize_copy(source)
        obj = super
        obj.tap { |o| o.send(:remove_instance_variable, :@globalize) } rescue obj
      end
    end
  end
end