class DmEvent::Admin::RegistrationsController < DmEvent::Admin::AdminController
  include DmEvent::PermittedParams
  helper  DmEvent::RegistrationsHelper

  before_action   :registration_lookup

  #------------------------------------------------------------------------------
  def action_state
    authorize! :manage_events, @workshop

    @state_event  = params[:state_event].downcase
    case @state_event
    # when 'verify payment'
    #   @registration.verify_payment
    # when 'archive', 'unarchive'
    #   @registration.toggle_archive
    # when 'confirm', 'unconfirm'
    #   @registration.toggle_confirm
    when 'take action'
      flash[:error] = "Please select an action to take"
    else
      #--- send to state machine if it's an allowed event
      @registration.send("#{@state_event}!") if @registration.aasm.events.include? @state_event.to_sym
    end

    respond_to do |format|
      format.html { redirect_to admin_workshop(@workshop) }
      format.js   { render action: :action_state }
    end

  rescue ActiveRecord::StaleObjectError
  end

  #------------------------------------------------------------------------------
  def destroy
    authorize! :manage_event_registrations, @workshop
    @registration.destroy
    redirect_to admin_workshop_url(@workshop), notice: 'Registration was successfully deleted.'
  end

  #------------------------------------------------------------------------------
  def edit
    authorize! :manage_event_registrations, @workshop
    @payment_histories = @registration.payment_histories.includes(:user_profile)
  end

  #------------------------------------------------------------------------------
  def update
    authorize! :manage_event_registrations, @workshop

    #--- save without validation, so can update without having to fill in all details
    payment_comment_text      = params[:registration].delete(:payment_comment_text)
    @registration.attributes  = registration_params(@workshop)

    if @registration.save(validate: false)
      if @registration.payment_comment.nil? && payment_comment_text
        #--- save the payment text as a comment, and keep a pointer to it
        payment_comment = @registration.private_comments.create(body: payment_comment_text, user_id: current_user.id)
        @registration.reload.update_attribute(:payment_comment_id, payment_comment.id)
      end
      redirect_to edit_admin_registration_path(@registration), notice: 'Registration was successfully updated.'
    else
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to action: :edit, id: @registration, alert: 'Changes not saved - registration was modified by someone else'
  end

  #------------------------------------------------------------------------------
  def send_payment_reminder
    authorize! :manage_event_registrations, @workshop
    status  = PaymentReminderService.send_reminder(@registration)
    status ? (flash[:notice] = 'Reminder sent') : (flash[:warning] = 'Reminder failed sending')
    redirect_to action: :edit, id: @registration
  end

  # Record a new payment for the event
  #------------------------------------------------------------------------------
  def ajax_payment
    authorize! :manage_event_registrations, @workshop

    previous_payment  = params[:payment_id] ? PaymentHistory.find(params[:payment_id]) : nil
    @payment_history  = @registration.manual_payment(previous_payment,
                              params[:payment_history][:cost],
                              params[:payment_history][:total_currency],
                              current_user.user_profile,
                              item_ref: params[:payment_history][:item_ref],
                              payment_method: params[:payment_history][:payment_method],
                              bill_to_name: params[:payment_history][:bill_to_name],
                              payment_date: params[:payment_history][:payment_date]
                        )

    if @payment_history.errors.empty?
      @registration.update_attribute(:receipt_requested, params[:payment_history][:receipt_requested])
    end

    respond_to do |format|
      format.html {
        flash[:notice] = "Payment was successfully added"           if @payment_history.errors.empty?
        flash[:alert]  = "There was a problem adding this payment"  unless @payment_history.errors.empty?
        redirect_to edit_admin_registration_path(@registration)
      }
      format.js { render action: :ajax_payment }
    end
  end

  #------------------------------------------------------------------------------
  def ajax_delete_payment
    authorize! :manage_event_registrations, @workshop

    if @registration.delete_payment(params[:payment_id])
      redirect_to edit_admin_registration_path(@registration), notice: 'Payment was deleted'
    else
      redirect_to edit_admin_registration_path(@registration), error: 'Problem deleting payment'
    end
  end

private

  #------------------------------------------------------------------------------
  def registration_lookup
    @registration = Registration.find(params[:id])
    @workshop     = @registration.workshop
    if !can?(:manage_event_registrations, @workshop) && !can?(:manage_event_finances, @workshop)
      # limit to your own registration if can only edit the workshop
      @registration = nil if @registration.user_profile_id != current_user.user_profile.id
    end
  end

end
