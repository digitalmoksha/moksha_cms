# Define presentation-specific methods here. Helpers are accessed through
# `helpers` (aka `h`).
#------------------------------------------------------------------------------
class ForumPresenter < ForumCommonPresenter
  presents :forum
  
  #------------------------------------------------------------------------------
  def visibility
    forum.is_private? ? 'private' : (forum.is_protected? ? 'protected' : 'public')
  end
  
  # #delegate :something, to: :course
  # 
end