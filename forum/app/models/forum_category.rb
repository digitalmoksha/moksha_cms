class ForumCategory < Category

  has_many     :forums, :dependent => :destroy

end