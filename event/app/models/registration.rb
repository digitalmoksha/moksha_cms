# Important: one reason to link off of the user_profile instead of the user
# is so that we can support registrations without requiring an account.
# We can create a "userless" profile, that has all the necessary information.
# This is instead of duplicating all those fields in the registration table.
#------------------------------------------------------------------------------
class Registration < ActiveRecord::Base
  include DmEvent::Concerns::RegistrationStateMachine
  include DmEvent::Concerns::RegistrationStateEmail
  include ActiveMerchant::Billing::Integrations

  self.table_name               = 'ems_registrations'

  attr_accessible               :workshop_price_id, :discount_value, :discount_use_percent,
                                :payment_comment,
                                :registered_locale, :user_profile_attributes
  
  belongs_to                    :workshop, :counter_cache => true
  belongs_to                    :workshop_price
  belongs_to                    :user_profile
  belongs_to                    :account
  has_many                      :payment_histories, :as => :owner, :dependent => :destroy                              
  
  monetize                      :amount_paid_cents, :with_model_currency => :amount_paid_currency, :allow_nil => true
  
  accepts_nested_attributes_for :user_profile
  
  default_scope                 { where(account_id: Account.current.id) }
  scope                         :attending, where("(aasm_state = 'accepted' OR aasm_state = 'paid') AND archived_on IS NULL")

  before_create                 :set_currency
  after_create                  :set_receipt_code
  
  validates_presence_of         :workshop_price_id, :if => Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  validates_presence_of         :workshop_price_id, :if => Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  validates_numericality_of     :discount_value, allow_nil: true
  validates_length_of           :payment_comment, :maximum => 255
  
  delegate :first_name, :last_name, :full_name, :email, :address, :address2, :city, :state, :country, :zipcode, :phone, :to => :user_profile
  
  # The amount_paid currency should match the workshop base currency
  #------------------------------------------------------------------------------
  def set_currency
    self[:amount_paid_currency] = workshop.base_currency
  end
  
  # Receipt code: (workshop.id)-(registration.id).  eg.  003-101
  #------------------------------------------------------------------------------
  def set_receipt_code
    receipt_code = ("%03d" % workshop.id) + '-' + ("%03d" % self[:id])
    update_attribute(:receipt_code, receipt_code)
  end
  
  # receipt code is simply the record id + 1100
  #------------------------------------------------------------------------------
  def self.receiptcode_to_id(receiptcode)
    return receipt_code.split('-')[1].to_i
  end

  # Price of this registration (without discount)
  #------------------------------------------------------------------------------
  def price
    (workshop_price && workshop_price.price) ? workshop_price.price : Money.new(0, workshop.base_currency)
  end
  
  # Price with discount
  #------------------------------------------------------------------------------
  def discounted_price
    price - discount
  end
  
  #------------------------------------------------------------------------------
  def discount
    return Money.new(0, workshop.base_currency) if workshop_price.nil? || workshop_price.price.nil?

    unless discount_value.blank?
      cents = (discount_use_percent ? (workshop_price.price.cents * discount_value / 100) : (discount_value * 100))
    else
      cents = 0
    end
    Money.new(cents, workshop_price.price.currency)
  end

  # Return the amount still owed, based on the current payments made.
  # balance_owed is positive if payment is still required.  Negative if there
  # has been an overpayment
  #------------------------------------------------------------------------------
  def balance_owed
    discounted_price - amount_paid
  end
  
  # Return the number of items specified, in particular the number of items in 
  # a particular state
  #------------------------------------------------------------------------------
  def self.number_of(state, options = {})
    include_confirmed = (options[:only_confirmed] ? 'AND confirmed_on IS NOT NULL' : '')
    case state
    when :attending
      attending.count
    when :unpaid
      #--- the number of unpaid is the same as the number of accepted
      number_of(:accepted)
    when :checkedin
      where("checkin_at <> 0 AND archived_on IS NULL #{include_confirmed}").count
    when :archived
      where("archived_on IS NOT NULL #{include_confirmed}").count
    when :registrations
      #--- don't count any canceled
      where("aasm_state <> 'canceled' AND aasm_state <> 'refunded' AND archived_on IS NULL #{include_confirmed}").count
    when :at_price
      #--- number of registrations for a particular price
      where("(aasm_state = 'paid' OR aasm_state = 'accepted') AND workshop_price_id = #{options[:price_id]} AND archived_on IS NULL #{include_confirmed}").count
    when :for_all_prices
      #--- array of counts per price
      where("(aasm_state = 'paid' OR aasm_state = 'accepted') AND archived_on IS NULL #{include_confirmed}").count(:group => :workshop_price_id)
    when :user_updated
      #--- how many users updated their record
      where("user_updated_at IS NOT NULL AND (aasm_state = 'paid' OR aasm_state = 'accepted') AND archived_on IS NULL #{include_confirmed}").count
    when :confirmed
      #--- how many users confirmed their attendance
      where("confirmed_on IS NOT NULL AND (aasm_state = 'paid' OR aasm_state = 'accepted') AND archived_on IS NULL").count
    else
      #--- must be wanting to count the process states
      where("archived_on IS NULL #{include_confirmed}").count_in_state(state)
    end
  end

  # Setup the columns for exporting data as csv.
  #------------------------------------------------------------------------------
  def self.csv_columns
    column_definitions = []
    column_definitions <<     ["Receipt Code",      "'R-' + item.receipt_code", 75] # 'R-' makes sure Numbers treats as a String, not a Date
    column_definitions <<     ['Process State',     'item.aasm_state', 100]
    column_definitions <<     ["Full Name",         "item.full_name", 100]
    column_definitions <<     ["Last Name",         "item.last_name.capitalize", 100]
    column_definitions <<     ["First Name",        "item.first_name.capitalize", 100]
    column_definitions <<     ["Email",             "item.email.downcase", 150]
    column_definitions <<     ["Address",           "item.address", 150]
    column_definitions <<     ["Address2",          "item.address2"]
    column_definitions <<     ["City",              "item.city.capitalize", 100]
    column_definitions <<     ["State",             "item.state.capitalize"]
    column_definitions <<     ["Zipcode",           "item.zipcode"]
    column_definitions <<     ["Country",           "item.country.code"]

    column_definitions <<     ['Registered on',     'item.created_at.to_date', 75, {:type => 'DateTime', :numberformat => 'd mmm, yyyy'}]

    column_definitions <<     ["Price",             "item.workshop_price.price.to_f", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
    column_definitions <<     ["Price Description", "item.workshop_price.price_description"]
    column_definitions <<     ["Price Sub Descr",   "item.workshop_price.sub_description"]
    column_definitions <<     ["Discount",          "item.discount.to_f", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
    column_definitions <<     ["Paid",              "item.amount_paid.to_f", nil, {:type => 'Number', :numberformat => '#,##0.00'}]
    column_definitions <<     ["Balance",           "item.balance_owed.to_f", nil, {:type => 'Number', :numberformat => '#,##0.00'}]

    return column_definitions
  end

  # Payment was entered manually, create the history record.  You can tell it's 
  # a manual entry if the user_profile is filled in - means a human did it.
  #------------------------------------------------------------------------------
  def manual_payment(payment_history, cost, total_currency, user_profile,
                     options = { item_ref: '', payment_method: 'cash', bill_to_name: '', payment_date: Time.now,
                                 notify_data: nil, transaction_id: nil, status: '' } )
    amount            = Money.parse(cost, total_currency)
    
    if payment_history
      new_amount_paid = self.amount_paid - self.workshop_price.to_base_currency(payment_history.total) + self.workshop_price.to_base_currency(amount)
      payment_history.update_attributes(
        :item_ref             => options[:item_ref],
        :cost                 => cost,
        :total_cents          => amount.cents,
        :total_currency       => amount.currency.iso_code,
        :payment_method       => options[:payment_method],
        :bill_to_name         => options[:bill_to_name],
        :payment_date         => options[:payment_date],
        :user_profile_id      => user_profile.id)
    else
      new_amount_paid = self.amount_paid + self.workshop_price.to_base_currency(amount)
      payment_history   = self.payment_histories.create(
          :anchor_id            => receipt_code,
          :item_ref             => options[:item_ref],
          :cost                 => cost,
          :quantity             => 1,
          :discount             => 0,
          :total_cents          => amount.cents,
          :total_currency       => amount.currency.iso_code,
          :payment_method       => options[:payment_method],
          :bill_to_name         => options[:bill_to_name],
          :payment_date         => options[:payment_date],
          :user_profile_id      => (user_profile ? user_profile.id : nil),
          :notify_data          => options[:notify_data],
          :transaction_id       => options[:transaction_id],
          :status               => (user_profile ? "Completed" : options[:status])
      )
    end
        
    if payment_history.errors.empty?
      self.update_attribute(:amount_paid_cents, new_amount_paid.cents)
      self.reload
      self.send('paid!') if balance_owed.cents <= 0 && self.accepted?
    else
      logger.error("===> Error: Registration.manual_payment: #{payment_history.errors.inspect}")
    end
    return payment_history
  end

  # delete a payment and update the registrations total amount paid
  #------------------------------------------------------------------------------
  def delete_payment(payment_id)
    payment = PaymentHistory.find(payment_id)
    if payment
      self.update_attribute(:amount_paid_cents, (self.amount_paid - self.workshop_price.to_base_currency(payment.total)).cents)
      payment.destroy
      suppress_transition_email
      self.send('accept!') if balance_owed.cents > 0 && self.paid?
      return true
    end
    return false
  end

  # Return the payment page url, so that it can be used in emails
  #------------------------------------------------------------------------------
  def payment_url
    DmEvent::Engine.routes.url_helpers.register_choose_payment_url(self.receipt_code, host: Account.current.url_host, locale: I18n.locale)
  end
  
  # Handle PayPal notification logic
  #------------------------------------------------------------------------------
  def self.paypal_ipn(notify)
    logger.error('===> Enter: Registration.paypal_ipn')
    logger.error(notify.inspect)
    registration = Registration.find_by_receipt_code(notify.item_id)
    
    if notify.acknowledge
      if registration
        logger.error(registration.inspect)
        payment_history = PaymentHistory.find_by_transaction_id(notify.transaction_id) ||
                            registration.manual_payment( nil,
                                          notify.amount.to_f.to_s,
                                          notify.currency,
                                          nil,
                                          payment_method: 'paypal',
                                          payment_date: notify.received_at,
                                          notify_data: notify,
                                          transaction_id: notify.transaction_id,
                                          status: notify.status
                      )
          logger.error(payment_history.inspect)
        begin
          if notify.complete?
            payment_history.status = notify.status
          else
            # TODO need to handle refunding, etc
            logger.error("Failed to verify Paypal's notification, please investigate")
          end
        rescue => e
          payment_history.status = 'Error'
          raise
        ensure
          payment_history.save
        end
      else
        #--- [todo] a linked registration was not found.  Should be stored in payment table anyway
        logger.error("   > Error: Registration was not found: #{notify.item_id}")
      end
    end
  end


=begin
  acts_as_reportable
  acts_as_commentable
  acts_as_taggable_on     :publictags, :privatetags
  
  has_and_belongs_to_many :studentgroup, :uniq => true   #--- TODO have no idea what this is used for
  has_many                :custom_fields, :as => :owner, :dependent => :destroy

  has_many                :payment_histories, :as => :owner, :dependent => :destroy
  has_many                :payment_histories_old, :class_name => 'PaymentHistory', 
                            :finder_sql => 'SELECT payment_histories.* ' +
                              'FROM payment_histories ' +
                              'WHERE #{receiptcode} = payment_histories.anchor_id'
                              
  has_one                 :photo, :class_name => 'EventRegistrationPhoto', :dependent => :destroy
  
  #=== validation rules
  validates_uniqueness_of :token
  validates_length_of     :heardabout,            :maximum => 50,   :allow_nil => true
  validates_presence_of   :heardabout,                              :if => Proc.new { |reg| reg.event_workshop.heardabout_required}
  validates_length_of     :roomate_pref,          :maximum => 255,  :allow_nil => true
  validates_presence_of   :roomate_pref,                            :if => Proc.new { |reg| reg.event_workshop.show_rooming}
  
  validates_with               EventRegistrationValidator

  #validates_associated         :custom_fields

  # --- because Europe doesn't really have states, dont' require or show it unless US
  # validates_presence_of       :state,       :message => "is a required field"

  attr_accessor               :substitutions  
  
  before_create               :set_name
  before_create               :set_token
  

  
  # Determine if any of the custom fields had a validation error when updating
  # their data
  #------------------------------------------------------------------------------
  def custom_field_errors?
    custom_fields.each do |field|
      return true if field.errors.size > 0
    end
    return false
  end
  
  #------------------------------------------------------------------------------
  def custom_field_attributes=(custom_field_attributes)
    custom_field_attributes.each_value do |attributes|
      #--- make sure its a valid custom field def
      if event_workshop.custom_field_defs.find_by_id(attributes['custom_field_def_id'])
        #--- update existing field if it exists, otherwise create it
        field = custom_fields.detect { |f| f.custom_field_def_id == attributes[:custom_field_def_id].to_i }
        if field.nil? 
          custom_fields.build(attributes) 
        else
          #--- Create temporary field so that data is munged correctly, then update the actual field
          temp  = CustomField.new(attributes)
          valid = field.update_attributes(:data => temp.data)
          errors.add(:base, field.errors.full_messages[0]) unless valid
        end        
      end
      
      #--- sort the fields so they continue to appear in the correct order
      custom_fields.sort! { |x, y| x.position <=> y.position }
    end
  end
  
  # returns true if there are any custom fields that are not blank and are marked
  # show_in_list
  #------------------------------------------------------------------------------
  def custom_fields_visible?
    custom_fields.any? {|x| !x.data.blank? and x.show_in_list? }
  end
  

  # The token is used to access the registration by a user without logging in
  # so that they can update any relevant details.
  # before_create hook
  #------------------------------------------------------------------------------
  def set_token
    self[:token] = HashcodeGenerator.generate(40) if self[:token].blank?
  end
  
  #------------------------------------------------------------------------------
  def mark_paid(plus_amount = 0)
    update_attribute(:amount, (self.amount + plus_amount))
    send('paid!')
  end

  #------------------------------------------------------------------------------
  def verify_payment
    update_attribute(:payment_verified_at, Time.now)    
  end
  
  #------------------------------------------------------------------------------
  def updates_allowed?
    if attending? && event_workshop.no_student_updates == true
      return false
    else
      return true
    end
  end
  
  # state_and_country
  #------------------------------------------------------------------------------
  def state_and_country
    if student.nil?
      output = ""
      output = state + ", " unless state.blank?
      output << country.english_name 
    else
      student.state_and_country
    end
  end

  # A comment was posted.  If the student did not post it, then send an email to the
  # student notifiying them.
  #------------------------------------------------------------------------------
  def comment_notify(comment)
    if comment.user != student.user
      receipt_content = compile_comment(comment)
      
      return RegistrationNotifyMailer.comment_notify(self, receipt_content[:content], receipt_content[:substitutions]).deliver
    end
  end

  # Compile the email values
  #------------------------------------------------------------------------------
  def compile_comment(comment)
    substitutions = {
      'state'   => state.to_s,
      'event'   => self.to_liquid,
    }
    substitutions['subject']  = "#{event_workshop.title}: New comment..."

    template  = Liquid::Template.parse(comment.comment)
    content   = template.render(substitutions)
    return {:content => content, :substitutions => substitutions}
  end

  # Is it ok to display this to the user?  If it's a rejected or canceled
  # registration, then we don't want to show it.  Or if the workshop has 
  # already past
  #------------------------------------------------------------------------------
  def visible_to_user?
    !(event_workshop.past? or process_state == 'rejected' or process_state == 'canceled')
  end

  # Has the person been checked in yet?
  #------------------------------------------------------------------------------
  def checkedin?
    !checkin_at.nil?
  end

  # Has the person been checked in yet?
  #------------------------------------------------------------------------------
  def has_photo?
    !photo.nil? or (!student.nil? and !student.photo.nil?)
  end

  #------------------------------------------------------------------------------
  def is_subscribed?(newsletter_tag)
    if student.nil?
      newsletter = Newsletter.find_by_idtag(newsletter_tag)
      newsletter.nil? ? false : newsletter.email_subscribed?(email)
    else
      student.is_subscribed?(newsletter_tag)
    end
  end
  
  # Has this registration been user_updated?
  #------------------------------------------------------------------------------
  def user_updated?
    !user_updated_at.nil?
  end

  # Has this registration been confirmed?
  #------------------------------------------------------------------------------
  def confirmed?
    !confirmed_on.nil?
  end

  # toggle the confirmed state of the workshop
  #------------------------------------------------------------------------------
  def toggle_confirm
    confirmed? ? update_attribute(:confirmed_on, nil) : update_attribute(:confirmed_on, Time.now)
  end

  # Is this registration archived?
  #------------------------------------------------------------------------------
  def archived?
    !archived_on.nil?
  end

  # toggle the archive state of the workshop
  #------------------------------------------------------------------------------
  def toggle_archive
    archived? ? update_attribute(:archived_on, nil) : update_attribute(:archived_on, Time.now)
  end

  # clear the confirmed_on and user_updated_at fields
  #------------------------------------------------------------------------------
  def self.clear_confirmed_updated
    find(:all).each do |registration|
      registration.update_attribute(:confirmed_on, nil) if registration.confirmed?
      registration.update_attribute(:user_updated_at, nil) if registration.user_updated?
    end
  end

  # We allow the date to be NULL, but when sorting it can cause problems.  Use 
  # this instead
  #------------------------------------------------------------------------------
  def arrival_at_sortable
    arrival_at.nil? ? DateTime.new(0) : arrival_at
  end

  # We allow the date to be NULL, but when sorting it can cause problems.  Use 
  # this instead
  #------------------------------------------------------------------------------
  def departure_at_sortable
    departure_at.nil? ? DateTime.new(0) : departure_at
  end
  
  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_students_per_country
    find( :all, 
          :select => 'event_registrations.id, students.visited_penukonda, students.firstname, students.lastname, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.archived_on, event_registrations.confirmed_on, globalize_countries.english_name', 
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
           INNER JOIN student_extras ON students.id = student_extras.student_id
           INNER JOIN globalize_countries ON students.country_id = globalize_countries.id',
          :order => 'firstname, lastname')
  end

  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_accepted
    find( :all, 
          :select => 'event_registrations.id, event_registrations.archived_on, student_extras.speak_english, students.firstname, students.lastname, globalize_countries.english_name', 
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
           INNER JOIN student_extras ON students.id = student_extras.student_id
           INNER JOIN globalize_countries ON students.country_id = globalize_countries.id',
          :order => 'firstname, lastname')
  end

  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_students_per_group
    find( :all,
          :select => 'event_registrations.id as reg_id, event_registrations.archived_on, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.checkin_at, event_registrations.confirmed_on, event_registrations.room_id, students.firstname, students.lastname, students.visited_penukonda, students.localcell, studentgroups.id, studentgroups.name', 
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN studentgroups_students ON students.id = studentgroups_students.student_id
             INNER JOIN studentgroups ON studentgroups_students.studentgroup_id = studentgroups.id',
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND studentgroups.historical = 0 AND event_registrations.archived_on IS NULL",
          :order => 'arrival_at ASC')
  end

  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_students_per_group_checked_in
    find( :all,
          :select => 'event_registrations.id as reg_id, event_registrations.archived_on, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.checkin_at, event_registrations.room_id, students.firstname, students.lastname, students.visited_penukonda, students.localcell, studentgroups.id, studentgroups.name', 
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN studentgroups_students ON students.id = studentgroups_students.student_id
             INNER JOIN studentgroups ON studentgroups_students.studentgroup_id = studentgroups.id',
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND studentgroups.historical = 0 AND event_registrations.archived_on IS NULL AND event_registrations.checkin_at IS NOT NULL",
          :order => 'arrival_at ASC')
  end

  # Get the list of groups that have people attending
  #------------------------------------------------------------------------------
  def self.report_attending_group_list
    find( :all,
          :select => 'DISTINCT studentgroups.id, studentgroups.name', 
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN studentgroups_students ON students.id = studentgroups_students.student_id
             INNER JOIN studentgroups ON studentgroups_students.studentgroup_id = studentgroups.id',
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND studentgroups.historical = 0 AND event_registrations.archived_on IS NULL",
          :order => 'studentgroups.name ASC')
  end
  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_students_no_group
    find( :all,
          :select => 'event_registrations.id as reg_id, event_registrations.archived_on, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.confirmed_on, event_registrations.checkin_at, event_registrations.room_id, students.firstname, students.lastname, students.visited_penukonda, students.localcell, globalize_countries.english_name', 
          :joins  => 'event_registrations INNER JOIN students on students.id = event_registrations.student_id 
                      LEFT JOIN studentgroups_students on students.id = studentgroups_students.student_id
                      INNER JOIN globalize_countries ON students.country_id = globalize_countries.id',
          :conditions => "studentgroups_students.student_id IS NULL AND (event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :order => 'arrival_at ASC')
  end

  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_students_per_tag
    find( :all,
          :select => 'event_registrations.id as reg_id, event_registrations.archived_on, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.checkin_at, event_registrations.room_id, students.firstname, students.lastname, students.visited_penukonda, students.localcell, tags.id, tags.name', 
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
            INNER JOIN taggings ON taggings.taggable_id = event_registrations.id
            INNER JOIN tags ON tags.id = taggings.tag_id',
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND taggings.taggable_type = 'EventRegistration' AND event_registrations.archived_on IS NULL",
          :order => 'arrival_at ASC')
  end

  # Generate a list of students, returning a small set of the total information
  #------------------------------------------------------------------------------
  def self.report_rooming_list
    find( :all,
          :select => 'event_registrations.id as reg_id, event_registrations.archived_on, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.checkin_at, rooms.number, rooms.floor, rooms.building, students.firstname, students.lastname, students.localcell', 
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN rooms ON rooms.id = event_registrations.room_id',
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :order => 'number ASC')
  end

  # Generate a list of students with arrival/departure dates
  #------------------------------------------------------------------------------
  def self.report_arrival_departure
    find_all_by_process_state('accepted', :include => [:student], :conditions => ' event_registrations.archived_on IS NULL')
  end

  # Generate a list of students with arrival/departure dates
  #------------------------------------------------------------------------------
  def self.report_firsttime
    find_all_by_process_state('accepted', :include => [:student], :conditions => 'students.visited_penukonda = 0 AND event_registrations.archived_on IS NULL', :order => 'arrival_at')
  end

  # Generate a list of students with arrival/departure dates
  #------------------------------------------------------------------------------
  def self.report_teachers
    find( :all,
          :select => 'event_registrations.id as reg_id, event_registrations.archived_on, event_registrations.arrival_at, event_registrations.departure_at, event_registrations.confirmed_on, event_registrations.checkin_at, event_registrations.room_id, students.firstname, students.lastname, students.visited_penukonda, students.localcell, teachers.id', 
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN teachers ON students.id = teachers.student_id',
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :order => 'arrival_at ASC')
  end

  # Generate a list of students with their roommates
  #------------------------------------------------------------------------------
  def self.report_roomates
    find( :all, 
          :select => 'event_registrations.id, event_registrations.archived_on, students.firstname, students.lastname, event_registrations.departure_at, event_registrations.arrival_at, event_registrations.roomate_pref, students.gender, students.dob, globalize_countries.english_name', 
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN student_extras ON students.id = student_extras.student_id
             INNER JOIN globalize_countries ON students.country_id = globalize_countries.id',
          :order => 'event_registrations.arrival_at ASC, firstname ASC, lastname ASC')
  end

  # Generate a list of students with their roommates
  #------------------------------------------------------------------------------
  def self.report_medical
    find( :all, 
          :select => 'event_registrations.id, event_registrations.archived_on, students.firstname, students.lastname, event_registrations.arrival_at, students.dob, students.gender, event_registrations.health_conditions, event_registrations.medication_allergies, event_registrations.psych_care, event_registrations.special_requirements', 
          :conditions => "(event_registrations.process_state = 'accepted' OR event_registrations.process_state = 'paid') AND event_registrations.archived_on IS NULL",
          :joins => 'event_registrations INNER JOIN students ON event_registrations.student_id = students.id
             INNER JOIN student_extras ON students.id = student_extras.student_id
             INNER JOIN globalize_countries ON students.country_id = globalize_countries.id',
          :order => 'firstname, lastname')
  end

  # Create a new registration object based on the values from an existing registration
  #------------------------------------------------------------------------------
  def self.new_registration_from_old(workshop_id, old_registration)
    return EventRegistration.new( :event_workshop_id => workshop_id, 
                                  :process_state => "pending", 
                                  :country_id => old_registration.country_id,
                                  :arrival_at => old_registration.arrival_at,
                                  :departure_at => old_registration.departure_at,
                                  :roomate_pref => old_registration.roomate_pref,
                                  :health_conditions => old_registration.health_conditions,
                                  :medication_allergies => old_registration.medication_allergies,
                                  :special_requirements => old_registration.special_requirements,
                                  :psych_care => old_registration.psych_care,
                                  :checkin_at => old_registration.checkin_at,
                                  :confirmed_on => old_registration.confirmed_on
                                )
  end
=end
  
end

=begin
#------------------------------------------------------------------------------
class RegistrationValidator < ActiveModel::Validator

  def validate(record)
    #--- if the show_spiritual flag is set, then require those fields to be filled in
    if record.event_workshop.show_spiritual
       record.errors[:base] << "Spiritual History section can't be blank" unless record.student.student_extra.spiritual_valid?
    end

    selected_country = StateCountryConstants::COUNTRIES_WITH_STATES.find {|x| x[:id] == record.country_id}
    record.errors[:state] << "is a required field" if selected_country and record.state.blank? and record.student_id.nil?

    #--- do validation of custom fields here, so that we get the proper error messages
    record.custom_fields.each do |field|
      if field.required? and field.visible? and field.data.blank?
        record.errors[:base] << "#{field.human_attribute_name(false)} is a required field"
      end
    end
  end

end

=end