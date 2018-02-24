# Decorate any models
# Chose to use this method for now, instead of creating a decorator folder and
# eager-loading it.  Prefer to keep the logic in the model folder.
#------------------------------------------------------------------------------

Ability.send(:include, DmLms::Concerns::Ability)
