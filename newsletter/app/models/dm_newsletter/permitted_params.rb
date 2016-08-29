module DmNewsletter
  module PermittedParams

    #------------------------------------------------------------------------------
    def newsletter_params
      params.require(:newsletter).permit! if can? :manage_newsletters, :all
    end

    #------------------------------------------------------------------------------
    def standard_newsletter_params
      params.require(:standard_newsletter).permit! if can? :manage_newsletters, :all
    end

    #------------------------------------------------------------------------------
    def mailchimp_newsletter_params
      params.require(:mailchimp_newsletter).permit! if can? :manage_newsletters, :all
    end

  end
end