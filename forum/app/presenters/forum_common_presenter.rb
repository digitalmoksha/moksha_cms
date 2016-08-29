# Define presentation-specific methods here. Helpers are accessed through
# `helpers` (aka `h`).
#
# This class is used to contain some common presenter functions
#------------------------------------------------------------------------------
class ForumCommonPresenter < BasePresenter
  presents  :model
  
  #------------------------------------------------------------------------------
  # Admin presenter methods
  
  #------------------------------------------------------------------------------
  def label_published
    model.published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end
  
  # 
  # #------------------------------------------------------------------------------
  # # Front-end presenter methods
  # 
  # # Run content through a standard Textile/Liquid renderer
  # #------------------------------------------------------------------------------
  # def render_content(arguments = {})
  #   doc = RedCloth.new(Liquid::Template.parse(model.content).render(arguments, :filters => [LiquidFilters], 
  #                       :registers => {:controller => controller, :view => self, :account_site_assets => '/site_assets', :current_user => current_user}))
  #   #doc.hard_breaks = false
  # 
  #   return doc.to_html.html_safe
  # end
    
end