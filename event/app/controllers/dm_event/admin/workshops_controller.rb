class DmEvent::Admin::WorkshopsController < DmEvent::Admin::ApplicationController
  include CsvExporter
  
  before_filter   :workshop_lookup, :except => [:index, :new, :create]
  
  helper DmEvent::WorkshopsHelper

  #------------------------------------------------------------------------------
  def index
    @workshops      = Workshop.upcoming
    @workshops_past = Workshop.past
  end

  #------------------------------------------------------------------------------
  def new
    @workshop = Workshop.new
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    prepare_date_time_attribute
    @workshop = Workshop.new(params[:workshop])
    if @workshop.save
      redirect_to admin_workshop_url(@workshop), notice: 'Workshop was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    prepare_date_time_attribute
    if @workshop.update_attributes(params[:workshop])
      redirect_to admin_workshop_url(@workshop), notice: 'Workshop was successfully updated.'
    else
      render action: :edit
    end
  end

  #------------------------------------------------------------------------------
  def show
    @registrations  = @workshop.registrations
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: RegistrationDatatable.new(view_context) }
      format.xls { data_export(Registration.csv_columns, @registrations, :filename => @workshop.slug, :expressions => true, :format => 'xls') }
      format.csv { data_export(Registration.csv_columns, @registrations, :filename => @workshop.slug, :expressions => true, :format => 'csv') }
    end    
  end
  
  # Edit/create of the registration state emails.  :email_type is passed in
  # to determine which one we're editing
  #------------------------------------------------------------------------------
  def edit_system_email
    redirect_to(admin_workshop_url(@workshop), error: 'Invalid system email type') if params[:email_type].blank?
    # [todo] verify that the email_type is one of the Registration.aasm.states
    
    @system_email = @workshop.send("#{params[:email_type]}_email") || @workshop.send("build_#{params[:email_type]}_email")
    @system_email.email_type = params[:email_type]
    if put_or_post?
      @system_email.attributes = params[:system_email]
      if @system_email.save
        redirect_to admin_workshop_url(@workshop), notice: 'Email was successfully updated.'
      end
    end    
  end
  
  #------------------------------------------------------------------------------
  def financials
    @financials = @workshop.financial_details
    @payments = []
    @workshop.registrations.each {|x| @payments.concat(x.payment_histories)}
  end

  #------------------------------------------------------------------------------
  def send_payment_reminder_emails
    status = @workshop.send_payment_reminder_emails
    redirect_to financials_admin_workshop_url(@workshop), notice: "Reminder emails sent ==>  Success: #{status[:success]}  Failed: #{status[:failed]}"
  end

private

  #------------------------------------------------------------------------------
  def workshop_lookup
    @workshop = Workshop.find(params[:id])
  end

  #------------------------------------------------------------------------------
  def prepare_date_time_attribute
    start_date = params[:workshop].delete(:starting_on_date) + " " + params[:workshop].delete(:starting_on_time)
    params[:workshop][:starting_on] = DateTime.parse(start_date) unless start_date.blank?

    end_date = params[:workshop].delete(:ending_on_date) + " " + params[:workshop].delete(:ending_on_time)
    params[:workshop][:ending_on] = DateTime.parse(end_date) unless end_date.blank?
  end
  
