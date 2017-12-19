# Define presentation-specific methods here. Helpers are accessed through
# `helpers` (aka `h`).
#------------------------------------------------------------------------------
class ForumPresenter < ForumCommonPresenter
  presents :forum

  #------------------------------------------------------------------------------
  def visibility
    forum.visibility_to_s
  end

  # #delegate :something, to: :course
  #
end