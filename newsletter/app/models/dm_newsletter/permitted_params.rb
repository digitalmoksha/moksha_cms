module DmNewsletter
  module PermittedParams

    #------------------------------------------------------------------------------
    def newsletter_params
      params.require(:newsletter).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def standard_newsletter_params
      params.require(:standard_newsletter).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def mailchimp_newsletter_params
      params.require(:mailchimp_newsletter).permit! if current_user.try(:is_admin?)
    end

  end
end