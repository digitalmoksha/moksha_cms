# This holds a site profile for a user.  This is any data that is needed for
# a user, on a per site/account basis, such as site specific preferences, login times,
# etc.
#   Note: don't use a default account scope as it makes some of the User 
#   associations a little more difficult
#------------------------------------------------------------------------------
class UserSiteProfile < ApplicationRecord

  include DmCore::Concerns::UserSiteProfile

end
