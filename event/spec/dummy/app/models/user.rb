class User < ActiveRecord::Base

  #--- DmCore already has default devise fields/tokens
  include DmCore::Concerns::User

end
