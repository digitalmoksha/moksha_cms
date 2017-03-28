class CmsBlogPresenter < BasePresenter

  presents :cms_blog

  #------------------------------------------------------------------------------
  def label_published
    cms_blog.is_published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end
  
  #------------------------------------------------------------------------------
  def visibility
    vis = cms_blog.visibility_to_s
    puts vis
    case vis
    when 'public'
      icon_label(:public, vis, icon_class: 'text-success')
    when 'protected'
      icon_label(:protected, vis, icon_class: 'text-warning')
    when 'private'
      icon_label(:private, vis, icon_class: 'text-danger')
    when 'subscription'
      icon_label(:subscriptions, vis)
    else
      vis
    end
  end
  
end