=begin

  # include CsvExporter
  # include DmUtilities::VcardExporter
  # include DmEvent::EventRegistrationsHelper
  # include DmUtilities::RenderingHelper
  # include DmUtilities::SortHelper
  # include DmAuthorization
  
  # helper ReportHelper
  # helper RegistrationHelper
  
  # permit "#{SystemRoles::Admin} on Event or #{SystemRoles::System}", :only => ['destroy']
  # permit "#{SystemRoles::Access} on Event or #{SystemRoles::Admin} on Event or #{SystemRoles::Attendant} or #{SystemRoles::System}"
  
  #before_filter :cache_permissions

  #------------------------------------------------------------------------------
  def list
    unless params[:id] == nil
      condition         = params[:archived] ? 'archived_on IS NOT NULL' : 'archived_on IS NULL'
      @event            = find_event_by_id(params[:id])
      @event_workshops  = @event.event_workshop.find(:all, :conditions => condition, :order => 'startdate DESC')
      @workshop_admin   = permit?("#{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}")
      permit "(#{SystemRoles::Access} on :event or #{SystemRoles::Moderator} on :event) or #{SystemRoles::Admin} on Event or #{SystemRoles::Attendant} or #{SystemRoles::System}"
    else
      flash[:notice] = 'Select an event to view workshops'
      redirect_to :controller => 'events', :action => 'list'
    end
    respond_to do |format|
      format.html # index.html.erb
      format.iphone { render :layout => false } # index.iphone.erb
    end
  end

  #------------------------------------------------------------------------------
  def search_results
    if params[:id].nil? or params[:name].blank?
      flash[:error] = 'A workshop or search criteria needs to be specified'
      redirect_to :controller => 'event_workshops', :action => 'list', :id => params[:id]
    else
      condition         = 'archived_on IS NULL'
      @event            = find_event_by_id(params[:id])
      @event_workshops  = @event.event_workshop.find(:all, :conditions => condition, :order => 'startdate DESC')
      @workshop_admin   = permit?("#{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}")
      permit "(#{SystemRoles::Access} on :event or #{SystemRoles::Moderator} on :event) or #{SystemRoles::Admin} on Event or #{SystemRoles::System}"
      
      archive_condition  = params[:archived] ? 'event_registrations.archived_on IS NOT NULL' : 'event_registrations.archived_on IS NULL'
      sort_init 'event_registrations.firstname, event_registrations.lastname', 'asc', nil, nil, false, true
      sort_update

      @results = Array.new
      wildname = params[:name].sql_wildcard
      @event_workshops.each do |event_workshop|
        if @workshop_admin || permit?("#{SystemRoles::Moderator} on :workshop or #{SystemRoles::Checkin} on :workshop", :workshop => event_workshop)
          @results << event_workshop
          if @workshop_admin
            condition = ["(event_registrations.receiptcode LIKE ? OR event_registrations.lastname LIKE ? OR 
                           event_registrations.firstname LIKE ? OR event_registrations.email LIKE ? OR
                           students.lastname LIKE ? OR students.firstname LIKE ? OR 
                           students.middlename LIKE ? OR students.nickname LIKE ? OR 
                           students.email LIKE ?)",
                          wildname, wildname, 
                          wildname, wildname,
                          wildname, wildname,
                          wildname, wildname,
                          wildname]
          else
            condition = ["(event_registrations.receiptcode LIKE ? OR event_registrations.lastname LIKE ? OR 
                           event_registrations.firstname LIKE ? OR event_registrations.email LIKE ? OR
                           students.lastname LIKE ? OR students.firstname LIKE ? OR 
                           students.middlename LIKE ? OR students.nickname LIKE ? OR 
                           students.email LIKE ?) AND
                          (event_registrations.process_state = 'paid' OR 
                           event_registrations.process_state = 'accepted')",
                          wildname, wildname, 
                          wildname, wildname,
                          wildname, wildname,
                          wildname, wildname,
                          wildname]
          end
          @results[@results.length-1][0] = EventRegistration.find_all_by_event_workshop_id(event_workshop.id, :conditions => condition, :include => [:event_workshop, :event_payment, :student, :country], :order => sort_clause)
          @results.delete_at(@results.length-1) if @results[@results.length-1][0].length == 0
        end
      end
    end
    store_location
    
  end

  #------------------------------------------------------------------------------
  def archive
    workshop = EventWorkshop.find(params[:id])
    workshop.toggle_archive
    redirect_to :action => 'edit', :id => workshop
  end
  
  #------------------------------------------------------------------------------
  def duplicate_and_edit
    @event_workshop = EventWorkshop.find(params[:id])

    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      unless @event_workshop.nil?
        new_workshop = @event_workshop.create_duplicate
      end
    
      redirect_to :action => :edit, :id => new_workshop
    end
  end

  #------------------------------------------------------------------------------
  def payment_matrix
    @event_workshop = EventWorkshop.find(params[:id])
    @payments = []
    @event_workshop.event_registration.each {|x| @payments.concat(x.payment_histories)}
    permit "#{SystemRoles::Finances} on :event_workshop or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event
  end

