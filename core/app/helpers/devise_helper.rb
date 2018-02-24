module DeviseHelper
  # A simple way to show error messages for the current devise resource. If you need
  # to customize this method, you can either overwrite it in your application helpers or
  # copy the views to your application.
  #
  # This method is intended to stay simple and it is unlikely that we are going to change
  # it to add more behavior or options.
  #------------------------------------------------------------------------------
  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation" class=" alert alert-error">
      <p class="alert-heading"><strong>#{sentence}</strong></p>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  #------------------------------------------------------------------------------
  def devise_recaptcha
    return '' unless Rails.application.secrets[:recaptcha_site_key]

    error = flash[:recaptcha_error] ? "<span class='help-inline'>#{flash[:recaptcha_error]}</span>" : ''
    html  = <<-HTML
    <div class="form-horizontal control-group #{'error' if flash[:recaptcha_error]}">
      <div class="controls">
        #{recaptcha_tags(site_key: Rails.application.secrets[:recaptcha_site_key], hl: I18n.locale)}
        #{error}
      </div>
    </div>
    HTML

    html.html_safe
  end
end
