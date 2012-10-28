module DmCore
  module Concerns
    module Models
      module User
        extend ActiveSupport::Concern
 
        # 'included do' causes the included code to be evaluated in the
        # conext where it is included (post.rb), rather than be 
        # executed in the module's context (blorgh/concerns/models/post).
        included do
          # Include default devise modules. Others available are:
          # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
          devise :database_authenticatable, :registerable, :confirmable,
                 :recoverable, :rememberable, :trackable, :validatable

          # Setup accessible (or protected) attributes for your model
          attr_accessible :email, :password, :password_confirmation, :remember_me,
                          :first_name, :last_name, :country_id

          belongs_to              :country, :class_name => 'DmCore::Country'

          validates_presence_of   :first_name
          validates_presence_of   :last_name
          validates_presence_of   :country_id
          validates_presence_of   :email

          #------------------------------------------------------------------------------
          def display_name
            self.first_name.to_s + " " + self.last_name.to_s
          end
        end
 
        module ClassMethods
          #def some_class_method
          #  'some class method string'
          #end
        end
      end
    end
  end
end

