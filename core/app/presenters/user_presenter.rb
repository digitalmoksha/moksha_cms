class UserPresenter < BasePresenter

  presents :user
  #delegate :username, to: :user

end