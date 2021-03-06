# https://medium.com/selleo/essential-rubyonrails-patterns-part-1-service-objects-1af9f9573ca1
# Including this module will allow you to simplify the UserCreator.new(params).call
# notation into UserCreator.call(params)
#------------------------------------------------------------------------------
module DmCore
  module ServiceSupport
    extend ActiveSupport::Concern
    class_methods do
      def call(*args)
        new(*args).call
      end
    end
  end
end
