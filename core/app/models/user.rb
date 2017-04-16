# users, user_profiles, and user_site_profiles...
#
# User:
# There is one User per person/email address.  Email address is the primary key.
# A User is created for a specific account. However, that user can login to any
# of the hosted sites on this system, with the same user/pass.  In this way
# we can have a set of related sites, with single sign-on
#
# UserProfile:
# Only one per User, this contains all the profile information - name, address,
# public/private avatars.  This information is used across all sites.
#
# UserSiteProfile:
# A User has one of these for each site they have logged into.  Keeps track of 
# any site specific information, like the last_access_at field, etc.  Also 
# allows us to know if someone has ever logged into a specific site.
#------------------------------------------------------------------------------
class User < ApplicationRecord

  include DmCore::Concerns::User
  
end
