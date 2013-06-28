# This holds the profile data for a user.  There is only one instance per user,
# so even when we're using users across sites, there is only one profile record
# per user record.
#------------------------------------------------------------------------------
class UserProfile < ActiveRecord::Base

  include DmCore::Concerns::UserProfile

end
