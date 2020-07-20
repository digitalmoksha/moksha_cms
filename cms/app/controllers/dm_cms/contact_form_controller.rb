class DmCms::ContactFormController < DmCms::ApplicationController
  include DmCore::RecaptchaHelper

  rescue_from ActionController::InvalidAuthenticityToken, with: :form_spam

  protect_from_forgery with: :exception

  # Type of contact form object is specified by any param name that
  # ends with '_contact_form'.  For example,
  # 'theme_bogus_tech_contact_form' => ThemeBogus::TechContactForm
  #------------------------------------------------------------------------------
  def create
    form_key = params.keys.select { |k| k.end_with?('contact_form') }.first
    klass    = contact_form_class(form_key)
    @contact = klass.new(params[form_key])

    if @contact.valid? && captcha_solved? && @contact.deliver
      flash.delete :error
      flash.now[:notice] = I18n.t('cms.contact_form.sent')
      @contact = nil
    end

    @partial_name = klass::PARTIAL_NAME
  rescue NameError => e
    Rails.logger.error "=====> Error in creating ContactForm: #{e.message}  URL: #{request.url}  REMOTE_ADDR: #{request.remote_addr}"
    @contact = nil
    @partial_name = ContactForm.PARTIAL_NAME
  end

  # Determines the name of the form class.
  # In order to specificy a theme class, it must
  # - start with "theme_"
  # - theme name must be the second piece
  # - it must end in "_contact_form"
  #
  # For example,
  # 'theme_bogus_tech_contact_form' => ThemeBogus::TechContactForm
  #------------------------------------------------------------------------------
  def contact_form_class(form_key)
    return ContactForm unless form_key.present?
    return ContactForm unless form_key.start_with?('theme_')
    return ContactForm unless form_key.end_with?('_contact_form')

    parts       = form_key.split('_')
    theme_name  = parts[1]
    theme_class = parts[2..-3].join('_')

    "theme_#{theme_name}/#{theme_class}_contact_form".camelize.constantize
  end

  #------------------------------------------------------------------------------
  def form_spam(exception)
    Rails.logger.error "=====> Spam attempt ContactForm: #{exception.message}  URL: #{request.url}  REMOTE_ADDR: #{request.remote_addr}"
    head :bad_request
  end
end
