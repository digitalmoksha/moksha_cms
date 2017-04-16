class User < ApplicationRecord

  #--- DmCore already has default devise fields/tokens
  include DmCore::Concerns::User

end
