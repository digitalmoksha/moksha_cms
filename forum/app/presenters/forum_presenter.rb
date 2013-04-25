# Define presentation-specific methods here. Helpers are accessed through
# `helpers` (aka `h`).
#------------------------------------------------------------------------------
class ForumPresenter < ForumCommonPresenter
  presents :forum
  
  def type_of_forum
    forum.is_private? ? 'private' : (forum.is_protected? ? 'protected' : 'public')
  end
  
  # #delegate :something, to: :course
  # 
  # #------------------------------------------------------------------------------
  # def label_published
  #   if course.teaser_only? 
  #     h.colored_label('Teaser', :info)
  #   else
  #     course.published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  #   end
  # end
  # 
  # #------------------------------------------------------------------------------
  # def icon
  #   'font-book'
  # end

end