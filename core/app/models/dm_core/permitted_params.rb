module DmCore
  module PermittedParams
    #------------------------------------------------------------------------------
    def account_params
      params.require(:account).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def user_params
      if can? :manage, :all
        params.require(:user).permit!
      else
        params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
      end
    end

    #------------------------------------------------------------------------------
    def user_profile_params
      if can? :manage, :all
        params.require(:user_profile).permit!
      else
        params.require(:user_profile).permit( :public_name, :first_name, :last_name, :public_avatar,
                       :address, :address2, :city, :state, :zipcode, :country_id)
      end
    end

    # used during a userless event registration
    #------------------------------------------------------------------------------
    def user_profile_direct_params(the_params)
      if can? :manage, :all
        the_params.permit!
      else
        the_params.permit( :public_name, :first_name, :last_name, :public_avatar,
                           :address, :address2, :city, :state, :zipcode, :country_id,
                           :userless_registration, :address_required, :email)
      end
    end

    #------------------------------------------------------------------------------
    def comment_params
      params.require(:comment).permit(:title, :body, :user_id)
    end

    #------------------------------------------------------------------------------
    def devise_sign_up_params(the_params)
      the_params.permit(:email, :password, :password_confirmation, :newsletter, :plan, :affiliate,
                        user_profile_attributes: [:public_name, :first_name, :last_name, :public_avatar,
                                                  :address, :address2, :city, :state, :zipcode, :country_id])
    end
  end
end