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
  
  attr_accessible         :title, :description, :sidebar, :country_id, :starting_on, :ending_on, :deadline_on, :info_url,
                          :contact_email, :contact_phone, :require_review, :require_account, :show_address, :require_address,
                          :require_photo, :published, :base_currency, :event_style, :funding_goal, :funding_goal_cents,
                          :payments_enabled

  # --- globalize
  translates              :title, :description, :sidebar, :fallbacks_for_empty_translations => true
  globalize_accessors     :locals => DmCore::Language.language_array

  extend FriendlyId
  friendly_id             :title_slug, use: :slugged
  resourcify

  validates_presence_of   :country_id
  validates_presence_of   :base_currency
  validates_presence_of   :starting_on
  validates_presence_of   :ending_on
  validates_presence_of   :contact_email
  validates_presence_of   :event_style
  
  # validates_presence_of   :deadline_on

  default_scope           { where(account_id: Account.current.id) }
  
  #--- upcoming and past are used in the admin, so should be published and non-published
  scope                   :upcoming,  where('ending_on > ? AND archived_on IS NULL', (Date.today - 1).to_s).order('starting_on DESC')
  scope                   :past,      where('ending_on <= ? AND archived_on IS NULL', (Date.today - 1).to_s).order('starting_on DESC')

  #--- available is list of published and registration open and not ended
  scope                   :available, where(published: true).where('ending_on > ? AND deadline_on > ? AND archived_on IS NULL', 
                                      (Date.today - 1).to_s, (Date.today - 1).to_s).order('starting_on ASC')

  monetize                :funding_goal_cents, :with_model_currency => :base_currency, :allow_nil => true

  EVENT_STYLES = [['Workshop', 'workshop'], ['Crowdfunding', 'crowdfunding']]

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
  
  # Is the registration closed?  If deadline is null, then registration is open ended
  #------------------------------------------------------------------------------
  def registration_closed?
    !published? || (deadline_on ? (deadline_on < Time.now.to_date) : false)
  end
  
  #------------------------------------------------------------------------------
  def published?
    published
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

  #------------------------------------------------------------------------------
  def crowdfunding?
    self.event_style == 'crowdfunding'
  end

  # Return financial summary and details
  # level => :summary or :detail
  #------------------------------------------------------------------------------
  def financial_details(level = :detail)
    #--- pick currency of first price
    financials = {:summary => { total_possible: Money.new(0, base_currency),          total_possible_worst: Money.new(0, base_currency),
                                total_paid: Money.new(0, base_currency),              total_outstanding: Money.new(0, base_currency), 
                                total_outstanding_worst: Money.new(0, base_currency), total_discounts: Money.new(0, base_currency) },
                  collected: {},
                  collected_monthly: {},
                  payment_type: {},
                  projected: {}
                 }
                  
    registrations.attending.each do |registration|
      if registration.workshop_price
        #--- Calculate the summary values
        financials[:summary][:total_possible]     += registration.discounted_price
        financials[:summary][:total_paid]         += registration.amount_paid.nil? ? Money.new(0, base_currency) : registration.amount_paid
        financials[:summary][:total_outstanding]  += registration.balance_owed
        financials[:summary][:total_discoutns]    += registration.discount

        if level == :detail
          #--- Calculate what has been collected, by payment method
          registration.payment_histories.each do |payment_history|
            payment_method = payment_history.payment_method
            financials[:collected]["#{payment_method}"] = Money.new(0, base_currency) if financials[:collected]["#{payment_method}"].nil?
            financials[:collected]["#{payment_method}"] += payment_history.total
        
            month = payment_history.payment_date.beginning_of_month
            financials[:collected_monthly][month] = Money.new(0, base_currency) if financials[:collected_monthly][month].nil?
            financials[:collected_monthly][month] += payment_history.total
          end
        end
      end
    end
    
    #--- give a worst case value - reduce by 20%
    financials[:summary][:total_possible_worst]               = financials[:summary][:total_possible] * 0.80
    financials[:summary][:total_outstanding_worst]            = financials[:summary][:total_outstanding] * 0.80
    
    return financials
  end

  #------------------------------------------------------------------------------
  def total_paid
    total_paid = Money.new(0, base_currency)
    registrations.attending.each do |registration|
      if registration.workshop_price
        total_paid += registration.amount_paid.nil? ? Money.new(0, base_currency) : registration.amount_paid
      end
    end
    return total_paid
  end
  
=begin
  
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
