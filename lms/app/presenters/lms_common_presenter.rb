# Define presentation-specific methods here. Helpers are accessed through
# `helpers` (aka `h`).
#
# This class is used to contain some common presenter functions
#------------------------------------------------------------------------------
class LmsCommonPresenter < BasePresenter
  presents  :model

  #------------------------------------------------------------------------------
  # Admin presenter methods

  #------------------------------------------------------------------------------
  def label_published
    model.published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end

  #------------------------------------------------------------------------------
  # Front-end presenter methods

  # Run content through a standard Textile/Liquid renderer
  #------------------------------------------------------------------------------
  def render_content(arguments = {})
    arguments.reverse_merge!(current_user.to_liquid) if current_user
    DmLms.config.use_markdown ? liquidize_markdown(model.content, arguments) : liquidize_textile(model.content, arguments)
  end
end