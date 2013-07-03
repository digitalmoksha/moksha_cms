class DmEvent::Admin::RegistrationsController < DmEvent::Admin::ApplicationController

  helper    DmEvent::RegistrationsHelper

  #------------------------------------------------------------------------------
  def action_state
    @registration = Registration.find(params[:id])
    @state_event  = params[:state_event].downcase
    case @state_event
    when 'delete'
      @registration.destroy
    when 'verify payment'
      @registration.verify_payment
    when 'archive', 'unarchive'
      @registration.toggle_archive
    when 'confirm', 'unconfirm'
      @registration.toggle_confirm
    when 'take action'
      flash[:error] = "Please select an action to take"
    else
      #--- send to state machine if it's an allowed event
      @registration.send("#{@state_event}!") if @registration.aasm.events.include? @state_event.to_sym
    end
  
    respond_to do |format|
      format.html { redirect_to admin_workshop(@registration.workshop) }
      format.js   { render :action => :action_state }
    end
  
  rescue ActiveRecord::StaleObjectError
  end

  #------------------------------------------------------------------------------
  def edit
    @registration = Registration.find(params[:id])
    @workshop     = @registration.workshop

    # #--- build up the custom field objects
    # @workshop.custom_field_defs.each do |c|
    #   @event_registration.custom_fields.build(:custom_field_def_id => c.id) unless @event_registration.custom_fields.detect { |f| f.custom_field_def_id == c.id }
    # end
  end

  #------------------------------------------------------------------------------
  def update
    @registration = Registration.find(params[:id])
    @workshop     = @registration.workshop

    #--- save without validation, so can update without having to fill in all details
    @registration.attributes = params[:registration]
    if @registration.save(:validate => false)
      redirect_to admin_workshop_url(@workshop), notice: 'Registration was successfully updated.'
    else
      render :action => :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to :action => :edit, :id => @registration, :alert => 'Changes not saved - registration was modified by someone else'
  end

  # Record a new payment for the event
  #------------------------------------------------------------------------------
  def ajax_new_payment
    @registration     = Registration.find(params[:id])
    @workshop         = @registration.workshop
    @payment_history  = @registration.manual_payment(
                              params[:payment_history][:amount],
                              params[:payment_history][:amount_currency],
                              current_user.user_profile,
                              item_ref: params[:payment_history][:description],
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
      format.js { render :action => :ajax_new_payment }
    end
  end


=begin

  #------------------------------------------------------------------------------
  def list
    unless params[:id] == nil
      @workshop = EventWorkshop.find_by_id(params[:id])
      permit "#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

      #sort_init 'created_at', 'asc', nil, nil, false, true
      sort_init 'event_registrations.firstname, event_registrations.lastname', 'asc', nil, 'student', false, true
      sort_update

      query = @workshop.event_registration.includes(:event_payment, :student, :country).order(sort_clause)

      @show_all = true
      if params[:commit] == 'Search'
        wildname = params[:name].sql_wildcard
        query = query.where(
                        "(event_registrations.receiptcode LIKE ? OR event_registrations.lastname LIKE ? OR
                         event_registrations.firstname LIKE ? OR event_registrations.email LIKE ? OR
                         students.lastname LIKE ? OR students.firstname LIKE ? OR
                         students.middlename LIKE ? OR students.nickname LIKE ? OR
                         students.email LIKE ?)",
                        wildname, wildname, wildname, wildname,
                        wildname, wildname, wildname, wildname, wildname)
      elsif params[:commit] == 'SearchTag'
        query = query.tagged_with(params[:name])
      elsif params[:commit] == 'SearchState'
        query = query.where("event_registrations.process_state LIKE ?", params[:name])
      else
        query = query.where(params[:archived] ? 'event_registrations.archived_on IS NOT NULL' : 'event_registrations.archived_on IS NULL')
      end
      @event_registrations = query.paginate :page => params[:page], :per_page => 100
    else
      flash[:error] = 'Select a workshop to view registrations'
      redirect_to :controller => 'event_workshops', :action => 'list'
    end
    store_location
  end

  #------------------------------------------------------------------------------
  def checkin
    unless params[:id] == nil
      @workshop = EventWorkshop.find_by_id(params[:id])
      permit "#{SystemRoles::Checkin} on :workshop or #{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

      sort_init 'created_at', 'asc', nil, nil, false, true
      sort_update

      query = @workshop.event_registration.includes(:event_payment, :student, :country).order(sort_clause)
      query = query.where(
          "event_registrations.process_state = 'paid' OR
           event_registrations.process_state = 'accepted' OR
           event_registrations.process_state = 'refunded'")
      query = query.where('event_registrations.archived_on IS NULL')

      @show_all = true
      if params[:commit] == 'Search'
        wildname = params[:name].sql_wildcard
        query = query.where(
            "(event_registrations.receiptcode LIKE ? OR event_registrations.lastname LIKE ? OR
             event_registrations.firstname LIKE ? OR
             students.lastname LIKE ? OR students.firstname LIKE ? OR
             students.middlename LIKE ? OR students.nickname LIKE ?)",
             wildname, wildname, wildname, wildname, wildname, wildname, wildname)

      elsif params[:commit] == 'SearchState'
        query = query.where("event_registrations.process_state LIKE ?", params[:name])
      elsif params[:commit] == 'SearchTag'
        query = query.tagged_with(params[:name])
      else
        @show_all = false
      end
      @event_registrations = query.paginate :page => params[:page], :per_page => 100
    else
      flash[:error] = 'Select a workshop to view registrations'
      redirect_to :controller => 'event_workshops', :action => 'list'
    end
    store_location
  end

  #------------------------------------------------------------------------------
  def student_search
    @workshop = EventWorkshop.find_by_id(params[:id])
    permit "#{SystemRoles::CashierLeader} on :workshop or #{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

    sort_init 'firstname, lastname', 'asc', params[:controller] + '_student_search_sort', nil, false, true
    sort_update

    wildname = params[:name].sql_wildcard
    condition = ["(students.lastname LIKE ? or students.firstname LIKE ? or students.middlename LIKE ? or students.nickname LIKE ? or students.email LIKE ? or students.city LIKE ? or students.address LIKE ?)", wildname,
                wildname, wildname, wildname, wildname, wildname, wildname]
    @show_all = true

    #--- don't include teachers, photos, etc.  Really degrades performance
    @students = Student.paginate :page => params[:page], :per_page => 100, :include => [:country], :conditions => condition, :order => sort_clause
  end

  #------------------------------------------------------------------------------
  def cancel_edit
    redirect_back_or_default(:action => 'list', :id => params[:id])
  end

  #------------------------------------------------------------------------------
  def clear_confirmed_updated
    @workshop = EventWorkshop.find_by_id(params[:id])
    permit "#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

    @workshop.event_registration.clear_confirmed_updated
    redirect_to :action => 'list', :id => @workshop
  end

  #------------------------------------------------------------------------------
  def destroy
    event_registration = EventRegistration.find(params[:id])
    @workshop           = @event_registration.event_workshop
    permit "#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event
    event_registration.destroy
    redirect_back_or_default(:action => 'list', :id => event_registration.event_workshop_id)
  end

  #------------------------------------------------------------------------------
  def markpaid
    event_registration = EventRegistration.find(params[:id])
    event_registration.paid!
    redirect_back_or_default(:action => 'list', :id => event_registration.event_workshop_id)
  rescue ActiveRecord::StaleObjectError
    flash[:error] = 'Changes not saved - registration was modified by someone else'
    redirect_back_or_default(:action => 'list', :id => event_registration.event_workshop_id)
  end

  #------------------------------------------------------------------------------
  def payment_verification
    event_registration = EventRegistration.find(params[:id])
    event_registration.verify_payment
    redirect_back_or_default(:action => 'list', :id => event_registration.event_workshop_id)
  end

  # cancel a registration
  #------------------------------------------------------------------------------
  def cancel
    event_registration = EventRegistration.find(params[:id])
    event_registration.canceled!
    redirect_back_or_default(:action => 'list', :id => event_registration.event_workshop_id)
  rescue ActiveRecord::StaleObjectError
    flash[:error] = 'Changes not saved - registration was modified by someone else'
    redirect_back_or_default(:action => 'list', :id => event_registration.event_workshop_id)
  end


  # remail the registration receipt
  #------------------------------------------------------------------------------
  def email_receipt
    @event_registration = EventRegistration.find(params[:id])
    email = @event_registration.email_receipt
    unless email == nil
      flash[:notice] = 'Email receipt was sent.'
    else
      flash[:error] = 'Sending of email receipt failed.'
    end
    redirect_back_or_default(:action => 'list', :id => @event_registration.event_workshop_id)
  end

  # remail the registration receipt to all attending
  #------------------------------------------------------------------------------
  def email_receipt_attending
    success   = failed = 0
    workshop  = EventWorkshop.find(params[:id])
    workshop.event_registrations_attending.each do |event_registration|
      email     = event_registration.email_receipt
      success  += 1 if email
      failed   += 1 if email.nil?
    end
    flash[:notice] = "Email receipt sent:  Successfully: #{success}    Failed: #{failed}"
    redirect_back_or_default(:action => :list, :id => workshop.id)
  end

  #------------------------------------------------------------------------------
  def export_payment
    unless params[:id] == nil
      column_definitions =  []
      column_definitions <<     ["student_id",        "item.student.nil? ? '' : item.student.id", 100]
      column_definitions <<     ["lastname",          "item.student.nil? ? item.lastname.capitalize : item.student.lastname.capitalize", 100]
      column_definitions <<     ["firstname",         "item.student.nil? ? item.firstname.capitalize : item.student.firstname.capitalize", 100]
      column_definitions <<     ["fullname",          "item.full_name", 100]
      column_definitions <<     ["receiptcode",       "item.receiptcode", nil, {:type => 'Number'}]
      column_definitions <<     ["payamount",         "item.event_payment.amount", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
      column_definitions <<     ["paytype",           "item.event_payment.payment_type"]
      column_definitions <<     ["paydesc",           "item.event_payment.payment_desc"]
      column_definitions <<     ["balance_owed",      "item.balance_owed / 100"]
      column_definitions <<     ["discount",          "item.discount_cents / 100"]
      column_definitions <<     ["item_code",         "item.item_code"]
      column_definitions <<     ["payment_comment",   "item.payment_comment"]
      column_definitions <<     ["receipt_requested", "item.receipt_requested"]

      workshop = EventWorkshop.find(params[:id])
      data_export(column_definitions, workshop.event_registrations_attending, :filename => "Payments #{workshop.title}", :expressions => true, :format => params[:format])
    end
  end

  #------------------------------------------------------------------------------
  def export_customers
    raise "Export Customer List" unless permit? SystemRoles::KitchenSink
    unless params[:id] == nil
      column_definitions =  []
      column_definitions <<     ["Code",            "item.student.nil? ? '' : ('H' + item.student.id.to_s)"]
      column_definitions <<     ["Name",            "item.full_name", 100]
      column_definitions <<     ["eMail",           "item.student.nil? ? item.email.downcase : item.student.email.downcase", 150]
      column_definitions <<     ["Address1",        "item.student.nil? ? item.address : item.student.address", 150]
      column_definitions <<     ["Address2",        "item.student.nil? ? item.address2 : item.student.address2"]
      column_definitions <<     ["Address3",        "item.student.nil? ? item.city.capitalize : item.student.city.capitalize", 100]
      column_definitions <<     ["State",           "item.student.nil? ? item.state.capitalize : item.student.state.capitalize"]
      column_definitions <<     ["PostCdoe",        "item.student.nil? ? item.zipcode : item.student.zipcode"]
      column_definitions <<     ["AddressCountry",  "item.student.nil? ? item.country.code : item.student.country.code"]
      column_definitions <<     ["Phone",           "item.student.nil? ? item.phone : item.student.phone", 100]
      column_definitions <<     ['Mobile',          'item.student.nil? ? item.cell : item.student.cell', 100]
      column_definitions <<     ['CustomerType',    '2']
      

      workshop = EventWorkshop.find(params[:id])
      data_export(column_definitions, workshop.event_registrations_attending, :filename => "Customers #{workshop.title}", :expressions => true, :format => params[:format])
    end
  end

  #------------------------------------------------------------------------------
  def ajax_quick_update
    @event_registration = EventRegistration.find(params[:id])
  end

  #------------------------------------------------------------------------------
  def ajax_save_update
    @event_registration = EventRegistration.find(params[:id])
    if @event_registration.update_attributes(params[:event_registration])
      render :action => :ajax_save_update
    end
  end

  #------------------------------------------------------------------------------
  def ajax_cancel_update
    render :action => :ajax_cancel_update
  end

  #------------------------------------------------------------------------------
  def ajax_checkin
    @event_registration = EventRegistration.find(params[:id])
  end

  #------------------------------------------------------------------------------
  def ajax_save_checkin
    @event_registration = EventRegistration.find(params[:id])
    params[:event_registration] ||= {}  # TODO this is a hack, if the payment level is not specified
    if params[:commit_value] == 'checkin'
      @event_registration.arrival_at       = DateTime.new(params[:event_registration]["arrival_at(1i)"].to_i, params[:event_registration]["arrival_at(2i)"].to_i, params[:event_registration]["arrival_at(3i)"].to_i) unless !@event_registration.event_workshop.show_arrival_departure or params[:event_registration]["arrival_at(1i)"].blank?
      @event_registration.departure_at     = DateTime.new(params[:event_registration]["departure_at(1i)"].to_i, params[:event_registration]["departure_at(2i)"].to_i, params[:event_registration]["departure_at(3i)"].to_i) unless !@event_registration.event_workshop.show_arrival_departure or params[:event_registration]["departure_at(1i)"].blank?
      @event_registration.checkin_at       = Time.new
      @success = @event_registration.save(:validate => false)
      @event_registration.student.update_attribute(:localcell, params[:localcell]) if @event_registration.student and params[:localcell]
    elsif params[:commit_value] == 'checkout'
      @event_registration.arrival_at       = DateTime.new(params[:event_registration]["arrival_at(1i)"].to_i, params[:event_registration]["arrival_at(2i)"].to_i, params[:event_registration]["arrival_at(3i)"].to_i) unless !@event_registration.event_workshop.show_arrival_departure or params[:event_registration]["arrival_at(1i)"].blank?
      @event_registration.departure_at     = DateTime.new(params[:event_registration]["departure_at(1i)"].to_i, params[:event_registration]["departure_at(2i)"].to_i, params[:event_registration]["departure_at(3i)"].to_i) unless !@event_registration.event_workshop.show_arrival_departure or params[:event_registration]["departure_at(1i)"].blank?
      @event_registration.checkin_at       = nil
      @success = @event_registration.save(:validate => false)
    elsif params[:commit_value] == 'confirm_dates'
      @event_registration.arrival_at       = DateTime.new(params[:event_registration]["arrival_at(1i)"].to_i, params[:event_registration]["arrival_at(2i)"].to_i, params[:event_registration]["arrival_at(3i)"].to_i) unless !@event_registration.event_workshop.show_arrival_departure or params[:event_registration]["arrival_at(1i)"].blank?
      @event_registration.departure_at     = DateTime.new(params[:event_registration]["departure_at(1i)"].to_i, params[:event_registration]["departure_at(2i)"].to_i, params[:event_registration]["departure_at(3i)"].to_i) unless !@event_registration.event_workshop.show_arrival_departure or params[:event_registration]["departure_at(1i)"].blank?
      #@event_registration.user_updated_at  = Time.new
      #@event_registration.room_id          = params[:event_registration][:room_id] if @event_registration.event_workshop.show_rooming
      @success = @event_registration.save(:validate => false)
      @event_registration.student.update_attribute(:localcell, params[:localcell]) if @event_registration.student and params[:localcell]
    elsif params[:commit_value] == 'payment_information'
      @event_registration.attributes = params[:event_registration]
      @success = @event_registration.save(:validate => false)
      if @success
        @event_registration.update_attribute(:item_code,  @event_registration.event_payment.shoppingcart_code) unless (@event_registration.event_payment.nil? || @event_registration.event_payment.shoppingcart_code.blank?)
      end
    else
      @event_registration.send('paid!')
      @success = true
    end
  end

  #------------------------------------------------------------------------------
  def ajax_tag_text
    @event_registration = EventRegistration.find(params[:id])
    render :text => (@event_registration.tag_list_on(params[:tag_context]).blank? ? " " : @event_registration.tag_list_on(params[:tag_context]))
  end

  #------------------------------------------------------------------------------
  def ajax_set_tag_text
    @event_registration = EventRegistration.find(params[:id])
    @event_registration.set_tag_list_on(params[:tag_context], params[:value])
    @event_registration.save(:validate => false)
    @event_registration.reload
    render :partial => "hanuman/shared/tag_text", :object => @event_registration.tags_on(params[:tag_context])
  end


  #------------------------------------------------------------------------------
  def ajax_tag_text_public
    @event_registration = EventRegistration.find(params[:id])
    render :text => (@event_registration.tag_list_public.blank? ? " " : @event_registration.tag_list_public)
  end

  #------------------------------------------------------------------------------
  def ajax_set_tag_text_public
    @event_registration = EventRegistration.find(params[:id])
    @event_registration.tag_public_with(params[:value])
    @event_registration.reload
    render :partial => "hanuman/shared/tag_text", :object => @event_registration.tags_public, :locals => {:caption => 'add public tag'}
  end

  # [todo]
  #------------------------------------------------------------------------------
  def edit_campaign
    @campaign = params[:id] ? EmailCampaign.find(params[:id]) : EmailCampaign.new
    @workshop = @campaign.new_record? ? EventWorkshop.find(params[:workshop_id]) : @campaign.campaignable

    if put_or_post?
      @campaign.attributes = params[:campaign]
      @campaign.html = TemplateLiquid.new(:template => File.read("#{Rails.root}/site_assets/email_templates/template_html.liquid"))
      @campaign.html = "<html><body>#{help.markdown(@campaign.plaintext, :safe => false)}</body></html>"
      if @campaign.save
        @campaign.campaignable = @workshop and @campaign.save if @campaign.campaignable.nil?
        redirect_to :controller => :event_registrations, :action => 'list', :id => @workshop
        return
      end
    end
  end

  # [todo]
  #------------------------------------------------------------------------------
  def send_campaign
    @campaign = EmailCampaign.find(params[:id])
    @workshop = @campaign.campaignable

    @workshop.event_registration.each do |registration|
      if registration.attending?
        values = {'event' => registration.to_liquid}
        @campaign.add_email(registration.student.nil? ? registration.email : registration.student.email, :substitutions => values)
      end
    end
    @campaign.start_sending

    flash[:notice] = "#{@workshop.event_registration.size} emails are now queued for sending"
    redirect_to :action => :edit_campaign, :id => @campaign
  end

  #------------------------------------------------------------------------------
  def preview_campaign
    show_preview_email(params[:campaign][:subject], '', params[:campaign][:plaintext])
  end

  #------------------------------------------------------------------------------
  def show_preview_email(subject, html, plain)
    render :action => :show_preview_email
  end

  #------------------------------------------------------------------------------
  def preview_email
    @subject, @html, @plain = params[:subject], params[:html], params[:plain]
    render :layout => false
  end
=end
end
