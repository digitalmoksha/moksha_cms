class DmNewsletter::NewslettersController < DmNewsletter::ApplicationController

  # Handle a newsletter signup.  By submitting using a Rails form
  # and then adding via the MailChimp API, it should cut out automated signups
  # from spam bots, because the authenticity token will be validated first
  #------------------------------------------------------------------------------
  def subscribe_to_newsletter
    subscription_params = params['subscription']
    user_or_email       = current_user ? current_user : subscription_params['email']
    @newsletter         = Newsletter.find_newsletter(subscription_params['token'])
    subscription_params.delete('token')
    
    respond_to do |format|
      result = @newsletter.subscribe(user_or_email, subscription_params)
      if result == true
        format.html { redirect_to (request.env['HTTP_REFERER'].blank? ? main_app.index_url : :back), notice: 'You have been subscribed' }
        format.js { render json: { success: true } }
      else
        format.html { redirect_to :back }
        format.js { render json: { success: false, msg: result.to_s } }
      end
    end
  end
end
