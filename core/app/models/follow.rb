# we use the `partisan` gem (https://github.com/mirego/partisan) instead of the
# `acts_as_follower` gem (https://github.com/tcocca/acts_as_follower).
# Because `acts_as_follower` has not released a Rails 5 compatible gem
# (it's only on master).  `partisan` seems to work well at the moment
class Follow < ApplicationRecord
  acts_as_follow
end
