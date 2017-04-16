class DmEvent::Admin::WorkshopsController < DmEvent::Admin::AdminController
  include DmEvent::PermittedParams
  include DmCore::PermittedParams
  include CsvExporter
  
  before_action   :workshop_lookup, except: [:index, :new, :create, :user_outstanding_balances]
  
  helper DmEvent::WorkshopsHelper

  #------------------------------------------------------------------------------
  def index
    authorize! :access_event_section, :all
    @workshops      = Workshop.upcoming.select {|w| can?(:list_events, w)}
    @workshops_past = Workshop.past.select {|w| can?(:list_events, w)}
  end

  #------------------------------------------------------------------------------
  def new
    authorize! :manage_events, :all
    @workshop = Workshop.new
  end

  #------------------------------------------------------------------------------
  def edit
    authorize! :manage_events, @workshop
  end

  #------------------------------------------------------------------------------
  def create
    authorize! :manage_events, :all
    @workshop = Workshop.new(workshop_params)
    if @workshop.save
      redirect_to admin_workshop_url(@workshop), notice: 'Workshop was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    authorize! :manage_events, @workshop
    if @workshop.update_attributes(workshop_params)
      redirect_to admin_workshop_url(@workshop), notice: 'Workshop was successfully updated.'
    else
      render action: :edit
    end
  end

  #------------------------------------------------------------------------------
  def show
    authorize! :list_events, @workshop
    respond_to do |format|
      format.html # show.html.erb
      format.json { 
        permissions = {
          manage_events: can?(:manage_events, @workshop),
          manage_event_registrations: can?(:manage_event_registrations, @workshop),
          manage_event_finances: can?(:manage_event_finances, @workshop)
        }
        render json: RegistrationDatatable.new(view_context, current_user, permissions)
      }
      format.xls  { data_export(Registration.csv_columns(@workshop), @workshop.registrations, filename: @workshop.slug, expressions: true, format: 'xls') if can?(:manage_event_registrations, @workshop)}
      format.csv  { data_export(Registration.csv_columns(@workshop), @workshop.registrations, filename: @workshop.slug, expressions: true, format: 'csv') if can?(:manage_event_registrations, @workshop)}
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    authorize! :manage_events, :all
    @workshop.destroy
    redirect_to admin_workshops_url, notice: 'Workshop was successfully deleted.'
  end
  
  # Edit/create of the registration state emails.  :email_type is passed in
  # to determine which one we're editing
  #------------------------------------------------------------------------------
  def edit_system_email
    authorize! :manage_events, @workshop
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
    authorize! :manage_event_finances, @workshop
    @financials = @workshop.financial_details
    @payments   = PaymentHistory.where(owner_type: 'Registration', owner_id: @workshop.registrations.pluck(:id)).includes(:user_profile, owner: [:user_profile])
    @unpaid     = @workshop.registrations.unpaid.includes(:user_profile, :workshop_price)
    @unpaid     = @unpaid.to_a.delete_if {|i| i.payment_owed.zero?}.sort_by {|i| i.full_name.downcase}
  end

  # Generate a list of all outstanding balances across all workshops
  #------------------------------------------------------------------------------
  def user_outstanding_balances
    authorize! :manage_events, :all
    @unpaid = Registration.unpaid.includes(:user_profile, :workshop_price)
    @unpaid = @unpaid.to_a.delete_if {|i| i.balance_owed.zero?}.group_by {|i| i.full_name}.sort_by {|i| i[0].downcase}
  end

  # Handle any additional configuration, such as selecting the attached blog/forum
  #------------------------------------------------------------------------------
  def additional_configuration
    authorize! :manage_events, @workshop
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
          params[:workshop][:custom_field_defs_attributes].each_pair {|key, value| params[:workshop][:custom_field_defs_attributes][key].delete(:custom_field)}
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
    authorize! :manage_event_finances, @workshop
    status  = @workshop.send_payment_reminder_emails(params[:registration_id])
    msg     = "Reminder emails sent ==>  Success: #{status[:success]}  Failed: #{status[:failed]}"
    status[:failed] > 0 ? (flash[:warning] = msg) : (flash[:notice] = msg)
    redirect_to financials_admin_workshop_url(@workshop)
  end

  #------------------------------------------------------------------------------
  def lost_users
    authorize! :manage_event_registrations, @workshop
    if put_or_post?
      @days_ago = params[:lost_users][:days_ago].to_i
      @days_ago = 60 if @days_ago > 60
    else
      @days_ago   = 10
    end
    # @lost_users = Workshop.lost_users(@days_ago)
    @lost_users = @workshop.lost_users(@days_ago)
  end

  #------------------------------------------------------------------------------
  def permissions
    authorize! :manage_events, :all
    if put_or_post?
      if params[:user][:user_id]
        user = User.find(params[:user][:user_id])
        if user
          roles = params[:user].delete(:roles)
          [:manage_event, :manage_event_registration, :manage_event_finance].each do |role|
            roles[role].as_boolean ? user.add_role(role, @workshop) : user.remove_role(role, @workshop)
          end
          user.save!
        end
      end
    end
    @event_managers = User.with_role(:event_manager)
    @event_managers_alacarte = User.with_role(:event_manager_alacarte)
  end

  #------------------------------------------------------------------------------
  def ajax_toggle_permission
    authorize! :manage_events, :all
    user = User.find(params[:user_id])
    role = params[:role].to_sym
    if user && [:manage_event, :manage_event_registration, :manage_event_finance].include?(role)
      user.has_role?(role, @workshop) ? user.remove_role(role, @workshop) : user.add_role(role, @workshop)
      user.save!
    end
    head :ok
  end

private

  #------------------------------------------------------------------------------
  def workshop_lookup
    @workshop = Workshop.friendly.find(params[:id])
  end

end
