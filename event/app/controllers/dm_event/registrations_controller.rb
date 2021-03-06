ActionView::Base.include OffsitePayments::ActionViewHelper

class DmEvent::RegistrationsController < DmEvent::ApplicationController
  include DmEvent::PermittedParams
  include OffsitePayments::Integrations
  include DmCore::UrlHelper
  include DmCore::LiquidHelper
  include DmCore::RecaptchaHelper

  protect_from_forgery except: [:paypal_ipn, :sofort_ipn], prepend: true

  helper          DmEvent::WorkshopsHelper
  helper          DmEvent::RegistrationsHelper
  layout          'layouts/event_templates/register'

  before_action   :workshop_lookup,          only: [:new, :create]
  before_action   :registration_uuid_lookup, only: [:choose_payment, :success]

  #------------------------------------------------------------------------------
  def new
    redirect_to(main_app.root_url) && return if @workshop.nil?

    if @workshop.visible? || can?(:manage_events, @workshop)
      @registration               = @workshop.registrations.build
      @registration.user_profile  = current_user ? current_user.user_profile : UserProfile.new

      if @workshop.require_address && !@registration.user_profile.address_valid?
        #--- address is required and there are missing fields in the profile
        @registration.user_profile.address_required = true
      end
      @registration.user_profile.userless_registration = true if current_user.nil? && !@workshop.require_account

      set_meta description: @workshop.summary, "og:description" => sanitize_text(markdown(@workshop.summary, safe: false))
      set_meta "og:image" => site_asset_media_url(@workshop.image) if @workshop.image.present?
    else
      render action: :closed
    end
  end

  #------------------------------------------------------------------------------
  def create
    redirect_to(action: :new) && return if user_needs_to_be_logged_in?
    redirect_to(action: :new) && return if current_user.nil? && !captcha_solved?

    profile_params = params[:registration].delete("user_profile_attributes") if params[:registration]
    profile_params&.delete(:id)

    @registration                   = @workshop.registrations.new(registration_params(@workshop))
    @registration.registered_locale = I18n.locale
    @registration.user_profile      = current_user ? current_user.user_profile : UserProfile.new
    @registration.user_profile.assign_attributes(user_profile_direct_params(profile_params)) unless profile_params.blank?

    if @registration.save
      if @workshop.payments_enabled? && !@workshop.require_review? && @registration.balance_owed.positive?
        redirect_to register_choose_payment_url(@registration.uuid)
      else
        redirect_to register_success_url(@registration.uuid)
      end
    else
      render action: :new
    end
  end

  # Only allow to proceed with payment if the registration is still in pending
  #------------------------------------------------------------------------------
  def choose_payment
    redirect_to(main_app.root_url) && return if @registration.nil?
    raise Account::LoginRequired, I18n.t('core.login_required') if user_needs_to_be_logged_in?

    if @workshop.require_account
      if @registration.user_profile.user != current_user && !is_admin?
        Rails.logger.error("=====> Error: Attempt to view payment page by user: <#{current_user&.email}>  for uuid: <#{params[:uuid]}>")

        redirect_to(main_app.root_url) && return
      end
    end

    render(:payment_complete)      && return if @registration.balance_owed.zero?
    render(:registration_status)   && return if @registration.pending?
    render(:registration_status)   && return if @registration.reviewing?
    render(:registration_status)   && return if @registration.rejected?
    render(:registration_status)   && return if @registration.waitlisted?
    render(:registration_status)   && return if @registration.canceled?
    render(:registration_status)   && return if @registration.refunded?
    redirect_to(main_app.root_url) && return unless @registration.accepted?
  end

  # Success page for a registration.  Look up the uuid and display success.
  # Can do this many times - if the user doesn't own the registration, then kick
  # them out.
  #------------------------------------------------------------------------------
  def success
    if @registration.nil? || @registration.user_profile.user != current_user
      Rails.logger.error("=====> Error: Attempt to view payment success page by user: <#{current_user&.email}>  for uuid: <#{params[:uuid]}>")

      redirect_to(main_app.root_url) && return
    end

    @receipt_content = @registration.email_state_notification(@registration.current_state, false) || ""
  end

  private

  #------------------------------------------------------------------------------
  def workshop_lookup
    @workshop = Workshop.find_by_slug(params[:id])
  end

  #------------------------------------------------------------------------------
  def registration_uuid_lookup
    @registration = Registration.find_by_uuid(params[:uuid])
    return unless @registration

    @workshop = @registration.workshop
  end

  #------------------------------------------------------------------------------
  def user_needs_to_be_logged_in?
    @workshop&.require_account && current_user.nil?
  end
