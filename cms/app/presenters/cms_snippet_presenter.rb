class CmsSnippetPresenter < BasePresenter
  presents :cms_snippet

  #------------------------------------------------------------------------------
  def label_published
    cms_snippet.is_published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end
end
