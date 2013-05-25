class Workshop < ActiveRecord::Base

  self.table_name         = 'ems_workshops'

  belongs_to              :country, :class_name => 'DmCore::Country'
  has_many                :registrations, :dependent => :destroy
  has_many                :workshop_prices, :dependent => :destroy
  has_many                :system_emails,     {:as => :emailable, :dependent => :destroy}
  has_one                 :pending_email,     :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'pending'"
  has_one                 :accepted_email,    :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'accepted'"
  has_one                 :rejected_email,    :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'rejected'"
  has_one                 :paid_email,        :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'paid'"
  has_one                 :waitlisted_email,  :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'waitlisted'"
  has_one                 :reviewing_email,   :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'reviewing'"
  has_one                 :canceled_email,    :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'canceled'"
  has_one                 :refunded_email,    :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'refunded'"
  has_one                 :noshow_email,      :class_name => 'SystemEmail', :as => :emailable, :conditions => "email_type LIKE 'noshow'"
  
  attr_accessible         :title, :description, :country_id, :starting_on, :ending_on, :deadline_on, :info_url,
                          :contact_email, :contact_phone, :require_review, :require_account, :require_address,
                          :require_photo

  # --- globalize
  translates              :title, :description, :fallbacks_for_empty_translations => true
  globalize_accessors     :locals => DmCore::Language.language_array

  extend FriendlyId
  friendly_id             :title_slug, use: :slugged
  resourcify

  default_scope           { where(account_id: Account.current.id) }

  validates_presence_of   :starting_on
  validates_presence_of   :ending_on
  validates_presence_of   :deadline_on

  scope                   :upcoming,  :conditions => ["ending_on > ? AND archived_on IS NULL", (Date.today - 1).to_s], :order => 'starting_on DESC'
  scope                   :past,      :conditions => ["ending_on <= ? AND archived_on IS NULL", (Date.today - 1).to_s], :order => 'starting_on DESC'

  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  # If the total_available is nil, then there are unlimited tickets to be sold.  
  # Otherwise, check if we have sold out
  #------------------------------------------------------------------------------
  def price_sold_out?(workshop_price)
    # p.sold_out?(@workshop.event_registration.number_of(:registrations_by_paymenttype, :payment_id => p.id)
    false # TODO
  end
  
  # Is this workshop in the past?  
  #------------------------------------------------------------------------------
  def past?
    ending_on < Time.now
  end
  
  # Is the registration closed
  #------------------------------------------------------------------------------
  def registration_closed?
    deadline_on < Time.now.to_date
  end

  # toggle the archive state of the workshop
  #------------------------------------------------------------------------------
  def toggle_archive
    archived_on ? update_attribute(:archived_on, nil) : update_attribute(:archived_on, Time.now)
  end
  
  #------------------------------------------------------------------------------
  def archived?
    self.archived_on ? true : false
  end

  