end

#   helper          'dm_event/event_registrations'
#   helper          'dm_event/custom_fields'
#
#   before_action   :login_required, :only => [:show_registrations]
#   before_action   :ssl_required
#
#   layout          :use_layout
#
#   # TODO GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#   #verify :method => :post, :only => [ :confirm, :verify_payment ],
#   #       :redirect_to => { :action => :index }
#
# private
#   #------------------------------------------------------------------------------
#   def use_layout
#     "#{account_layouts}/#{Hanuman::Application.config.event_registration_layout}"
#   end
#
# public
#   #-----------------------------------------------------------------------
#   def index
#     #--- clear out any session data for this registration
#     session[:event_registration] = nil
#     redirect_to '/'
#   end
#
#   # :id => the workshop id we're registering for
#   #-----------------------------------------------------------------------
#   def register
#     redirect_to :action => 'index' and return if params[:id] == nil
#     @workshop = EventWorkshop.find_by_id(params[:id])
#     redirect_to :action => 'index' and return if @workshop == nil
#     redirect_to :action => 'index' and return unless @workshop.valid_invitation?(params[:code])
#
#     #--- allow an admin to see registration form
#     if !@workshop.workshop_closed or permit?("#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Admin} on Event or #{SystemRoles::Admin} on Student or #{SystemRoles::System}")
#       if @workshop.require_account
#         unless logged_in?
#           flash[:special_message] = nls(:event_require_account, :title => @workshop.title, :link => register_account_url)
#           login_required
#           return
#         end
#       end
#
#       #--- if we're an admin, then you can register another student for this event, using information from a previous registration
#       if !params[:r_id].blank? and permit?("#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Admin} on Event or #{SystemRoles::Admin} on Student or #{SystemRoles::System}")
#         old_registration    = EventRegistration.find(params[:r_id])
#         @register_user      = old_registration.student.user
#         @event_registration = EventRegistration.new_registration_from_old(@workshop.id, old_registration)
#       elsif  !params[:s_id].blank? and permit?("#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Admin} on Event or #{SystemRoles::Admin} on Student or #{SystemRoles::System}")
#         @register_user      = Student.find(params[:s_id]).user
#         @event_registration = EventRegistration.new(:event_workshop_id => @workshop.id, :country_id => @workshop.country_id)
#       else
#         @register_user      = current_user
#         @event_registration = EventRegistration.new(:event_workshop_id => @workshop.id, :country_id => @workshop.country_id)
#       end
#
#       @use_login_info       = @workshop.require_account || (!@register_user.nil? && !params['no_login'])
#
#       unless put_or_post?
#         #--- build up the custom field objects
#         @workshop.custom_field_defs.each do |c|
#           @event_registration.custom_fields.build(:custom_field_def_id => c.id)
#         end
#       else
#         #--- TODO security problem - shouldn't do the following assignment blindly
#        @event_registration.attributes  = params[:event_registration] unless params[:event_registration].nil?
#
#         #--- tie registration to student if they are logged in
#         @event_registration.student_id  = @register_user.student_id if @use_login_info
#
#         @photo = ((params[:photo].nil? || params[:photo][:image].blank?) ? nil : EventRegistrationPhoto.new(params[:photo]))
#         if @event_registration.valid? && (@photo.nil? || @photo.valid?)
#
#           if @event_registration.save && (@photo.nil? || @photo.save)
#             @event_registration.photo = @photo unless @photo.nil?
#             @event_registration.update_attribute(:item_code,  @event_registration.event_payment.shoppingcart_code) unless (@event_registration.event_payment.nil? || @event_registration.event_payment.shoppingcart_code.blank?)
#
#             unless params[:newsletters].nil?
#               #--- they asked to be notified of news, sign them up for the newletter
#               params[:newsletters].each do |idtag|
#                 #--- we don't really care about the return code ---
#                 rc = Newsletter.add_subscriber( idtag, !@use_login_info ? @event_registration : @event_registration.student,
#                                                 :remote_ip => request.remote_ip,
#                                                 :subscriber_id => !@use_login_info ? nil : @event_registration.student.id)
#               end
#             end
#             session[:event_registration] = @event_registration.id
#
#             #--- if shopping cart payment required, add redirect to the link that adds
#             #--- the items to the cart.  Receipt is emailed after we get confirmation back
#             #--- from shopping cart that payment was made.
#             if (  !@event_registration.event_payment.nil? and
#                   @event_registration.event_payment.payment_type == 'cc' and
#                   !@event_registration.item_code.blank?)
#               redirect_to generate_shoppingcart_link(@event_registration) and return
#             else
#               redirect_to :action => 'success' and return
#             end
#           end
#         end
#       end
#     end
#
#     #--- use the overriden template if specified, otherwise the default register.rhtml is used
#     @workshop.template.blank? ? render(:action => :register) : render(:action => :register, :layout => "#{account_layouts}/#{@workshop.template}")
#   end
#
#   #-----------------------------------------------------------------------
#   def success
#     unless session[:event_registration] == nil
#       @event_registration = EventRegistration.find_by_id(session[:event_registration])
#
#       #--- clear out the session information
#       session[:event_registration] = nil
#       @content = (@event_registration.compile_receipt)[:content]
#     else
#       #--- somehow sesssion got lost - back to the beginning
#       redirect_to :action => 'index'
#     end
#   end
#
#   # Clears the session of any information that might be there, and returns
#   # user to event information page.
#   #-----------------------------------------------------------------------
#   def user_cancel
#     @workshop = EventWorkshop.find_by_id(params[:workshop])
#     @workshop.nil? ? redirect_to('/') : redirect_to(@workshop.eventinfo_url)
#   end
#
#   #------------------------------------------------------------------------------
#   def show_registrations
#     @student = current_user.student
#
#     render :layout => "#{account_layouts}/members_backend"
#   end
#
#   #------------------------------------------------------------------------------
#   def select_registration
#   end
#
#   #------------------------------------------------------------------------------
#   def goto_shopping_cart
#     event_registration = EventRegistration.find(params[:id])
#     redirect_to generate_shoppingcart_link(event_registration) and return
#   end
#
#   #------------------------------------------------------------------------------
#   def update_registration
#     redirect_to :action => 'index' and return if params[:id] == nil
#     @event_registration = EventRegistration.find_by_token(params[:id])
#     if @event_registration.nil?
#       flash[:error] = 'This registration is not valid.'
#       redirect_to :action => :show_registrations and return
#     end
#
#     @workshop           = @event_registration.event_workshop
#     unless @workshop.workshop_closed
#       if @workshop.require_account
#         flash[:warning] = 'Please login to your student account before registering' and return unless login_required
#       end
#       @use_login_info     = @workshop.require_account || (user_signed_in? && !params['no_login'])
#
#       if put_or_post? && @event_registration.updates_allowed?
#         @event_registration.errors.add(:base, 'Please fill in the form') and return if params[:event_registration].nil?
#
#         #--- TODO security problem - shouldn't do the following assignment blindly
#         @event_registration.attributes              = params[:event_registration]
#         @event_registration.user_updated_at         = Time.new
#         @event_registration.confirmed_on            = Time.new if params[:confirm]
#
#         @photo = ((params[:photo].nil? || params[:photo][:image].blank?) ? nil : EventRegistrationPhoto.new(params[:photo]))
#         if @event_registration.valid? && (@photo.nil? || @photo.valid?) && !@event_registration.custom_field_errors?
#
#           if @event_registration.save && (@photo.nil? || @photo.save)
#             @event_registration.photo = @photo unless @photo.nil?
#
#             #flash[:notice] = "Registration Updated Successfully"
#             redirect_to :action => :update_successful, :id => @event_registration.token and return
#           end
#         end
#       else
#         #--- build up the custom field objects
#         @workshop.custom_field_defs.each do |c|
#           @event_registration.custom_fields.build(:custom_field_def_id => c.id) unless @event_registration.custom_fields.detect { |f| f.custom_field_def_id == c.id }
#         end
#       end
#     end
#
#     #--- use the overriden template if specified, otherwise the default register.rhtml is used
#     render :layout => "#{account_layouts}/#{@workshop.template}" unless @workshop.template.blank?
#   end
#
#   #------------------------------------------------------------------------------
#   def update_successful
#     @event_registration = EventRegistration.find_by_token(params[:id])
#     if @event_registration.nil?
#       flash[:error] = 'This registration is not valid.'
#       redirect_to :action => :show_registrations and return
#     end
#     @workshop           = @event_registration.event_workshop
#   end
#
#   #------------------------------------------------------------------------------
#   def registration_comments
#     if params[:id].nil? || (@event_registration  = EventRegistration.find_by_token(params[:id])).nil?
#       flash[:error] = 'This registration is not valid.'
#       redirect_to :action => :show_registrations and return
#     end
#
#     @workshop = @event_registration.event_workshop
#     if @workshop.workshop_closed
#       flash[:error] = 'This workshop is closed.'
#       redirect_to :action => :show_registrations and return
#     end
#   end
#
#   #------------------------------------------------------------------------------
#   def add_comment
#     if params[:id].nil? || (@event_registration  = EventRegistration.find_by_token(params[:id])).nil? || @event_registration.event_workshop.workshop_closed || current_user.nil?
#       flash[:error] = 'This registration is not valid.'
#       redirect_to :action => :show_registrations and return
#     end
#     @comment = Comment.new(:comment => params[:comment], :user_id => current_user.id)
#     @event_registration.add_comment(@comment)
#
#     #--- give the object a chance to do something if necessary
#     @event_registration.comment_notify(@comment) if @event_registration.respond_to?(:comment_notify)
#     redirect_to :action => :registration_comments, :id => params[:id]
#   end
#
#   # Show the workshops information page
#   #------------------------------------------------------------------------------
#   def information_page
#     redirect_to :action => 'index' and return if params[:id].nil?
#     @event_registration = EventRegistration.find_by_token(params[:id])
#     redirect_to :action => 'index' and return if @event_registration.nil?
#     @workshop           = @event_registration.event_workshop
#
#     unless permit?("#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event)
#       if @workshop.require_account
#         if !user_signed_in? or (user_signed_in? && !@workshop.registered?(current_user.student)) or @workshop.information_text.blank?
#           redirect_to :action => :show_registrations and return
#         end
#       else
#         redirect_to :action => 'index' and return if @workshop.information_text.blank?
#         redirect_to :action => 'index' and return if @workshop.past?
#       end
#     end
#
#     #--- use the overriden template if specified, otherwise the default register.rhtml is used
#     @workshop.template.blank? ? render(:action => :information_page) : render(:action => :information_page, :layout => "#{account_layouts}/#{@workshop.template}")
#   end
#
#   # Show the workshops information page
#   #------------------------------------------------------------------------------
#   def event_information_page
#     redirect_to :action => 'index' and return if params[:id].nil?
#     @workshop = EventWorkshop.find_by_id(params[:id])
#     redirect_to :action => 'index' and return if @workshop.nil? or @workshop.past?
#
#     #--- use the overriden template if specified, otherwise the default register.rhtml is used
#     @workshop.template.blank? ? render(:action => :event_information_page) : render(:action => :event_information_page, :layout => "#{account_layouts}/#{@workshop.template}")
#   end
#
