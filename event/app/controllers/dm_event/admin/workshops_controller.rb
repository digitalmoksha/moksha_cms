class DmEvent::Admin::WorkshopsController < DmEvent::Admin::AdminController
  include DmEvent::PermittedParams
  include DmCore::PermittedParams
  include CsvExporter
  
  before_filter   :workshop_lookup, except: [:index, :new, :create]
  
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
    @workshop = Workshop.new(workshop_params)
    if @workshop.save
      redirect_to admin_workshop_url(@workshop), notice: 'Workshop was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    prepare_date_time_attribute
    if @workshop.update_attributes(workshop_params)
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
      format.xls { data_export(Registration.csv_columns(@workshop), @registrations, filename: @workshop.slug, expressions: true, format: 'xls') }
      format.csv { data_export(Registration.csv_columns(@workshop), @registrations, filename: @workshop.slug, expressions: true, format: 'csv') }
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
      @system_email.attributes = system_email_params
      if @system_email.save
        redirect_to edit_system_email_admin_workshop_path(@workshop, email_type: @system_email.email_type), notice: 'Email was successfully updated.'
      end
    end    
  end
  
  #------------------------------------------------------------------------------
  def financials
    @financials = @workshop.financial_details
    @payments = PaymentHistory.where(owner_type: 'Registration', owner_id: @workshop.registrations.pluck(:id)).includes(:user_profile, owner: [:user_profile])
  end

  # Handle any additional configuration, such as selecting the attached blog/forum
  #------------------------------------------------------------------------------
  def additional_configuration
    if put_or_post?
      if @workshop.valid?
        new_blog_id = params[:workshop].delete(:cms_blog).to_i
        if @workshop.cms_blog.try(:id) != new_blog_id
          @workshop.cms_blog = new_blog_id == 0 ? nil : CmsBlog.find(new_blog_id)
        end
    
        new_forum_id = params[:workshop].delete(:forum).to_i
        if @workshop.forum.try(:id) != new_forum_id
          @workshop.forum = new_forum_id == 0 ? nil : Forum.find(new_forum_id)
        end

        #--- remove any extra "custom_field" attributes left during the field definition
        if params[:workshop][:custom_field_defs_attributes]
          params[:workshop][:custom_field_defs_attributes].each_key {|key| params[:workshop][:custom_field_defs_attributes][key].delete(:custom_field)}
        end
        
        @workshop.update_attributes(workshop_params)
        redirect_to additional_configuration_admin_workshop_url(@workshop), notice: 'Workshop was successfully updated.'
      else
        render action: :additional_configuration
      end
    end
  end
  
  #------------------------------------------------------------------------------
  def send_payment_reminder_emails
    status  = @workshop.send_payment_reminder_emails(params[:registration_id])
    msg     = "Reminder emails sent ==>  Success: #{status[:success]}  Failed: #{status[:failed]}"
    status[:failed] > 0 ? (flash[:warning] = msg) : (flash[:notice] = msg)
    redirect_to financials_admin_workshop_url(@workshop)
  end

private

  #------------------------------------------------------------------------------
  def workshop_lookup
    @workshop = Workshop.friendly.find(params[:id])
  end

  #------------------------------------------------------------------------------
  def prepare_date_time_attribute
    start_date = params[:workshop].delete(:starting_on_date) + " " + params[:workshop].delete(:starting_on_time)
    params[:workshop][:starting_on] = DateTime.parse(start_date) unless start_date.blank?

    end_date = params[:workshop].delete(:ending_on_date) + " " + params[:workshop].delete(:ending_on_time)
    params[:workshop][:ending_on] = DateTime.parse(end_date) unless end_date.blank?
  end
  
end
