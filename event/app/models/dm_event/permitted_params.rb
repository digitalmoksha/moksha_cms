module DmEvent
  module PermittedParams

    #------------------------------------------------------------------------------
    def workshop_params
      params.require(:workshop).permit! if can? :manage_events, :all
    end

    #------------------------------------------------------------------------------
    def workshop_price_params
      params.require(:workshop_price).permit! if can? :manage_events, :all
    end

    #------------------------------------------------------------------------------
    def registration_params
      return nil if params[:registration].nil? || params[:registration].empty?
      if can? :manage_events, :all
        params.require(:registration).permit!
      else
        # nested attributes: because field_data can be either a single value or an array of values,
        # we include it twice in the permit, once as a normal param, and again as a param with data.
        # sample data:
        #  {"workshop_price_id"=>"72", "custom_fields_attributes"=>{"0"=>{"field_data"=>"234", "custom_field_def_id"=>"8"}, 
        #    "1"=>{"field_data"=>["eee", ""], "custom_field_def_id"=>"16"}}}
        params.require(:registration).permit(:workshop_price_id, custom_fields_attributes: [:field_data, {:field_data => []}, :custom_field_def_id])
      end
    end

  end
end