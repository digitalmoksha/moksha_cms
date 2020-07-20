# Decorate any models
# Chose to use this method for now, instead of creating a decorator folder and
# eager-loading it.  Prefer to keep the logic in the model folder.
#------------------------------------------------------------------------------
module DmCms
  module ModelDecorators
    Ability.include DmCms::Concerns::Ability
  end
end
