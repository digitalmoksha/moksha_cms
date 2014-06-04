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
      return nil if params[:registration].nil? || params[:registration].empty?
      if current_user.try(:is_admin?)
        params.require(:registration).permit!
      else
        # TODO Make this work!! params.require(:registration).permit(:workshop_price_id, custom_fields_attributes: [:field_data, :custom_field_def_id])
        params.require(:registration).permit!
      end
    end

  end
end