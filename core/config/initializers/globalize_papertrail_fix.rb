# [todo] Now with PaperTrail 4, not sure if this fix is needed.
# Also, v4 recommends not using an initializer to modify PaperTrail (see changelog)
# Removed for now

# This fixes an issue where changing a translated field *and* a non-translated
# field at the same time caused the translated field in other locales to be
# replaced with the data of the changed translated field (it's previous data).
# Fix was outlined here: https://github.com/globalize/globalize/issues/117
# This has not been fixed as of the 3.0-stable release on Oct 24, 2013
#------------------------------------------------------------------------------
# module PaperTrail
#   module Model
#     module InstanceMethods
#       def initialize_copy(source)
#         obj = super
#         obj.tap { |o| o.send(:remove_instance_variable, :@globalize) } rescue obj
#       end
#     end
#   end
# end
