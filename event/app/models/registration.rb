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
  belongs_to                    :payment_comment, class_name: 'Comment'
  preference                    :payment_reminder_hold_until,  :date
  serialize                     :payment_reminder_history, Array
  attr_accessor                 :payment_comment_text
  acts_as_commentable           :private

  accepts_nested_attributes_for :user_profile

  monetize                      :amount_paid_cents, with_model_currency: :amount_paid_currency, allow_nil: true

  default_scope                 { where(account_id: Account.current.id) }
  scope                         :attending, -> { where("(aasm_state = 'accepted' OR aasm_state = 'paid') AND archived_on IS NULL") }
  scope                         :accepted,  -> { where("aasm_state = 'accepted' AND archived_on IS NULL") }
  scope                         :paid,      -> { where("aasm_state = 'paid' AND archived_on IS NULL") }
  scope                         :unpaid,    -> { where("aasm_state = 'accepted' AND archived_on IS NULL") } # same as accepted
  scope                         :discounted,-> { where("discount_value > 0") } # use like registrations.attending.discounted

  after_initialize              :create_uuid
  before_create                 :set_currency
  after_create                  :set_receipt_code
  before_save                    :clear_reminder_sent_on, if: :amount_paid_cents_changed?

  validates_uniqueness_of       :uuid
  validates_presence_of         :workshop_price_id, if: Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  validates_presence_of         :workshop_price_id, if: Proc.new { |reg| reg.workshop.workshop_prices.size > 0}
  validates_numericality_of     :discount_value, allow_nil: true
  validates_length_of           :payment_comment, maximum: 255
  
  delegate                      :first_name, :last_name, :full_name, :email, :address, :address2, 
                                :city, :state, :country, :zipcode, :phone, to: :user_profile

private

  # when a payment is made, we want reset whether a payment reminder has been sent
  #------------------------------------------------------------------------------
  def clear_reminder_sent_on
    self.payment_reminder_sent_on = nil
  end

  # the uuid is used to provide a private url to a customer so that they can access
  # their registration if not logged in.  This is particularly important when
  # a customer registers without having a user account.
  #------------------------------------------------------------------------------
  def create_uuid
    self.uuid = SecureRandom.uuid if self.new_record?
  end

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
  
public

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
  
  # suggested amount of next payment.
  # when it's recurring, they payment should be whatever is needed to bring their
  # payment plan up to date
  #------------------------------------------------------------------------------
  def payment_owed
    if workshop_price && workshop_price.recurring_payments?
      to_pay = recurring_what_should_be_paid_by_now(0) - amount_paid
      to_pay.negative? ? Money.new(0, workshop_price.price.currency) : to_pay
    else
      balance_owed
    end
  end
  
  # when a customer wants to make a payment, they should either charged the amount
  # for this month (which could be less than the normal monthly amount), or the
  # standard monthly amount, or whatever the balance_owed is
  #------------------------------------------------------------------------------
  def make_payment_now_amount
    if payment_owed.positive?
      payment_owed
    elsif workshop_price.payment_price < balance_owed
      workshop_price.payment_price
    else
      balance_owed
    end
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
  # Due first 7 days after inital registration (or a payment period).  Then every 14 days after that
  #------------------------------------------------------------------------------
  def payment_reminder_due?
    if preferred_payment_reminder_hold_until.nil? || preferred_payment_reminder_hold_until < Time.now
      time_period = self.payment_reminder_sent_on.nil? ? (self.created_at + 7.days) : (self.payment_reminder_sent_on + 14.days)
      past_due?(7) ? time_period < Time.now : false
    else
      false
    end
  end

  # past due means they haven't paid what they should have paid by now
  #------------------------------------------------------------------------------
  def past_due?(grace_period_in_days = 7)
    return false if !balance_owed.positive?
    if workshop_price.recurring_payments?
      return amount_paid < recurring_what_should_be_paid_by_now(grace_period_in_days)
    else
      return Date.today > (self.created_at + grace_period_in_days.days)
    end
  end

  #------------------------------------------------------------------------------
  def recurring_what_should_be_paid_by_now(grace_period_in_days = 7)
    entry = workshop_price.specific_payment_schedule(self.created_at + grace_period_in_days.days, Date.today)
    entry ? entry[:total_due] : 0
  end

  # date when the most recent payment was due
  #------------------------------------------------------------------------------
  def last_payment_due_on
    entry = workshop_price.specific_payment_schedule(self.created_at, Date.today)
    entry ? entry[:due_on] : self.created_at.to_date
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
    amount            = Monetize.parse(cost, total_currency)
    
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
      self.send('accept!') if balance_owed.positive? && self.paid?
      return true
    end
    return false
  end

  # Return the payment page url, so that it can be used in emails
  #------------------------------------------------------------------------------
  def payment_url
    DmEvent::Engine.routes.url_helpers.register_choose_payment_url(self.uuid, host: Account.current.url_host, locale: I18n.locale)
  end
  
end
