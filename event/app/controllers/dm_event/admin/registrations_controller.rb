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
      @registration.send("#{@state_event}!")
    end
  
    respond_to do |format|
      format.html { redirect_to admin_workshop(@registration.workshop) }
      format.js   { render :action => :action_state }
    end
  
  rescue ActiveRecord::StaleObjectError
  end




=begin
  helper :registration
  helper 'dm_event/event_workshops'
  helper 'dm_event/custom_fields'

  include CsvExporter
  include DmUtilities::SortHelper

  can_edit_on_the_spot

  permit "#{SystemRoles::Admin} on Event or #{SystemRoles::System}", :only => ['destroy', 'export']
  permit "#{SystemRoles::Access} on Event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}"

  #------------------------------------------------------------------------------
  def index
    list
    render :action => 'list'
  end

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
  def show
    @event_registration = EventRegistration.find(params[:id])
  end

  # [deprecated]
  #------------------------------------------------------------------------------
  def new
    unless params[:id] == nil
      @workshop           = EventWorkshop.find_by_id(params[:id])
      permit "#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

      @event_registration = EventRegistration.new(:event_workshop_id => @workshop.id,
                                                  :country_id => @workshop.country_id)
      if @workshop.event_payment.length == 1
        @event_registration.event_payment_id = @workshop.event_payment[0].id
      end
    else
      redirect_to :controller => 'events', :action => 'list'
    end
  end

  #------------------------------------------------------------------------------
  def create
    params[:event_registration][:price]         = params[:price].to_money
    @event_registration = EventRegistration.new(params[:event_registration])

    if @event_registration.save
      flash[:notice] = 'EventRegistration was successfully created.'
      redirect_back_or_default(:action => 'list', :id => @event_registration.event_workshop_id)
    else
      @workshop = EventWorkshop.find_by_id(@event_registration.event_workshop_id)
      render :action => 'new'
    end
  end

  #------------------------------------------------------------------------------
  def edit
    @event_registration = EventRegistration.find(params[:id])
    @workshop           = @event_registration.event_workshop
    permit "#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

    #--- build up the custom field objects
    @workshop.custom_field_defs.each do |c|
      @event_registration.custom_fields.build(:custom_field_def_id => c.id) unless @event_registration.custom_fields.detect { |f| f.custom_field_def_id == c.id }
    end
  end

  #------------------------------------------------------------------------------
  def update
    @event_registration = EventRegistration.find(params[:id])
    @workshop           = @event_registration.event_workshop
    permit "#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @workshop.event

    params[:event_registration] ||= Hash.new

    #--- save without validation, so that we can update a registration without having to fill in all details
    @event_registration.attributes = params[:event_registration]
    if @event_registration.save(:validate => false)
      @event_registration.update_attribute(:item_code,  @event_registration.event_payment.shoppingcart_code) unless (@event_registration.event_payment.nil? || @event_registration.event_payment.shoppingcart_code.blank?)
      flash[:notice] = 'Registration was successfully updated'
      redirect_back_or_default(:action => 'list', :id => @event_registration.event_workshop_id)
    else
      render :action => 'edit'
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = 'Changes not saved - registration was modified by someone else'
    redirect_to :action => 'edit', :id => @event_registration
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
  def export
    unless params[:id] == nil
      workshop            = EventWorkshop.find(params[:id])
      filename            = workshop.title
      column_definitions  = []
      if params[:format] == 'email'
        #--- only add email addresses.  Make column name the web site event admin email
        column_definitions  <<     [workshop.event.account.preferred(:event_admin_email), "item.student.nil? ? item.email.downcase : item.student.email.downcase", 150] if sys_admin?
        params[:format]     = 'csv'
        filename           += "_email"
      else
        column_definitions <<     ["student_id",        "item.student.nil? ? '' : item.student.id", 100]
        column_definitions <<     ['process_state',     'item.process_state', 100]
        column_definitions <<     ["fullname",          "item.full_name", 100]
        column_definitions <<     ["lastname",          "item.student.nil? ? item.lastname.capitalize : item.student.lastname.capitalize", 100]
        column_definitions <<     ["firstname",         "item.student.nil? ? item.firstname.capitalize : item.student.firstname.capitalize", 100]
        column_definitions <<     ["email",             "item.student.nil? ? item.email.downcase : item.student.email.downcase", 150] if permit? SystemRoles::KitchenSink # if sys_admin?
        column_definitions <<     ["address",           "item.student.nil? ? item.address : item.student.address", 150] if permit? SystemRoles::KitchenSink # if sys_admin?
        column_definitions <<     ["address2",          "item.student.nil? ? item.address2 : item.student.address2"]  if permit? SystemRoles::KitchenSink # if sys_admin?
        column_definitions <<     ["city",              "item.student.nil? ? item.city.capitalize : item.student.city.capitalize", 100]
        column_definitions <<     ["state",             "item.student.nil? ? item.state.capitalize : item.student.state.capitalize"]
        column_definitions <<     ["zipcode",           "item.student.nil? ? item.zipcode : item.student.zipcode"]
        column_definitions <<     ["country",           "item.student.nil? ? item.country.code : item.student.country.code"]
        column_definitions <<     ["phone",             "item.student.nil? ? item.phone : item.student.phone", 100] if permit? SystemRoles::KitchenSink # if sys_admin?
        column_definitions <<     ["fax",               "item.student.nil? ? item.fax : item.student.fax", 100] if permit? SystemRoles::KitchenSink # if sys_admin?
        column_definitions <<     ['cell',              'item.student.nil? ? item.cell : item.student.cell', 100] if permit? SystemRoles::KitchenSink # if sys_admin?
        column_definitions <<     ['indiancell',        'item.student.nil? ? item.localcell : item.student.localcell', 100]
        column_definitions <<     ['registered_on',     'item.created_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ['checkin_at',        'item.checkin_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ["receiptcode",       "item.receiptcode", nil, {:type => 'Number'}]
        column_definitions <<     ["payamount",         "item.event_payment.amount", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
        column_definitions <<     ["paytype",           "item.event_payment.payment_type"]
        column_definitions <<     ["paydesc",           "item.event_payment.payment_desc"]
        column_definitions <<     ["item_code",         "item.item_code"]
        column_definitions <<     ["receipt_requested", "item.receipt_requested"]
        column_definitions <<     ["heardabout",        "item.heardabout"]
        column_definitions <<     ['arrival_at',        'item.arrival_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ['departure_at',      'item.departure_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ['confirmed_on',      'item.confirmed_on.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ['process_changed_on','item.process_changed_on.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ['user_updated_at',   'item.user_updated_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
        column_definitions <<     ['photo',             '(item.student.nil? or item.student.photo.nil?) ? "" : "x"'] if sys_admin?
        column_definitions <<     ['dob',               'item.student.nil? ? item.dob : item.student.dob', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}] if sys_admin?
        column_definitions <<     ['gender',            'item.student.nil? ? item.gender.capitalize : item.student.gender.capitalize']
        column_definitions <<     ['married',           'item.student.nil? ? item.married : item.student.married'] if sys_admin?
        column_definitions <<     ['roomate_pref',      'item.roomate_pref.capitalize', 200] if sys_admin?
        column_definitions <<     ['room',              'item.room.nil? ? "" : item.room.sortable'] if sys_admin?
        column_definitions <<     ['speak_english',     'item.student.nil? ? item.speak_english : item.student.speak_english']
        column_definitions <<     ['visited_penukonda', 'item.student.nil? ? "" : item.student.visited_penukonda'] if sys_admin?
        column_definitions <<     ['groups',            'item.student.nil? ? "" :  ((item.student.studentgroup.collect {|x| x.name }).join(", "))'] if sys_admin?
        column_definitions <<     ['tags',              '(item.privatetag_list + item.publictag_list).join(" ")']

        #--- add the list of groups
        groups = Studentgroup.find(:all, :order => :name)
        groups.each do |group|
          add = ["g_#{group.name}", "item.student.nil? ? '' :  ((item.student.studentgroup.detect {|x| x.name == '#{group.name}'}) ? 'x' : '')"]
          column_definitions << add
        end

        #--- add the list of tags
        workshop.find_registration_tags(:privatetags).each do |tag|
          add = ["tag_#{tag.name}", "item.privatetags.empty? ? '' :  ((item.privatetags.detect {|x| x.name == '#{tag.name}'}) ? 'x' : '')"]
          column_definitions << add
        end
        workshop.find_registration_tags(:publictags).each do |tag|
          add = ["tag_#{tag.name}", "item.publictags.empty? ? '' :  ((item.publictags.detect {|x| x.name == '#{tag.name}'}) ? 'x' : '')"]
          column_definitions << add
        end

        # ---- add the extra fields defined in the workshop record
        workshop.custom_field_defs.each_with_index do | x, index |
          column_definitions << [ "#{x.column_name}", "(z = item.custom_fields.detect { |y| y.custom_field_def_id == #{x.id} }) ? z.data : ''"]
        end
      end

      query = EventRegistration.where(:event_workshop_id => params[:id]).order("lastname ASC")

      if !params[:state].blank?
        case params[:state]
        when 'attending'
          query = query.where("(process_state = 'paid' OR process_state = 'accepted') AND archived_on IS NULL")
          filename += "_attending"
        when 'confirmed'
          query = query.where("confirmed_on IS NOT NULL AND (process_state = 'paid' OR process_state = 'accepted') AND archived_on IS NULL")
          filename += "_confirmed"
        when 'unconfirmed'
          query = query.where("confirmed_on IS NULL AND (process_state = 'paid' OR process_state = 'accepted') AND archived_on IS NULL")
          filename += "_unconfirmed"
        else
          #--- must be wanting to export the process states
          query = query.where("process_state = ? AND archived_on IS NULL", params[:state].to_s)
          filename += "_#{params[:state].to_s}"
        end
        event_registrations = query
      elsif !params[:privatetags].blank?
        event_registrations = query.tagged_with(params[:privatetags], :on => :privatetags)
      elsif !params[:publictags].blank?
        event_registrations = query.tagged_with(params[:publictags], :on => :publictags)
      else
        event_registrations = query.where("archived_on IS NULL")
      end
      data_export(column_definitions, event_registrations, :filename => filename, :expressions => true, :format => params[:format])
    end
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
  def ajax_new_payment
    @event_registration = EventRegistration.find(params[:id])
    @payment_history = @event_registration.payment_histories.create(
        :anchor_id            => @event_registration.receiptcode,
        :cost                 => params[:payment_history][:cost],
        :item_id              => params[:payment_history][:item_id],
        :quantity             => 1,
        :discount             => 0,
        :total_cents          => EventPayment.payment_total_cents(params[:payment_history][:cost]),
        :payment_method       => params[:payment_history][:payment_method],
        :bill_to_name         => params[:payment_history][:bill_to_name],
        :payment_date         => Time.now,
        :manual_entry         => true,
        :currency_country_id  => params[:payment_history][:currency_country_id])
    if @payment_history.errors.empty?
      @event_registration.update_attribute(:amount, @event_registration.amount + @event_registration.event_payment.to_base_currency_cents(@payment_history.total_cents, @payment_history.currency_country)) #@payment_history.total_cents)
      @event_registration.update_attribute(:receipt_requested, params[:event_registration][:receipt_requested])
      @event_registration.reload
      @event_registration.send('paid!') if @event_registration.balance_owed <= 0 && !@event_registration.paid?
      #--- checkin person if "Save and Checkin" pressed
      if params[:commit].downcase != 'save'
        @event_registration.checkin_at       = Time.new
        success = @event_registration.save(:validate => false)
      end
    end

    respond_to do |format|
      format.html {
        flash[:notice] = "Payment added #{@event_registration.payment_histories.sum(:cost)}" if @payment_history.errors.empty?
        redirect_to :action => 'edit', :id => @event_registration
      }
      format.js { render :action => :ajax_new_payment }
    end
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
