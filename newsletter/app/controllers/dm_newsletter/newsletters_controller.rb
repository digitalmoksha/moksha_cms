class DmNewsletter::NewslettersController < DmNewsletter::ApplicationController
  # Handle a newsletter signup.  By submitting using a Rails form
  # and then adding via the MailChimp API, it should cut out automated signups
  # from spam bots, because the authenticity token will be validated first.
  #------------------------------------------------------------------------------
  def subscribe_to_newsletter
    subscription_params = params['subscription'] || {}
    user_or_email       = current_user ? current_user : subscription_params['email']
    @newsletter         = Newsletter.find_newsletter(params['token'])

    if @newsletter
      result = @newsletter.subscribe(user_or_email, subscription_params, new_subscription: true)

      respond_to do |format|
        if result[:success]
          msg = I18n.t('nms.subscription_successful')
          format.html { redirect_back fallback_location: main_app.index_url, notice: msg }
          format.json { render json: { success: true, msg: msg } }
        else
          msg = I18n.t(@newsletter.map_error_to_msg(result[:code]))
          format.html { redirect_back fallback_location: main_app.index_url, alert: msg }
          format.json { render json: { success: false, msg: msg } }
        end
      end
    end
  end

  # Unsubscribe current user from newsletter.  We only support direct unsubscribing
  # for a logged in user
  #------------------------------------------------------------------------------
  def unsubscribe_from_newsletter
    email       = current_user ? current_user.email : ''
    @newsletter = Newsletter.find_newsletter(params['token'])

    if @newsletter
      result = @newsletter.unsubscribe(email)
      respond_to do |format|
        if result
          msg = I18n.t('nms.unsubscribe_successuful')
          format.html { redirect_back fallback_location: main_app.index_url, notice: msg }
          format.json { render json: { success: true, msg: msg } }
        else
          msg = I18n.t('nms.Email_NotExists')
          format.html { redirect_back fallback_location: main_app.index_url, alert: msg }
          format.json { render json: { success: false, msg: msg } }
        end
      end
    end
  end
end
