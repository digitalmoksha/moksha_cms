class UserPresenter < BasePresenter
  presents :user
  # delegate :username, to: :user

  #------------------------------------------------------------------------------
  def role_label
    if user.is_admin?
      colored_label('Admin', :success)
    elsif user.has_role?(:manager)
      colored_label('Manager', :info)
    elsif user.has_role?(:content_manager) || user.has_role?(:event_manager) || user.has_role?(:forum_manager)
      colored_label('Submanager', :warning)
    elsif user.has_role?(:reviewer)
      colored_label('Reviewer', :default)
    elsif user.has_role?(:beta)
      colored_label('Beta', :danger)
    else
      'User'
    end
  end

  #------------------------------------------------------------------------------
  def last_access
    user.last_access_at.nil? ? colored_label('n/a', :warning) : "#{time_ago_in_words(user.last_access_at)} ago"
  end

  # gives the public avatar for a user
  #------------------------------------------------------------------------------
  def avatar_for(size = 32, options = {})
    case
    when size.class == String && size.end_with?('%')
      avatar = user.user_profile.public_avatar_url(:sq200)
    when size <= 35
      avatar = user.user_profile.public_avatar_url(:sq35)
    when size <= 100
      avatar = user.user_profile.public_avatar_url(:sq100)
    when size <= 200
      avatar = user.user_profile.public_avatar_url(:sq200)
    else
      avatar = user.user_profile.public_avatar_url
    end
    image_tag(avatar, width: size, class: options[:class] ? options[:class] : 'image')
  end
end
