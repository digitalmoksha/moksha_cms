# require 'digest/sha1'

#------------------------------------------------------------------------------
class Registration < ActiveRecord::Base
  include DmEvent::Concerns::RegistrationStateMachine
  include DmEvent::Concerns::RegistrationStateEmail
  
  self.table_name         = 'ems_registrations'

  attr_accessible         :workshop_price_id
  
  belongs_to              :workshop, :counter_cache => true
  belongs_to              :workshop_price
  belongs_to              :user
  belongs_to              :account
  
  default_scope           { where(account_id: Account.current.id) }

  after_create            :set_receipt_code
  
  validates_presence_of   :workshop_price_id,      :message => "Please select a payment option", :if => Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  
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

  #------------------------------------------------------------------------------
  def price
    workshop_price ? workshop_price.price : 'n/a'
  end
  
  #------------------------------------------------------------------------------
  def full_name
    user.full_name
  end

  #------------------------------------------------------------------------------
  def email_address
    user.email
  end
  
  
  
=begin
  acts_as_reportable
  acts_as_commentable
  acts_as_taggable_on     :publictags, :privatetags
  
  belongs_to              :country
  belongs_to              :event_payment
  has_and_belongs_to_many :studentgroup, :uniq => true   #--- TODO have no idea what this is used for
  has_many                :payment_histories_old, :class_name => 'PaymentHistory', 
                            :finder_sql => 'SELECT payment_histories.* ' +
                              'FROM payment_histories ' +
                              'WHERE #{receiptcode} = payment_histories.anchor_id'
                              
  has_many                :custom_fields, :as => :owner, :dependent => :destroy
  has_many                :payment_histories, :as => :owner, :dependent => :destroy

  has_one                 :photo, :class_name => 'EventRegistrationPhoto', :dependent => :destroy
  
  #=== validation rules
  validates_uniqueness_of :token
  validates_length_of     :heardabout,            :maximum => 50,   :allow_nil => true
  validates_presence_of   :heardabout,                              :if => Proc.new { |reg| reg.event_workshop.heardabout_required}
  validates_length_of     :roomate_pref,          :maximum => 255,  :allow_nil => true
  validates_presence_of   :roomate_pref,                            :if => Proc.new { |reg| reg.event_workshop.show_rooming}
  
  validates_length_of     :health_conditions,     :maximum => 255,  :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_presence_of   :health_conditions,                       :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_length_of     :medication_allergies,  :maximum => 255,  :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_presence_of   :medication_allergies,                    :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_length_of     :special_requirements,  :maximum => 255,  :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_presence_of   :special_requirements,                    :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_length_of     :psych_care,            :maximum => 255,  :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_presence_of   :psych_care,                              :if => Proc.new { |reg| reg.event_workshop.show_medical}
  validates_presence_of   :arrival_at,                              :if => Proc.new { |reg| reg.event_workshop.show_arrival_departure}
  validates_presence_of   :departure_at,                            :if => Proc.new { |reg| reg.event_workshop.show_arrival_departure}

  #--- validates used for a registration that is not associated with a student account
  validates_presence_of        :country,           :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id }
  validates_presence_of        :email,             :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id }
  validates_presence_of        :firstname,         :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id }
  validates_presence_of        :lastname,          :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id }
  validates_presence_of        :address,           :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id and reg.event_workshop.require_address }
  validates_presence_of        :city,              :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id and reg.event_workshop.require_address }
  validates_presence_of        :zipcode,           :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id and reg.event_workshop.require_address }
  validates_presence_of        :phone,             :message => "is a required field",  :if => Proc.new { |reg| !reg.student_id and reg.event_workshop.require_address }
  validates_length_of          :email,             :maximum => 60,                        :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :address,           :maximum => 70,                        :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :address2,          :maximum => 70,  :allow_nil => true,   :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :city,              :maximum => 20,                        :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :state,             :maximum => 30,                        :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :zipcode,           :maximum => 10,  :allow_nil => true,   :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :phone,             :maximum => 20,  :allow_nil => true,   :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :fax,               :maximum => 20,  :allow_nil => true,   :if => Proc.new { |reg| !reg.student_id }
  validates_length_of          :cell,              :maximum => 20,  :allow_nil => true,   :if => Proc.new { |reg| !reg.student_id }
  validates_email_veracity_of  :email,                                                    :if => Proc.new { |reg| !reg.student_id }

  validates_with               EventRegistrationValidator

  #validates_associated         :custom_fields

  # --- because Europe doesn't really have states, dont' require or show it unless US
  # validates_presence_of       :state,       :message => "is a required field"

  composed_of                 :price, :class_name => 'Money', :mapping => [%w(amount cents)]
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
  

  # before_create hook
  #------------------------------------------------------------------------------
  def set_name
    if self.student
      self[:firstname] = student.firstname
      self[:lastname]  = student.lastname
    end
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
  
  #------------------------------------------------------------------------------
  def amount_formatted(empty_string = "")
    (paid? || amount > 0) ? ut_currency_cents(amount, event_payment.country) : empty_string
  end
  
  # Return the amount (in cents) still owed, based on the current payments made.
  # balance_owed is positive if payment is still required.  Negative if there
  # has been an overpayment
  #------------------------------------------------------------------------------
  def balance_owed(formatted = false)
    balance = total_amount_cents - amount
    return (formatted && !event_payment.nil?) ? ut_currency_cents(balance, event_payment.country) : balance
  end
  
  #------------------------------------------------------------------------------
  def purchased_amount_cents
    (event_payment.nil? || event_payment.amount.nil?) ? 0 : (event_payment.amount * 100)
  end
  
  #------------------------------------------------------------------------------
  def total_amount_cents(formatted = false)
    total = purchased_amount_cents - discount_cents
    return (formatted && !event_payment.nil?) ? ut_currency_cents(total, event_payment.country) : total
  end
  
  #------------------------------------------------------------------------------
  def discount_cents
    if discount_value.blank?
      0
    else
      if discount_use_percent
        purchased_amount_cents * discount_value / 100
      else
        (discount_value * 100)
      end
    end
  end
  
  #------------------------------------------------------------------------------
  def discount_formatted(empty_string = "")
    ut_currency_cents(discount_cents, event_payment.country)
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
  
  # Return the number of items specified, in particular the number of items in 
  # a particular state
  #------------------------------------------------------------------------------
  def self.number_of(state, options = {})
    include_confirmed = (options[:only_confirmed] ? 'AND confirmed_on IS NOT NULL' : '')
    case state
    when :attending
      number_of(:paid) + number_of(:accepted)
    when :unpaid
      #--- the number of unpaid is the same as the number of accepted
      number_of(:accepted)
    when :checkedin
      count(:conditions => "checkin_at <> 0 AND archived_on IS NULL #{include_confirmed}")
    when :archived
      count(:conditions => "archived_on IS NOT NULL #{include_confirmed}")
    when :registrations
      #--- don't count any canceled
      count(:conditions => "process_state <> 'canceled' AND process_state <> 'refunded' AND archived_on IS NULL #{include_confirmed}")
    when :registrations_by_paymenttype
      #--- number of registrations paid with a particular payment type
      count(:conditions => "(process_state = 'paid' OR process_state = 'accepted') AND event_payment_id = #{options[:payment_id]} AND archived_on IS NULL #{include_confirmed}")
    when :user_updated
      #--- how many users updated their record
      count(:conditions => "user_updated_at IS NOT NULL AND (process_state = 'paid' OR process_state = 'accepted') AND archived_on IS NULL #{include_confirmed}")
    when :confirmed
      #--- how many users confirmed their attendance
      count(:conditions => "confirmed_on IS NOT NULL AND (process_state = 'paid' OR process_state = 'accepted') AND archived_on IS NULL")
    else
      #--- must be wanting to count the process states
      count(:conditions => "process_state = '#{state.to_s}' AND archived_on IS NULL #{include_confirmed}")
    end
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