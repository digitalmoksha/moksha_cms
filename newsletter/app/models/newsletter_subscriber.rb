# [todo] currently not saving subscriber info in database, only working with a
# temporary object.  Look at caching/syncing subscriber info for performance
#------------------------------------------------------------------------------
class NewsletterSubscriber # < ApplicationRecord
=begin
  belongs_to              :newsletter

  validates_presence_of     :email
  validates_presence_of     :firstname,   :if => Proc.new { |sub| sub.newsletter.require_name}
  validates_presence_of     :lastname,    :if => Proc.new { |sub| sub.newsletter.require_name}
  validates_presence_of     :country,     :if => Proc.new { |sub| sub.newsletter.require_country}

  default_scope             { where(account_id: Account.current.id) }

  #------------------------------------------------------------------------------
  # protect admin values from being assigned via a malicious form
  # attr_accessible makes everything protected except those listed
  # attr_protected makes everything accessible except those listed
  #------------------------------------------------------------------------------
  scope :subscribed,    :conditions => ["process_state = ?", 'subscribed']
  scope :unsubscribed,  :conditions => ["process_state = ?", 'unubscribed']
  scope :unconfirmed,   :conditions => ["process_state = ?", 'unconfirmed']
  scope :not_reminded,  :conditions => ["process_state = ? AND reminded_on IS NULL", 'unconfirmed']

  attr_protected            :subscribedate, :confirmed, :confrimdate, :unsubscribed,
                            :unsubscribedate, :confirmcode, :subscribeip,
                            :confirmationemail, :confirmationreply

  belongs_to                :country

  #--- tie the subscriber_id to a student record
  belongs_to                :subscriber, :class_name => 'Student', :foreign_key => 'subscriber_id'

  #=== validation rules

  validates_length_of       :firstname, :maximum => 50
  validates_length_of       :lastname,  :maximum => 50
  validates_length_of       :email,     :maximum => 60

  validates_email_veracity_of  :email,     :on => :create

  #--- define how the state machine works
  acts_as_state_machine       :initial => :unconfirmed, :column => :process_state
  state :unconfirmed,         :after => Proc.new { |o| o.update_attribute(:processed_on, Time.now) }
  state :subscribed,          :after => Proc.new { |o| o.update_attribute(:processed_on, Time.now) }
  state :unsubscribed,        :after => Proc.new { |o| o.update_attribute(:processed_on, Time.now) }
  state :bounced,             :after => Proc.new { |o| o.update_attribute(:processed_on, Time.now) }

  #------------------------------------------------------------------------------
  event :unconfirm do
    transitions :from => :subscribed,     :to => :unconfirmed
    transitions :from => :unsubscribed,   :to => :unconfirmed
    transitions :from => :bounced,        :to => :unconfirmed
  end

  #------------------------------------------------------------------------------
  event :subscribe do
    transitions :from => :unconfirmed,    :to => :subscribed
    transitions :from => :unsubscribed,   :to => :subscribed
    transitions :from => :bounced,        :to => :subscribed
  end

  #------------------------------------------------------------------------------
  event :unsubscribe do
    transitions :from => :unconfirmed,    :to => :unsubscribed
    transitions :from => :subscribed,     :to => :unsubscribed
    transitions :from => :bounced,        :to => :unsubscribed
  end

  #------------------------------------------------------------------------------
  event :bounce do
    transitions :from => :unconfirmed,    :to => :bounced
    transitions :from => :subscribed,     :to => :bounced
    transitions :from => :unsubscribed,   :to => :bounced
  end

  # Takes either a Hash of values or an object that responds to the proper values
  #------------------------------------------------------------------------------
  def initialize(subscriber = nil, options = {:subscriber_id => nil})
    if subscriber.nil? || subscriber.is_a?(Hash)
      super(subscriber)
    else
      super(:firstname => subscriber.firstname, :lastname => subscriber.lastname,
                        :email => subscriber.email, :country => subscriber.country,
                        :subscriber_id => options[:subscriber_id])
    end
    write_attribute(:subscribeip, options[:remote_ip])
    write_attribute(:confirmcode, generate_confirmation_code())
  end

  # find if there is an existing subscription
  #------------------------------------------------------------------------------
  def self.find_existing_subscription(newsletter_id, subscriber_id = nil, email = nil)
    if subscriber_id
      #--- look for a specific subscriber_id
      subscriber = NewsletterSubscriber.find_by_subscriber_id_and_newsletter_id(subscriber_id, newsletter_id)
    else
      #--- look for a specific email address
      subscriber = NewsletterSubscriber.find_by_email_and_newsletter_id(email, newsletter_id)
    end
    return subscriber
  end

  #------------------------------------------------------------------------------
  def self.find_existing_subscription_is_subscribed(newsletter_id, subscriber_id = nil, email = nil)
    subscriber = NewsletterSubscriber.find_existing_subscription(newsletter_id, subscriber_id, email)
    return subscriber ? subscriber.is_subscribed? : false
  end

  # Return a reference to the actual subscriber data (like name and email).
  #------------------------------------------------------------------------------
  def subscriber_data
    subscriber_id.nil? ? self : subscriber
  end

  #------------------------------------------------------------------------------
  def country_name
    self.country.english_name
  end

  #------------------------------------------------------------------------------
  def full_name
    name = firstname.capitalize + " " + lastname.capitalize
    return name.blank? ? email : name
  end

  # Given a subscriber, update the information in this record with that from the
  # subscriber info.  If there is a subscriber_id, then don't update the record.
  #------------------------------------------------------------------------------
  def update_subscription(subscriber)
    unless subscriber.nil?
      update_attributes(:firstname => subscriber.firstname, :lastname => subscriber.lastname,
                        :email => subscriber.email, :country => subscriber.country)
    end
  end

  #------------------------------------------------------------------------------
  def hard_bounce
    increment!(:hard_bounces)
    bounce! if hard_bounces >= 1
  end

  #------------------------------------------------------------------------------
  def soft_bounce
    increment!(:soft_bounces)
  end

  #------------------------------------------------------------------------------
  def is_subscribed?
    process_state == 'subscribed'
  end

  #------------------------------------------------------------------------------
  def is_unsubscribed?
    process_state == 'unsubscribed'
  end

  #------------------------------------------------------------------------------
  def is_unconfirmed?
    process_state == 'unconfirmed'
  end

  #------------------------------------------------------------------------------
  def is_bounced?
    process_state == 'bounced'
  end

  #------------------------------------------------------------------------------
  def generate_confirmation_code()
    hashed(Time.now.to_i.to_s + rand.to_s)
  end

  #------------------------------------------------------------------------------
  def hashed(str)
    return Digest::SHA1.hexdigest("guruparampara--#{str}--")[0..39]
  end

  #------------------------------------------------------------------------------
  def update_confirmationemail(email)
    update_attribute(:confirmationemail, email)
  end

  # This trys to keep information indicating that the user actually
  # did click on the activation link in the email. We will track the
  # ipaddress and the uri that was requested.
  #------------------------------------------------------------------------------
  def update_confirmationreply(request_obj)
    info = "Remote IP: " + request_obj.remote_ip + "   URI: " + request_obj.url
    update_attribute(:confirmationreply, info)
  end

  # Set everything back to a pre confirmed state
  #------------------------------------------------------------------------------
  def reset_confirmation
    update_attribute(:confirmcode, generate_confirmation_code)
    update_attribute(:confirmationemail, nil)
    update_attribute(:confirmationreply, nil)
    update_attribute(:hard_bounces, 0)
    update_attribute(:soft_bounces, 0)
    unconfirm!
  end

  #------------------------------------------------------------------------------
  def send_confirmation
    email         = NewsletterSubscriberMailer.signup(self, confirm_subscription_url, confirm_unsubscribe_url).deliver_now
    update_confirmationemail(email.to_s)
  end

  #------------------------------------------------------------------------------
  def resend_confirmation
    email         = NewsletterSubscriberMailer.reconfirm(self, confirm_subscription_url, confirm_unsubscribe_url).deliver_now
    update_confirmationemail(email.to_s)
    update_attribute(:reminded_on, Time.now)
  end

  #------------------------------------------------------------------------------
  def confirm_subscription_url
    confirm_url   = newsletter.account.preferred(:system_main_site) + "/#{I18n.locale}" + Hanuman::Application.config.confirm_subscription_url
    confirm_url  += "?subid=#{self.id}&code=#{self.confirmcode}"
  end

  #------------------------------------------------------------------------------
  def confirm_unsubscribe_url
    confirm_url   = newsletter.account.preferred(:system_main_site) + "/#{I18n.locale}" + Hanuman::Application.config.confirm_unsubscription_url
    confirm_url  += "?subid=#{self.id}&code=#{self.confirmcode}"
  end

  # Return the number of items specified, in particular the number of items in
  # a particular state
  #------------------------------------------------------------------------------
  def self.number_of(state, options = {})
    #--- must be wanting to count the process states
    if options[:date]
      count(:conditions => "process_state = '#{state.to_s}' AND date(created_on) = '#{options[:date]}'")
    elsif options[:before_date]
      count(:conditions => "process_state = '#{state.to_s}' AND date(created_on) <= '#{options[:before_date]}'")
    else
      count(:conditions => "process_state = '#{state.to_s}'")
    end
  end

  # Supported series:
  #   :subscribed, :unsubscribed, :unconfirmed, :continents
  #------------------------------------------------------------------------------
  def self.subscribers_chart_series(requested_data = :subscribed, months_ago = 24)
    case requested_data
    when :subscribed, :unsubscribed, :unconfirmed
      months_ago.downto(0).map { |date| number_of(requested_data.to_s, :before_date => date.months.ago.to_date) }.inspect
    when :continents
      joins(:country).where(:process_state => 'subscribed').select('globalize_countries.continent').group('continent').count('continent')
    end
  end

=end
end
