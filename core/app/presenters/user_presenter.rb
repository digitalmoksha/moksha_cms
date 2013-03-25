class UserPresenter < BasePresenter

  presents :user
  #delegate :username, to: :user

  #------------------------------------------------------------------------------
  def role_label
    user.is_admin? ? colored_label('Admin', :success) : (user.has_role?(:beta) ? colored_label('Beta', :warning) : (user.has_role?(:author) ? colored_label('Author', :info) : 'User' ))
  end
  
end