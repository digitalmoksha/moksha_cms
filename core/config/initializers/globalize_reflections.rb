# [todo] is this patch still needed?
#
# This monkey patch fixes an issue where the "relfections" method was not defined.
# Globalize 4.0.2 fixes this, but at this moment, there is another bug in 4.0.2
# that requires me to use 4.0.1 instead.  Once the bug in 4.0.2 is fixed, 
# then we should be able to remove this patch.  Test by making sure
# a CmsPage with translations can be saved...
# https://github.com/globalize/globalize/issues/357
# [todo]
#------------------------------------------------------------------------------
# module Globalize
#   module ActiveRecord
#     class Adapter
#       protected
#
#       def ensure_foreign_key_for(translation)
#         # Sometimes the translation is initialised before a foreign key can be set.
#         translation[translation.class.reflections[:globalized_model].foreign_key] = record.id
#       end
#     end
#   end
# end