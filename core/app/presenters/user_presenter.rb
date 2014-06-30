class UserPresenter < BasePresenter

  presents :user
  #delegate :username, to: :user

  #------------------------------------------------------------------------------
  def role_label
    user.is_admin? ? colored_label('Admin', :success) : (user.has_role?(:beta) ? colored_label('Beta', :warning) : (user.has_role?(:author) ? colored_label('Author', :info) : 'User' ))
  end
  
  #------------------------------------------------------------------------------
  def last_access
    user.last_access_at.nil? ? colored_label('n/a', :warning) : "#{time_ago_in_words(user.last_access_at)} ago"
  end

  # gives the public avatar for a user
  #------------------------------------------------------------------------------
  def avatar_for(size = 32)
    case 
    when size <= 35
      avatar = user.user_profile.public_avatar_url(:sq35)
    when size <= 100
      avatar = user.user_profile.public_avatar_url(:sq100)
    when size <= 200
      avatar = user.user_profile.public_avatar_url(:sq200)
    else
      avatar = user.user_profile.public_avatar_url
    end
    # image_tag('dm_core/user.gif', width: size, height: size, class: 'image')
    image_tag(avatar, width: size, height: size, class: 'image')
  end

  
end