public
  #------------------------------------------------------------------------------
  def destroy
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @event_workshop.destroy
      redirect_to :action => 'list', :id => @event_workshop.event
    end
  end

  #------------------------------------------------------------------------------
  def report_list
    @event_workshop = EventWorkshop.find(params[:id])    
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop or #{SystemRoles::System} or #{SystemRoles::Rooming} on :event_workshop", :event => @event_workshop.event
  end
  
  #------------------------------------------------------------------------------
  def report_summary
    @event_workshop   = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @countries      = @event_workshop.event_registration.report_students_per_country
      @grouplist      = @event_workshop.event_registration.report_students_per_group
      @nogrouplist    = @event_workshop.event_registration.report_students_no_group
      @firsttime      = @event_workshop.event_registration.report_firsttime
      @teachers       = @event_workshop.event_registration.report_teachers

      render :layout =>  'report_layout'
    end
  end

  #------------------------------------------------------------------------------
  def report_arrival
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportAttendance} on :event_workshop", :event => @event_workshop.event ) do 
      @dates          = @event_workshop.event_registration.report_arrival_departure
      render :layout =>  'report_layout'
    end
  end

  # Simple export of all the workshops - not really used
  #------------------------------------------------------------------------------
  def export_workshop_list
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      column_definitions =  [   ['date',        'item.startdate.to_date'], 
                                ['title',        'item.title'],
                                ['country',      'item.country.english_name']
                            ]

      workshops = EventWorkshop.find(:all, :order => 'startdate')
      data_export(column_definitions, workshops, :filename => "workshops", :expressions => true, :format => params[:format])
    end
  end

  
  #------------------------------------------------------------------------------
  def export_arrival
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportAttendance} on :event_workshop", :event => @event_workshop.event ) do 
      column_definitions =  [   ['checkin_at',        'item.checkin_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}], 
                                ['arrival_at',        'item.arrival_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}], 
                                ['departure_at',      'item.departure_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}],
                                ["firstname",         "item.student.nil? ? item.firstname.capitalize : item.student.firstname.capitalize", 100], 
                                ["lastname",          "item.student.nil? ? item.lastname.capitalize : item.student.lastname.capitalize", 100],
                                ["room",              "item.room.number", 50],
                                ["floor",             "item.room.floor_to_human", 50],
                                ["building",          "item.room.building", 50],
                                ['indiancell',        'item.student.nil? ? item.localcell : item.student.localcell', 100]
                            ]

      event_registrations = @event_workshop.event_registration.find(:all, :conditions => "(process_state = 'accepted' OR process_state = 'paid') AND archived_on IS NULL", :order => "arrival_at ASC")
      data_export(column_definitions, event_registrations, :filename => "arrival_list_#{@event_workshop.title}", :expressions => true, :format => params[:format])
    end
  end

  #------------------------------------------------------------------------------
  def report_departure
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportAttendance} on :event_workshop", :event => @event_workshop.event ) do 
      @dates          = @event_workshop.event_registration.report_arrival_departure
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_group
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event ) do 
      @grouplist      = @event_workshop.event_registration.report_students_per_group
      @nogrouplist    = @event_workshop.event_registration.report_students_no_group
      @firsttime      = @event_workshop.event_registration.report_firsttime
      @teachers       = @event_workshop.event_registration.report_teachers
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_group_2
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event ) do 
      @grouplist      = @event_workshop.event_registration.report_students_per_group
      @nogrouplist    = @event_workshop.event_registration.report_students_no_group
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_group_by_room
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event ) do 
      @grouplist      = @event_workshop.event_registration.report_students_per_group
      @nogrouplist    = @event_workshop.event_registration.report_students_no_group
      @firsttime      = @event_workshop.event_registration.report_firsttime
      @teachers       = @event_workshop.event_registration.report_teachers
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_group_thumbs
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event ) do 
      @grouplist      = @event_workshop.event_registration.report_students_per_group
      @nogrouplist    = @event_workshop.event_registration.report_students_no_group
      @firsttime      = @event_workshop.event_registration.report_firsttime
      @teachers       = @event_workshop.event_registration.report_teachers
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_group_thumbs_2
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event ) do 
      @grouplist      = @event_workshop.event_registration.report_students_per_group
      @nogrouplist    = @event_workshop.event_registration.report_students_no_group
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_group_non_attending
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @grouplist      = @event_workshop.event_registration.report_attending_group_list
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_tag
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @taglist      = @event_workshop.event_registration.report_students_per_tag
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_tag_thumbnails
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @taglist      = @event_workshop.event_registration.report_students_per_tag
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_country
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event do
      @countries      = @event_workshop.event_registration.report_students_per_country
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_roommate
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Rooming} on :event_workshop or #{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @roommate       = @event_workshop.event_registration.report_roomates
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_medical
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @medical        = @event_workshop.event_registration.report_medical
      @medical.each do |item|
        item.health_conditions    = empty_value(item.health_conditions)
        item.psych_care           = empty_value(item.psych_care)
        item.special_requirements = empty_value(item.special_requirements)
        item.medication_allergies = empty_value(item.medication_allergies)
      end
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_transportation_arrival
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Transportation} on :event_workshop or #{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event do
      params[:report] ||= {}

      @include_roomnumber       = (params[:report][:include_roomnumber]) ? params[:report][:include_roomnumber] : false
      @include_phone            = (params[:report][:include_phone]) ? params[:report][:include_phone] : false
      @include_departure_bus    = (params[:report][:include_departure_bus]) ? params[:report][:include_departure_bus] : false
      @include_user_update      = (params[:report][:include_user_update]) ? params[:report][:include_user_update] : false
      @back_link                = url_for(:action => :report_list, :id => @event_workshop)
      @vehicles                 = Vehicle.find_all_by_event_workshop_id_and_to_ashram(@event_workshop, true)
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_transportation_departure
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Transportation} on :event_workshop or #{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event do
      @vehicles                 = Vehicle.find_all_by_event_workshop_id_and_to_ashram(@event_workshop, false)
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def empty_value(x)
    case x.downcase
    when 'na', 'no', 'none', 'n/a', '-', 'x', 'no.', 'nope', '/', 'nothing', 'nein', 'ok', 'o.k.', 'never', 'neine', '--', 'none.', '-no', 'non'
      return ''
    else
      return x
    end
  end
  
  #------------------------------------------------------------------------------
  def report_accepted
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @accepted       = @event_workshop.event_registration.report_accepted
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_payment_list
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      params[:report] ||= {}
      @alternate_currencies = (params[:report][:alternate_currencies]) ? params[:report][:alternate_currencies] : false
      @accepted             = @event_workshop.event_registrations_attending.find(:all, :order => 'firstname, lastname ASC')
      @back_link            = url_for(:action => :report_list, :id => @event_workshop)
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_rooming_list
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop or #{SystemRoles::Rooming} on :event_workshop", :event => @event_workshop.event ) do 
      @rooming       = @event_workshop.event_registration.report_rooming_list
      render :layout =>  'report_layout'
    end
  end
  
  # state => :attending or :waitlisted
  #------------------------------------------------------------------------------
  def report_thumbnails
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @students = Array.new
      @event_workshop.event_registration.each do |event_registration|
        case params[:state]
        when 'waitlisted'
          if event_registration.student && event_registration.waitlisted? && !event_registration.archived?
            s = event_registration.student
            @students << s
          end
        when 'pending'
          if event_registration.student && event_registration.pending? && !event_registration.archived?
            s = event_registration.student
            @students << s
          end
        else
          @students << event_registration.student if event_registration.student && event_registration.attending? && !event_registration.archived?
        end
      end
      @thumb_only = true
    
      render :action => 'report_bios', :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_bios
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event => @event_workshop.event do
      @students = Array.new
      @event_workshop.event_registration.each do |event_registration|
        case params[:state]
        when 'waitlisted'
          @students << event_registration.student if event_registration.student && event_registration.waitlisted? && !event_registration.archived?
        when 'pending'
          @students << event_registration.student if event_registration.student && event_registration.pending? && !event_registration.archived?
        else
          @students << event_registration.student if event_registration.student && event_registration.attending? && !event_registration.archived?
        end
      end
    
      render :layout =>  'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def report_teacher_bios
    @event_workshop = EventWorkshop.find(params[:id])
    permit "#{SystemRoles::System}" do
      @students = Array.new
      @event_workshop.event_registration.each do |event_registration|
        @students << event_registration.student if event_registration.student && event_registration.student.teacher && event_registration.attending? && !event_registration.archived?
      end
    
      render :layout =>  'report_layout'
    end
  end

  #------------------------------------------------------------------------------
  def export_vcards
    @event_workshop = EventWorkshop.find(params[:id])
    vcard_items = Array.new
    permit "#{SystemRoles::System}" do
      @event_workshop.event_registrations_attending.each do |event_registration|
        vcard_items << {:firstname => event_registration.student.firstname, 
                        :lastname => event_registration.student.lastname + " ***",
                        :mobile => event_registration.student.localcell,
                        :company => "#{event_registration.room.to_s}",
                        :dates  => "#{format_date_range(event_registration.arrival_at, event_registration.departure_at, false, :separator => ' to ')}"
                       }
      end
    
      vcard_export(vcard_items, :filename => "vcards", :expressions => true, :format => params[:format])
    end
  end

  # Uses Ruport
  #------------------------------------------------------------------------------
  def report_custom
    @event_workshop = EventWorkshop.find(params[:id])
    permit("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::System} or #{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event => @event_workshop.event ) do 
      params[:report] ||= {}
      @columns          = custom_column_defs(@event_workshop)
      @state_filter     = params[:report][:state_filter].blank? ? 'attending' : params[:report][:state_filter].downcase
      if sys_admin? or permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event", :event => @event_workshop.event)
        @state_filter_options  = ['Attending', 'Pending', 'Reviewing', 'Accepted', 'Paid', 'Waitlisted', 'Rejected', 'Canceled', 'All']
      else
        @state_filter_options  = ['Attending', 'Accepted', 'Paid']
      end
      @group_by         = (params[:report][:group_by] and @columns.any? {|a| a[0] == params[:report][:group_by]}) ? params[:report][:group_by] : nil
      @sort_by          = (params[:report][:sort_by] and @columns.any? {|a| a[0] == params[:report][:sort_by]}) ? params[:report][:sort_by] : 'Name'
      @sort_by_2        = (params[:report][:sort_by_2] and @columns.any? {|a| a[0] == params[:report][:sort_by_2]}) ? params[:report][:sort_by_2] : nil
      @sort_by_3        = (params[:report][:sort_by_3] and @columns.any? {|a| a[0] == params[:report][:sort_by_3]}) ? params[:report][:sort_by_3] : nil
      @selected_fields  = (params[:report][:fields]) ? params[:report][:fields] : ['Name']
      @header           = (params[:report][:header]) ? params[:report][:header] : 'Custom Report'
      @not_specified    = (params[:report][:not_specified]) ? params[:report][:not_specified] : false
      @numbering        = (params[:report][:numbering]) ? params[:report][:numbering] : true
      @single_page      = (params[:report][:single_page]) ? params[:report][:single_page] : false

      column_subset     = Array.new    
      @columns.each do |column|
        column_subset << column if (@selected_fields.detect { |f| f == column[0] or @group_by == column[0]}) or (column[3] !=nil and column[3][:type] == 'hidden')
      end

      @report_html = EventReport.render_html( :column_definitions => column_subset, 
                                              :event_workshop => @event_workshop, 
                                              :subtitle => @event_workshop.title,
                                              :group_by => @group_by, 
                                              :sort_by => @sort_by, :sort_by_2 => @sort_by_2, :sort_by_3 => @sort_by_3,
                                              :not_specified => @not_specified,
                                              :numbering => @numbering, :single_page => @single_page,
                                              :state_filter => @state_filter, :state_filter_options => @state_filter_options)
    
      @title        = "#{@header} for #{@event_workshop.title}"
      @subtitle     = @event_workshop.title
      @back_link    = url_for(:action => :report_list, :id => @event_workshop)
      
      render :template => 'hanuman/shared/report_custom', :layout => 'report_layout'
    end
  end
  
  #------------------------------------------------------------------------------
  def custom_column_defs(event_workshop)
    event_admin        = (sys_admin? or permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event", :event_workshop => event_workshop, :event => event_workshop.event))
    column_definitions = Array.new
    column_definitions << ["Photo (small)",   "(item.student.nil? or item.student.photo.nil?) ? StudentPhoto.new.image_url(:mini) : item.student.photo.image_url(:mini)", nil, {:type => 'image_html', :class => 'photo_inline'}]
    column_definitions << ["Photo (medium)",  "(item.student.nil? or item.student.photo.nil?) ? StudentPhoto.new.image_url(:thumb) : item.student.photo.image_url(:thumb)", nil, {:type => 'image_html', :class => 'photo_inline'}]
    column_definitions << ['Receipt Code',    'item.receiptcode', nil, {:type => 'Number', :numberformat => '#,##0.00', :class => 'receipt_code'}]
    column_definitions << ["Name",            "item.full_name.capitalize", nil, {:type => (event_admin ? 'link' : 'string'), :link => url_for(:controller => :event_registrations, :action => :edit)}]
    column_definitions << ["Name_link",       "item.id", nil, {:type => 'hidden'}]
    column_definitions << ['State',           'item.process_state', nil, {:class => 'state'}]
    column_definitions << ["Amount Paid",     "item.amount_formatted", nil, {:class => 'amount_paid'}] if event_admin
    column_definitions << ["Balance Owed",    "item.balance_owed(true)", nil, {:class => 'amount_paid'}] if event_admin
    column_definitions << ["Discount",        "item.discount_formatted", nil, {:class => 'amount_paid'}] if event_admin    
    column_definitions << ["Paid By",         "item.event_payment.payment_type", nil, {}] if event_admin
    column_definitions << ["Payment Desc",    "item.event_payment.payment_desc", nil, {}] if event_admin or permit?("#{SystemRoles::Checkin} on :event_workshop")
    column_definitions << ["Payment Comment", "item.payment_comment", nil, {}] if event_admin or permit?("#{SystemRoles::Checkin} on :event_workshop")
    column_definitions << ["Receipt Requested","item.receipt_requested ? 'Yes' : 'No'", nil, {}]
    column_definitions << ["Confirmed",       "item.confirmed_on.nil? ? 'No' : 'Yes'", nil, {}]
    column_definitions << ["Photo Report",    "(item.student.nil? or item.student.photo.nil?) ? StudentPhoto.new.image_url(:thumb) : item.student.photo.image_url(:thumb)", nil, {}]
    column_definitions << ["Subscribed GDM",  "item.is_subscribed?('GDM') ? 'Yes' : 'No'", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event")
    column_definitions << ["Visited Ashram",  "item.student.nil? ? 'n/a' : (item.student.visited_penukonda? ? 'Yes' : 'No')", nil, {}] if event_workshop.ashram_program
    column_definitions << ["New Student",     "item.student.nil? ? 'n/a' : ((item.student.event_registrations.number_of(:attending) == 1 && item.student.studentgroup.count == 0) ? 'Yes' : 'No')", nil, {}]
    column_definitions << ["Student Status",  "item.student.nil? ? 'n/a' : (item.student.status_name)", nil, {}] if sys_admin?
    column_definitions << ["Address",         "item.student.nil? ? 'n/a' : (item.student.address)", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event or #{SystemRoles::Moderator} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Address2",        "item.student.nil? ? 'n/a' : (item.student.address2)", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event or #{SystemRoles::Moderator} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["City",            "item.student.nil? ? 'n/a' : (item.student.city)", nil, {}]
    column_definitions << ["State/Region",    "item.student.nil? ? 'n/a' : (item.student.state)", nil, {}]
    column_definitions << ["Zipcode",         "item.student.nil? ? 'n/a' : (item.student.zipcode)", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event or #{SystemRoles::Moderator} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Country",         "item.student.nil? ? 'n/a' : (item.student.country.english_name)", nil, {}]
    column_definitions << ["Continent",       "item.student.nil? ? 'n/a' : (item.student.country.continent)", nil, {}]
    column_definitions << ["Age",             "item.student.nil? ? 'n/a' : (item.student.age)", nil, {:class => 'age'}]
    column_definitions << ["Date of Birth",   "item.student.nil? ? 'n/a' : (item.student.dob)", 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
    column_definitions << ["Place of Birth",  "item.student.nil? ? 'n/a' : (item.student.student_extra.birth_place)", nil, {}]
    column_definitions << ["Gender",          "item.student.nil? ? 'n/a' : (item.student.gender)", nil, {:class => 'gender'}] if event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Spouse",          "item.student.nil? ? 'n/a' : (item.student.student_extra.spouse)", nil, {:class => 'gender'}] if event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Mother's Name",   "item.student.nil? ? 'n/a' : (item.student.student_extra.mothersfullname)", nil, {:class => 'gender'}] if event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Father's Name",   "item.student.nil? ? 'n/a' : (item.student.student_extra.fathersfullname)", nil, {:class => 'gender'}] if event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Which Child",     "item.student.nil? ? 'n/a' : (item.student.student_extra.which_child)", nil, {:class => 'gender'}] if event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Profession",      "item.student.nil? ? 'n/a' : (item.student.profession)", nil, {}] if event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ['Arrival Date',    'item.arrival_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}] if event_workshop.show_arrival_departure and (event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop", :event_workshop => event_workshop))
    column_definitions << ['Departure Date',  'item.departure_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}] if event_workshop.show_arrival_departure and (event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop", :event_workshop => event_workshop))
    column_definitions << ["Arrival Vehicle", "item.arrival_vehicle.nil? ? 'n/a' : (format_date(item.arrival_vehicle.departing_at, false) + ' : ' + item.arrival_vehicle.name + ' : ' + item.arrival_vehicle.style)", nil, {}]
    column_definitions << ["Departure Vehicle","item.departure_vehicle.nil? ? 'n/a' : (format_date(item.departure_vehicle.departing_at, false) + ' : ' + item.departure_vehicle.name + ' : ' + item.departure_vehicle.style)", nil, {}]
    column_definitions << ["Checked in?",     "item.checkedin? ? 'Arrived' : 'No'", nil, {}] if (event_admin or permit?("#{SystemRoles::ReportAttendance} on :event_workshop", :event_workshop => event_workshop))
    column_definitions << ['Last User Update','item.user_updated_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]
    column_definitions << ["Room #",          "item.room.nil? ? 'n/a' : item.room.sortable", nil, {}]
    column_definitions << ["Email",           "item.student.nil? ? 'n/a' : (item.student.email)", nil, {}] if sys_admin? or permit?("#{SystemRoles::EmailAccess} on :event_workshop or #{SystemRoles::Admin} on Event or #{SystemRoles::System}", :event_workshop => event_workshop)
    column_definitions << ["Phone #",         "item.student.nil? ? 'n/a' : (item.student.phone)", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event or #{SystemRoles::Moderator} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Cell #",          "item.student.nil? ? 'n/a' : (item.student.cell)", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event or #{SystemRoles::Moderator} on :event_workshop", :event_workshop => event_workshop)
    column_definitions << ["Local Cell #",    "item.student.nil? ? 'n/a' : (item.student.localcell)", nil, {}]
    column_definitions << ['Groups (for grouping)', "item.student.nil? ? 'n/a' : (item.student.studentgroup.find_all { |x| !x.historical? }.collect {|x| x.name}.join(', '))", nil, {:type => 'list'}] if sys_admin? or permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop, :event => event_workshop.event)
    column_definitions << ['Group List',      "item.student.nil? ? 'n/a' : (item.student.studentgroup.find_all { |x| !x.historical? }.collect {|x| x.name}.join(', '))", nil, {:type => 'list'}] if sys_admin? or permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event or #{SystemRoles::ReportGroups} on :event_workshop", :event_workshop => event_workshop, :event => event_workshop.event)
    column_definitions << ['Events (for grouping)', "item.student.nil? ? 'n/a' : (item.student.event_registrations_attending.collect {|x| x.event_workshop.title.gsub(',', '') if !x.event_workshop.archived?}.join(', '))", nil, {:type => 'list'}] if sys_admin? or permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event", :event_workshop => event_workshop, :event => event_workshop.event)
    column_definitions << ['Events List',      "item.student.nil? ? 'n/a' : (item.student.event_registrations_attending.collect {|x| x.event_workshop.title.gsub(',', '')}.join(', '))", nil, {:type => 'list'}] if sys_admin? or permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event", :event_workshop => event_workshop, :event => event_workshop.event)
    column_definitions << ["Teacher (Continent)", "(item.student.nil? or item.student.teacher.nil?) ? '' : (item.student.country.continent)", nil, {}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event")
    column_definitions << ['Teacher (Certifications)', "(item.student.nil? or item.student.teacher.nil?) ? '' : (item.student.teacher.certifiedprograms.collect {|x| x.name}.join(', '))", nil, {:type => 'list'}] if sys_admin? or permit?("#{SystemRoles::Admin} on Event")
    column_definitions << ['Private Tags (for grouping)', "(item.privatetags.collect {|x| x.name.capitalize}.join(', '))", nil, {:type => 'list'}] if event_admin
    column_definitions << ['Private Tags',    "(item.privatetags.collect {|x| x.name.capitalize}.join(', '))", nil, {:type => 'list'}] if event_admin
    column_definitions << ['Public Tags (for grouping)',  "(item.publictags.collect {|x| x.name.capitalize}.join(', '))", nil, {:type => 'list'}]
    column_definitions << ['Public Tags',     "(item.publictags.collect {|x| x.name.capitalize}.join(', '))", nil, {:type => 'list'}]
    column_definitions << ["Health Conditions","item.health_conditions", nil, {}] if sys_admin?
    column_definitions << ["Psych Care",       "item.psych_care", nil, {}] if sys_admin?
    column_definitions << ["Special Requirements","item.special_requirements", nil, {}] if sys_admin?
    column_definitions << ["Medication Allergies","item.medication_allergies", nil, {}] if sys_admin?
    column_definitions << ["Student History", 
                           '(item.student.histories_ordered_by_submitted.collect {|x| "<h5>#{x.category} : #{x.title}</h5><h6>#{format_date(x.created_at)} : submitted by #{x.user.login}</h6><p>#{x.history}</p>"}).to_s.html_safe', nil, {:type => 'as_row', :class => 'custom_as_row'}] if sys_admin?

    # ---- add the extra fields defined in the workshop record
    @event_workshop.custom_field_defs.each_with_index do | x, index |
      if sys_admin? or !x.admin_only? or (x.admin_only? and permit?("#{SystemRoles::Moderator} on :event_workshop or #{SystemRoles::Moderator} on :event or #{SystemRoles::Admin} on Event", :event_workshop => event_workshop, :event => event_workshop.event))
        case x.fieldtype
        when 'multiple_select'
          column_definitions << [ "#{x.column_name}", "(z = item.custom_fields.detect { |y| y.custom_field_def_id == #{x.id} }) ? z.value : ''", nil, {:type => 'list', :custom_field => true}]
        when 'divider'
        else
          column_definitions << [ "#{x.column_name}", "(z = item.custom_fields.detect { |y| y.custom_field_def_id == #{x.id} }) ? z.value : ''", nil, {:custom_field => true}]        
        end
      end
    end
    return column_definitions
  end
  
  #------------------------------------------------------------------------------
  def new_custom_field
    unless params[:id] == nil
      @custom_field_def = CustomFieldDef.new
      @custom_field_def.owner_id = params[:id]
      @custom_field_def.owner_type = 'EventWorkshop'
    else
      redirect_to :action => :edit_advanced, :id => params[:id]
    end
  end

  #------------------------------------------------------------------------------
  def create_custom_field
    @custom_field_def = CustomFieldDef.new(params[:custom_field_def])
    if @custom_field_def.save
      flash[:notice] = 'Custom Field was successfully created.'
      redirect_to :action => :edit_advanced, :id => @custom_field_def.owner
    else
      render :action => :new_custom_field
    end
  end

  #------------------------------------------------------------------------------
  def edit_custom_field
    @custom_field_def = CustomFieldDef.find(params[:id])
  end

  #------------------------------------------------------------------------------
  def update_custom_field
    @custom_field_def = CustomFieldDef.find(params[:id])
    if @custom_field_def.update_attributes(params[:custom_field_def])
      flash[:notice] = 'Custom Field was successfully updated.'
      redirect_to :action => :edit_advanced, :id => @custom_field_def.owner
    else
      render :action => :edit_custom_field, :id => @custom_field_def
    end
  end

  #------------------------------------------------------------------------------
  def destroy_custom_field
    @custom_field_def = CustomFieldDef.find(params[:id]).destroy
    redirect_to :action => :edit_advanced, :id => @custom_field_def.owner
  end
  
  #------------------------------------------------------------------------------
  def sort_custom_fields
    @event_workshop       = EventWorkshop.find_by_id(params[:id])
    @event_workshop.custom_field_defs.each do |custom_field| 
      custom_field.position = params['row'].index(custom_field.id.to_s) + 1 
      custom_field.save 
    end 
    render :nothing => true 
  end 

=end
end
