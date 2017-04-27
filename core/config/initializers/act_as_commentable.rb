# Allows acts_as_commentable to work with Rails 5
module Juixe
  module Acts
    module Commentable
      module HelperMethods
        def define_role_based_inflection_5(role)
          has_many "#{role.to_s}_comments".to_sym, -> { where(role: role.to_s) }, has_many_options(role)
        end
      end
    end
  end
end