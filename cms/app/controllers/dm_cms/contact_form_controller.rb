class DmCms::ContactFormController < DmCms::ApplicationController
  # Type of contact form object is specified by any param name that
  # ends with '_contact_form'.  Also takes into account themes.
  # 'tech_contact_form' => TechContactForm
  # 'theme_bogus_tech_contact_form' => ThemeBogus::TechContactForm
  #------------------------------------------------------------------------------
  def create
    form_key = params.select {|key, v| key.end_with?('contact_form') }.first[0]
    if form_key.present?
      if form_key.start_with?('theme_')
        parts       = form_key.split('_')
        part_module = parts[0...2].join('_')
        part_class  = parts[2..-1].join('_')
        object      = "#{part_module}/#{part_class}".camelize.constantize
      else
        part_class  = form_key
        object      = "#{part_class}".camelize.constantize
      end
      @contact  = object.new(params[form_key])
      if @contact.deliver
        flash.now[:notice] = I18n.t('cms.contact_form.sent')
        @contact = nil
      end
    end
    @partial_name = "liquid_tags/#{part_class || 'contact_form'}"
  end
end
