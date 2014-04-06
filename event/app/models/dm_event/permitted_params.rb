module DmEvent
  module PermittedParams

    #------------------------------------------------------------------------------
    def workshop_params
      params.require(:workshop).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def workshop_price_params
      params.require(:workshop_price).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def registration_params
      if current_user.try(:is_admin?)
        params.require(:registration).permit!
      else
        params.require(:registration).permit(:workshop_price_id)
      end
    end

  end
end