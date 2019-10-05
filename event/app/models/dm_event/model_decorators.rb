# Decorate any models
# Chose to use this method for now, instead of creating a decorator folder and
# eager-loading it.  Prefer to keep the logic in the model folder.
#------------------------------------------------------------------------------

UserProfile.send(:include, DmEvent::Concerns::UserProfile) # rubocop:disable Lint/SendWithMixinArgument
Ability.send(:include, DmEvent::Concerns::Ability) # rubocop:disable Lint/SendWithMixinArgument
