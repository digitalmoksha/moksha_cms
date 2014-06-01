# Important: one reason to link off of the user_profile instead of the user
# is so that we can support registrations without requiring an account.
# We can create a "userless" profile, that has all the necessary information.
# This is instead of duplicating all those fields in the registration table.
#------------------------------------------------------------------------------
class Registration < ActiveRecord::Base
  include DmEvent::Concerns::RegistrationStateMachine
  include DmEvent::Concerns::RegistrationStateEmail
  include DmCore::Concerns::HasCustomFields
  include ActiveMerchant::Billing::Integrations

  self.table_name               = 'ems_registrations'

  belongs_to                    :workshop, counter_cache: true
  belongs_to                    :workshop_price
  belongs_to                    :user_profile
  belongs_to                    :account
  has_many                      :payment_histories, as: :owner, dependent: :destroy                              

  accepts_nested_attributes_for :user_profile
  
  monetize                      :amount_paid_cents, with_model_currency: :amount_paid_currency, allow_nil: true
  
  default_scope                 { where(account_id: Account.current.id) }
  scope                         :attending, -> { where("(aasm_state = 'accepted' OR aasm_state = 'paid') AND archived_on IS NULL") }
  scope                         :accepted,  -> { where("aasm_state = 'accepted' AND archived_on IS NULL") }
  scope                         :paid,      -> { where("aasm_state = 'paid' AND archived_on IS NULL") }
  scope                         :unpaid,    -> { where("aasm_state = 'accepted' AND archived_on IS NULL") } # same as accepted
  scope                         :discounted,-> { where("discount_value > 0") } # use like registrations.attending.discounted

  before_create                 :set_currency
  after_create                  :set_receipt_code
  
  validates_presence_of         :workshop_price_id, if: Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  validates_presence_of         :workshop_price_id, if: Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  validates_numericality_of     :discount_value, allow_nil: true
  validates_length_of           :payment_comment, maximum: 255
  
  delegate                      :first_name, :last_name, :full_name, :email, :address, :address2, 
                                :city, :state, :country, :zipcode, :phone, to: :user_profile
  
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
  
  # suggested amount of next payment
  #------------------------------------------------------------------------------
  def payment_owed
    [workshop_price.payment_price, balance_owed].min
  end
  
  # Return the number of items specified, in particular the number of items in 
  # a particular state
  #------------------------------------------------------------------------------
  def self.number_of(state, options = {})
    query = (options[:only_confirmed] ? where.not(confirmed_on: nil) : all)
    case state
    when :attending
      attending.count
    when :unpaid
      #--- the number of unpaid is the same as the number of accepted
      number_of(:accepted)
    when :checkedin
      query.where.not(checkin_at: 0).where(archived_on: nil).count
    when :archived
      query.where.not(archived_on: nil).count
    when :registrations
      #--- don't count any canceled
      query.where(archived_on: nil).where.not(aasm_state: 'canceled').where.not(aasm_state: 'refunded').count
    when :at_price
      #--- number of registrations for a particular price
      query.where(archived_on: nil).where("(aasm_state = 'paid' OR aasm_state = 'accepted')").where(workshop_price_id: options[:price_id]).count
    when :for_all_prices
      #--- array of counts per price
      query.where(archived_on: nil).where("(aasm_state = 'paid' OR aasm_state = 'accepted')").group(:workshop_price_id).count
    when :discounted
      attending.discounted.count
    when :discounted_total
      total = attending.discounted.to_a.sum(&:discount)
      (total == 0) ? Money.new(0) : total
    when :user_updated
      #--- how many users updated their record
      query.where(archived_on: nil).where("(aasm_state = 'paid' OR aasm_state = 'accepted')").where.not(user_updated_at: nil).count
    when :confirmed
      #--- how many users confirmed their attendance
      where.not(confirmed_on: nil).where(archived_on: nil).where("(aasm_state = 'paid' OR aasm_state = 'accepted')").count
    else
      #--- must be wanting to count the process states
      query.where(archived_on: nil, aasm_state: state).count
    end
  end

  # check if the regsitration is unpaid
  #------------------------------------------------------------------------------
  def unpaid?
    self.accepted? && self.archived_on == nil
  end
  
  # Is it time to send a payment reminder?
  # Due first 7 days after inital registration.  Then every 14 days after that
  #------------------------------------------------------------------------------
  def payment_reminder_due?
    time_period = self.payment_reminder_sent_on.nil? ? (self.created_at + 7.days) : (self.payment_reminder_sent_on + 14.days)
    self.balance_owed > Money.new(0, workshop.base_currency) && time_period < Time.now
    
    # if recurring_period since last paymnet
    # if 7 days after registration and no payment
    # if 14 days since last reminder and no payment
    # if resume_reminders is past
    # last_payment = payment_histories.order('created_on').last
    # if workshop_price.recurring?
    #   if 
  end
  
  # Setup the columns for exporting data as csv.
  #------------------------------------------------------------------------------
  def self.csv_columns(workshop)
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

    column_definitions <<     ['Registered on',     'item.created_at.to_date', 75, {type: 'DateTime', numberformat: 'd mmm, yyyy'}]

    column_definitions <<     ["Price",             "item.workshop_price.price.to_f", nil, {type: 'Number', numberformat: '#,##0.00'}]
    column_definitions <<     ["Price Description", "item.workshop_price.price_description"]
    column_definitions <<     ["Price Sub Descr",   "item.workshop_price.sub_description"]
    column_definitions <<     ["Discount",          "item.discount.to_f", nil, {type: 'Number', numberformat: '#,##0.00'}]
    column_definitions <<     ["Paid",              "item.amount_paid.to_f", nil, {type: 'Number', numberformat: '#,##0.00'}]
    column_definitions <<     ["Balance",           "item.balance_owed.to_f", nil, {type: 'Number', numberformat: '#,##0.00'}]

    # ---- add the extra fields defined in the workshop record
    workshop.custom_field_defs.each_with_index do | x, index |
      case x.field_type
      when 'check_box_collection'
        column_definitions << [ "#{x.column_name}", "(z = item.custom_fields.detect { |y| y.custom_field_def_id == #{x.id} }) ? z.value : ''", nil, {type: 'list', custom_field: true}]
      when 'divider'
      else
        column_definitions << [ "#{x.column_name}", "(z = item.custom_fields.detect { |y| y.custom_field_def_id == #{x.id} }) ? z.value : ''", nil, {custom_field: true}]
      end
    end
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
        item_ref: options[:item_ref],
        cost: cost,
        total_cents: amount.cents,
        total_currency: amount.currency.iso_code,
        payment_method: options[:payment_method],
        bill_to_name: options[:bill_to_name],
        payment_date: options[:payment_date],
        user_profile_id: user_profile.id)
    else
      new_amount_paid = self.amount_paid + self.workshop_price.to_base_currency(amount)
      payment_history   = self.payment_histories.create(
          anchor_id: receipt_code,
          item_ref: options[:item_ref],
          cost: cost,
          quantity: 1,
          discount: 0,
          total_cents: amount.cents,
          total_currency: amount.currency.iso_code,
          payment_method: options[:payment_method],
          bill_to_name: options[:bill_to_name],
          payment_date: options[:payment_date],
          user_profile_id: (user_profile ? user_profile.id : nil),
          notify_data: options[:notify_data],
          transaction_id: options[:transaction_id],
          status: (user_profile ? "Completed" : options[:status])
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
  
end