=begin
  
  has_many    :event_registrations_attending, :class_name => 'EventRegistration', :conditions => "(process_state = 'accepted' OR process_state = 'paid') AND archived_on IS NULL", :order => "arrival_at ASC"
  has_many    :event_payment, :order => :position, :dependent => :destroy
  has_one     :event_venue
  has_many    :custom_field_defs, :as => :owner, :order => 'position', :dependent => :destroy
  has_many    :email_campaigns, :as => :campaignable
  has_many    :rooms

  # [todo] need to use lambda to make the date work correctly.
  scope       :upcoming,   :conditions => ["enddate > ? AND archived_on IS NULL", (Date.today - 1).to_s], :order => 'startdate DESC'

  # --- {todo} add more validations
  validates_length_of     :heardabout_list,       :maximum => 255, :allow_nil => true
  validates_length_of     :invitation_code,       :maximum => 255, :allow_nil => true
  validates_associated    :custom_field_defs
  validates_email_veracity_of  :contact_email

  validates_presence_of   :title
  validates_presence_of   :country_id
  validates_presence_of   :contact_email
  
  after_save              :after_save_remove_associated_privileges
  after_update            :save_custom_field_defs

  # When a workshop becomes archived, all access to it gets removed (other than admins)
  #------------------------------------------------------------------------------
  def after_save_remove_associated_privileges
    self.accepted_roles.each { |r| r.destroy } if archived? 
  end
    
  #------------------------------------------------------------------------------
  def new_custom_field_def_attributes=(custom_field_def_attributes)
    custom_field_def_attributes.each do |attributes|
      custom_field_defs.build(attributes)
    end
  end

  #------------------------------------------------------------------------------
  def existing_custom_field_def_attributes=(custom_field_def_attributes) 
    custom_field_defs.reject(&:new_record?).each do |custom_field_def|
      attributes = custom_field_def_attributes[custom_field_def.id.to_s] 
      if attributes 
        custom_field_def.attributes = attributes 
      else 
        custom_field_defs.delete(custom_field_def) 
      end 
    end 
  end 
  
  # Used to save existing, updated fields
  #------------------------------------------------------------------------------
  def save_custom_field_defs
    custom_field_defs.each do |c| 
      c.save(:validate => false)
    end 
  end 

  # Sometimes we request the "name" of an object - return the title 
  #------------------------------------------------------------------------------
  def name
    title
  end
  
  #------------------------------------------------------------------------------
  def member_of?(student_obj)
    return false if student_obj.nil?
    (e = event_registration.find_by_student_id(student_obj.id)) ? e.attending? : false
  end
  
  #------------------------------------------------------------------------------
  def registered?(student_obj)
    return false if student_obj.nil?
    (e = event_registration.find_by_student_id(student_obj.id)) ? e.registered? : false
  end
  
  # Choose the primary currency to be the currency of the first payment currency,
  # or the workshop's country
  #------------------------------------------------------------------------------
  def primary_currency
    if event_payment.empty?
      return country
    else
      return event_payment[0].country
    end
  end
  
  #------------------------------------------------------------------------------
  def heardabout_collection
    self.heardabout_list.blank? ? nil : self.heardabout_list.split(",")
  end
  
  # Return array of all registrations (that have not been canceled)
  #------------------------------------------------------------------------------
  def registration_dates
    EventRegistration.find_by_sql("SELECT created_at FROM event_registrations WHERE event_workshop_id = #{self.id} AND process_state <> 'canceled' ORDER BY created_at ASC")
  end

  # Create a hash of arrival/departure values per day, indexed by (yday + year*1000) eg. 2010256
  # stat[2010265] = {:departures, :arrivals, :total}
  #------------------------------------------------------------------------------
  def generate_arrival_departure_numbers(days_before = 30, days_after = 30)
    stats = []
    event_registrations_attending.each do |registration|
      arrival_index = registration.arrival_at.to_datetime.to_index
      stats[arrival_index] = {:arrival => 0, :departure => 0, :total => 0, :date => registration.arrival_at.to_datetime} if stats[arrival_index].nil?
      stats[arrival_index][:arrival] += 1
      
      departure_index = registration.departure_at.to_datetime.to_index
      stats[departure_index] = {:arrival => 0, :departure => 0, :total => 0, :date => registration.departure_at.to_datetime} if stats[departure_index].nil?
      stats[departure_index][:departure] += 1
    end

    #--- remove null entries
    stats.delete_if { |x| x.nil? }
    
    #--- calculate the day totals
    total = 0
    stats.each do |x|
      total = total + x[:arrival] - x[:departure]
      x[:total] = total
    end

    #--- remove any days outside of the specified range
    stats.delete_if { |x| (x[:date] < (startdate - days_before.days)) || (x[:date] > (startdate + days_after.days)) }
    return stats
  end
  
  # Return the number of registrations for a particular payment type
  #------------------------------------------------------------------------------
  def registrations_by_paymenttype
    itemArray = Array.new
    self.event_payment.each do |p|
        payment_count           = event_registration.number_of(:registrations_by_paymenttype, :payment_id => p.id)
        payment_count_confirmed = event_registration.number_of(:registrations_by_paymenttype, :payment_id => p.id, :only_confirmed => true)
        itemArray << {:description => p.payment_desc, :count => payment_count, :confirmed_count => payment_count_confirmed, :amount => p.amount, :country => p.country, :sold_out => p.sold_out?(payment_count)}
      end
    return itemArray
  end

  # Return financial summary and details
  #------------------------------------------------------------------------------
  def financial_details(level = :detail)
    financials = {:summary => { :total_possible => 0, :total_possible_worst => 0, :total_paid => 0, :total_outstanding => 0, :total_outstanding_worst => 0,
                                :confirmed_total_possible => 0, :confirmed_total_possible_worst => 0, :confirmed_total_paid => 0, :confirmed_total_outstanding => 0, :confirmed_total_outstanding_worst => 0},
                  :collected => {},
                  :collected_monthly => {},
                  :payment_type => {},
                  :projected => {}}
    event_registrations_attending.each do |registration|
      unless registration.event_payment.nil?
        #--- Calculate the summary values
        financials[:summary][:total_possible]     += registration.total_amount_cents
        financials[:summary][:total_paid]         += registration.amount.nil? ? 0 : registration.amount
        financials[:summary][:total_outstanding]  += registration.balance_owed
        if registration.confirmed?
          financials[:summary][:confirmed_total_possible]     += registration.total_amount_cents
          financials[:summary][:confirmed_total_paid]         += registration.amount.nil? ? 0 : registration.amount
          financials[:summary][:confirmed_total_outstanding]  += registration.balance_owed
        end
        
        if level == :detail
          #--- Calculate possible amount for each payment type
          payment_type = EventPayment::PAYMENT_TYPES[registration.event_payment.payment_type]
          financials[:payment_type]["#{payment_type}"] = 0 if financials[:payment_type]["#{payment_type}"].nil?
          financials[:payment_type]["#{payment_type}"] += registration.total_amount_cents

          #--- Calculate what has been collected, by payment method
          registration.payment_histories.each do |payment_history|
            financials[:collected]["#{payment_history.payment_method}"] = 0 if financials[:collected]["#{payment_history.payment_method}"].nil?
            financials[:collected]["#{payment_history.payment_method}"] += payment_history.total_cents

            month = payment_history.payment_date.beginning_of_month
            financials[:collected_monthly][month] = 0 if financials[:collected_monthly][month].nil?
            financials[:collected_monthly][month] += payment_history.total_cents
          end
          
          #--- Calculate payment projection
          unless registration.event_payment.recurring_number.blank?
            payment_date = registration.created_at
            registration.event_payment.recurring_number.times do
              month = payment_date.beginning_of_month
              financials[:projected][month] = 0 if financials[:projected][month].nil?
              financials[:projected][month] += (registration.event_payment.recurring_amount * 100)
              payment_date += registration.event_payment.recurring_period.days
            end
          else
            if registration.event_payment.payment_type == 'cc'
              #--- since it's a credit card, payment should have been immediate
              month = registration.created_at.beginning_of_month
            else
              #--- cash, check, wire, donation: assume that payment will be made on the day of the event
              month = self.startdate.beginning_of_month
            end
            financials[:projected][month] = 0 if financials[:projected][month].nil?
            financials[:projected][month] += registration.total_amount_cents
          end
        end
      end
    end
    
    #--- give a worst case value - reduce by 20%
    financials[:summary][:total_possible_worst]               = financials[:summary][:total_possible] * 0.80
    financials[:summary][:total_outstanding_worst]            = financials[:summary][:total_outstanding] * 0.80
    financials[:summary][:confirmed_total_possible_worst]     = financials[:summary][:confirmed_total_possible] * 0.80
    financials[:summary][:confirmed_total_outstanding_worst]  = financials[:summary][:confirmed_total_outstanding] * 0.80
    
    return financials
  end

  # if an invite code is valid (invitation_code is a space or comma seperated list)
  #------------------------------------------------------------------------------
  def valid_invitation?(invite_code)
    return true if invitation_code.blank?
    invitation_code.downcase.scan(/\w+/) { |word| return true if word == invite_code }
    return false
  end
  
  # find the tags associated with the registrations in this workshop and calculate
  # their popularity
  # Searches all registrations, not just attending.
  #------------------------------------------------------------------------------
  def find_registration_tags(tag_context)
    event_registration.tag_counts_on(tag_context).order('name ASC')
  end

  #------------------------------------------------------------------------------
  def create_duplicate
    new_workshop = EventWorkshop.create(attributes.merge({:title => "(Duplicate) #{title}"}))
    event_payment.each { |payment| new_workshop.event_payment.create(payment.attributes) }
    copy_custom_fields_to(new_workshop)
    return new_workshop
  end

  # Adds all people attending (paid or accepted) to a specific group
  #------------------------------------------------------------------------------
  def add_attendees_to_group(studentgroup)
    event_registration.each do |registration|
      studentgroup.add_to_group(registration.student) if registration.attending? and !registration.student.nil?
    end
  end

  # This is a special, seldom used function to tag registrants with their group name
  #------------------------------------------------------------------------------
  def create_tag_of_group(studentgroup, tag_name)
    event_registration.each do |registration|
      registration._add_tags(tag_name) if studentgroup.member_of?(registration.student)
    end
  end
  
  # Currently, rooms are only associated with a particular workshop.  This copies
  # the rooming list from one workshop to another
  #------------------------------------------------------------------------------
  def copy_rooms_to(workshop)
    workshop.event_registration.each do |to_registration|
      unless to_registration.student.nil?
        from_registration = event_registration.find_by_student_id(to_registration.student.id)
        to_registration.update_attribute(:room_id, from_registration.room_id) if from_registration and from_registration.room
      end
    end
  end
  
  #------------------------------------------------------------------------------
  def copy_custom_fields_to(workshop)
    custom_field_defs.each { |field| field.create_copy(workshop.id) }
  end
  
  # Return a list of upcoming workshops
  #------------------------------------------------------------------------------
  def self.upcoming_workshops(registration_deadline = false)
    if registration_deadline
      EventWorkshop.find(:all, :conditions => ["regdeadline > ?", Time.now], :order => 'startdate ASC')
    else
      EventWorkshop.find(:all, :conditions => ["enddate > ?", Time.now], :order => 'startdate ASC')
    end
  end
=end
  
end
