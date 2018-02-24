class ForumCategory < Category
  has_many :forums, :dependent => :destroy

  # Are any of the forums readable by this user? One positive is all need...
  #------------------------------------------------------------------------------
  def any_readable_forums?(user)
    if user && user.is_admin?
      true
    else
      forums.any? { |f| f.can_be_read_by?(user) }
    end
  end
end
