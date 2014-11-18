#------------------------------------------------------------------------------
class Account < ActiveRecord::Base

  class DomainNotFound < StandardError
  end
  class LoginRequired < StandardError
  end
  
  CURRENCY_TYPES    = { 'British Pound (&pound;)'.html_safe => 'GBP',
                        'Czech Koruna (&#x4B;&#x10D;)'.html_safe => 'CZK',
                        'Euro (&euro;)'.html_safe => 'EUR',
                        'Indian Rupee (Rs)' => 'INR',
                        'Japanese Yen (&yen;)'.html_safe => 'JPY',
                        'Swiss Franc (Fr)' => 'CHF',
                        'US Dollar ($)' => 'USD' }
  
  self.table_name   = 'core_accounts'

  attr_accessor           :email_validation, :general_validation, :analytics_validation, :metadata_validation, :media_validation
  attr_accessor           :url_base, :url_host, :url_protocol  #--- stores the current base site url for this request. 
                                                               #    useful to mailers where request object not available
  
  validates_presence_of   :domain,                                      :if => Proc.new { |p| p.general_validation }
  validates_presence_of   :account_prefix,                              :if => Proc.new { |p| p.general_validation }
  validates_presence_of   :preferred_default_locale,                    :if => Proc.new { |p| p.general_validation }
  validates_presence_of   :preferred_locales,                           :if => Proc.new { |p| p.general_validation }
  validates_presence_of   :preferred_smtp_address,                      :if => Proc.new { |p| p.email_validation }
  validates_presence_of   :preferred_smtp_port,                         :if => Proc.new { |p| p.email_validation }
  validates_presence_of   :preferred_smtp_user_name,                    :if => Proc.new { |p| p.email_validation }
  validates_presence_of   :preferred_smtp_from_email,                   :if => Proc.new { |p| p.email_validation }
  validates_presence_of   :preferred_webmaster_email,                   :if => Proc.new { |p| p.email_validation }
  validates_presence_of   :preferred_site_title,       :maximum => 255, :if => Proc.new { |p| p.metadata_validation }
  validates_length_of     :preferred_site_description, :maximum => 255, :if => Proc.new { |p| p.metadata_validation }
  validates_length_of     :preferred_site_keywords,    :maximum => 255, :if => Proc.new { |p| p.metadata_validation }
   
  after_create            :create_default_roles

  preference              :ssl_enabled,                     :boolean, :default => false
  preference              :default_locale,                  :string,  :default => 'en'
  preference              :locales,                         :string,  :default => 'en, de'
  preference              :site_enabled,                    :boolean, :default => false
  preference              :site_maintenance,                :boolean, :default => false
  preference              :google_analytics_tracker_id,     :string
  
  #--- Site wide page settings
  preference              :site_title,                      :string
  preference              :site_keywords,                   :string
  preference              :site_copyright,                  :string
  preference              :site_description,                :string
  preference              :youtube_url,                     :string
  preference              :facebook_url,                    :string
  preference              :twitter_url,                     :string
  preference              :linkedin_url,                    :string

  #--- Email / SMTP settings
  preference              :webmaster_email,                 :string
  preference              :support_email,                   :string
  preference              :mailchimp_api_key,               :string
  preference              :smtp_address,                    :string
  preference              :smtp_port,                       :string,  :default => '587'
  preference              :smtp_domain,                     :string
  preference              :smtp_user_name,                  :string
  preference              :smtp_password,                   :string
  preference              :smtp_from_email,                 :string
  preference              :blog_from_email,                 :string
                        
  #--- PayPal
  preference              :paypal_merchant_id,              :string
  preference              :paypal_cert_id,                  :string

  #--- Sofort payment system sofort.com
  preference              :sofort_user_id,                  :string
  preference              :sofort_project_id,               :string
  preference              :sofort_project_password,         :string
  preference              :sofort_notification_password,    :string

  #--- Subscritpion Payments
  preference              :subscription_processor,          :string
  preference              :default_currency,                :string
  preference              :subscription_bcc_email,          :string

  #--- Newsletter
  preference              :nms_use_mailchimp,               :boolean, :default => false
  preference              :nms_api_key,                     :string
  preference              :nms_lists_synced_on,             :datetime
  
  #--- status values (no UI)
  preference              :follower_notifications_sent_at,  :datetime # when last follower notifications were sent
  
  #--- Media libary preferences
  preference              :image_thumbnail_width,           :integer, default: 200
  preference              :image_small_width,               :integer, default: 300
  preference              :image_medium_width,              :integer, default: 600
  preference              :image_large_width,               :integer, default: 900

  #--- eager load all preferences when an object is found
  after_find              :preferences
  
  # Find the account using the specified host (usually from the request url).
  # Check for certain special subdomains before lookup:
  #   dev, www, backoffice, staging, stg-
  # Supports xip.io format for testing on local network
  #   dev.testapp.net.192.168.1.5.xip.io
  # is a valid address.  See http://xip.io for more info
  #------------------------------------------------------------------------------
  def self.find_account(host)
    host      ||= ""
    separated   = host.downcase.split('.')
    separated   = separated[0..-7] if host.end_with?('xip.io') # strip off xip.io and ip address
    separated   = separated.delete_if { |x| x == 'dev' || x == 'www' || x == 'backoffice' || x =~ /stg-/ || x == 'staging' }
    self.find_by_domain(separated.join('.')) or raise Account::DomainNotFound.new("Invalid domain: #{host}")
  end

  # Since we need the current account for the default scope in models, we need 
  # this information easily available at the model level.
  # This is thread safe, as opposed to using a simple cattr_accessor.
  # But we must ensure the that thread info is nulled out after every request
  # using an around_filter
  #------------------------------------------------------------------------------
  def self.current=(account)
    Thread.current[:account] = account
  end
  
  def self.current
    Thread.current[:account]
  end
  
  # Set the current account by looking up the account prefix.  To be used when
  # operating outside a request, such as from the console
  #------------------------------------------------------------------------------
  def self.current_by_prefix(account_prefix)
    Account.current = Account.find_by_account_prefix(account_prefix)

    #--- set the current request site url for use where request object is not avail,
    #    like in ActionMailer or from a rake task
    Account.current.url_protocol  = Account.current.ssl_enabled? ? 'https://' : 'http://'
    Account.current.url_host      = Account.current.domain
    Account.current.url_base      = Account.current.url_protocol + Account.current.url_host
  end
  
  #------------------------------------------------------------------------------
  def create_default_roles
    Role.unscoped.create!(name: 'admin',   account_id: self.id)
    Role.unscoped.create!(name: 'beta',    account_id: self.id)
  end
  
  #------------------------------------------------------------------------------
  def site_enabled?
    preferred_site_enabled?
  end

  #------------------------------------------------------------------------------
  def site_maintenance?
    preferred_site_maintenance?
  end
  
  #------------------------------------------------------------------------------
  def ssl_enabled?
    preferred_ssl_enabled?
  end

  # check the local is a supported locale. If not, return site default
  #------------------------------------------------------------------------------
  def verify_locale(locale)
    (site_locales.include? locale.to_s) ? locale : preferred_default_locale
  end
  
  # Reutrn an array of locales used for the site.  Split on commas and whitespace
  #------------------------------------------------------------------------------
  def site_locales
    preferred_locales.split(/,\s*/)
  end
  
  # take the root path and use the default locale
  #------------------------------------------------------------------------------
  def index_path
    "/#{preferred_default_locale}/index"
  end
  
  #------------------------------------------------------------------------------
  def smtp_settings
    {
      :address              => preferred_smtp_address,
      :port                 => preferred_smtp_port,
      :domain               => preferred_smtp_domain,
      :user_name            => preferred_smtp_user_name,
      :password             => preferred_smtp_password
    }
  end
  
  # Return the current theme's data structure.
  # parent: true    will give the parent theme's data
  # if no data exists, return an empty hash
  #------------------------------------------------------------------------------
  def theme_data(options = {})
    if options[:parent]
      ThemesForRails.config.themes_data(parent_theme) || {}
    else
      ThemesForRails.config.themes_data(current_theme) || {}
    end
  end
  
  # Get the value of the specific theme option.  
  #------------------------------------------------------------------------------
  def theme_option(option_name)
    theme_data(parent: true).merge(theme_data)[option_name.to_s]
  end
  
  # get the account's theme filesystem path
  #------------------------------------------------------------------------------
  def theme_path
    "#{ThemesForRails.config.themes_path}/#{current_theme}"
  end

  # Get the name of the current theme - which is simply the account prefix
  #------------------------------------------------------------------------------
  def current_theme
    account_prefix
  end
  
  # Get the name of the parent theme
  #------------------------------------------------------------------------------
  def parent_theme
    ThemesForRails.config.parent_theme(current_theme)
  end
end
