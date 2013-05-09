class CmsPostPresenter < BasePresenter

  presents :cms_post

  #------------------------------------------------------------------------------
  def label_published
    date_formatted = format_datetime(cms_post.published_on)
    cms_post.is_published? ? h.colored_label(date_formatted, :success) : h.colored_label(date_formatted)
  end
  
end