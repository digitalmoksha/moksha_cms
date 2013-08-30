#------------------------------------------------------------------------------
class Account < ActiveRecord::Base

  class DomainNotFound < StandardError
  end
  class LoginRequired < StandardError
  end
  
  self.table_name   = 'core_accounts'
  attr_accessible         :company_name, :contact_email, :default_site_id, :domain, :account_prefix
  attr_accessible         :preferred_site_enabled, :preferred_default_locale, :preferred_locales,
                          :preferred_ssl_enabled, :preferred_webmaster_email,
                          :preferred_support_email, :preferred_google_analytics_tracker_id,
                          :preferred_mailchimp_api_key, :preferred_site_title
  attr_accessible         :preferred_smtp_address, :preferred_smtp_port, :preferred_smtp_domain,
                          :preferred_smtp_user_name, :preferred_smtp_password, :preferred_smtp_from_email,
                          :preferred_blog_from_email
  attr_accessible         :preferred_paypal_merchant_id, :preferred_paypal_cert_id
  attr_accessible         :preferred_newsletter_settings

  validates_presence_of   :domain
  validates_presence_of   :account_prefix
  validates_presence_of   :preferred_default_locale
  validates_presence_of   :preferred_locales
  validates_presence_of   :preferred_smtp_address
  validates_presence_of   :preferred_smtp_port
  validates_presence_of   :preferred_smtp_user_name
  validates_presence_of   :preferred_smtp_from_email
  validates_presence_of   :preferred_webmaster_email

  after_create            :create_default_roles
                        
  preference              :site_title,                      :string
  preference              :ssl_enabled,                     :boolean, :default => false
  preference              :default_locale,                  :string,  :default => 'en'
  preference              :locales,                         :string,  :default => 'en, de'
  preference              :site_enabled,                    :boolean, :default => false
  preference              :google_analytics_tracker_id,     :string
  
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

  #--- Newsletter Settings - uses the 'group' function to have one preference and many values
  #    ex) current_account.preferred_newsletter_settings(:mailchimp_api_key)
  preference              :newsletter_settings,             :string
  
  #--- eager load all preferences when an object is found
  after_find              :preferences
  
  # Find the account using the specified host (usually from the request url).
  # Check for certain special subdomains before lookup:
  #   dev, www, backoffice, staging, stg-
  #------------------------------------------------------------------------------
  def self.find_account(host)
    host      ||= ""
    separated   = host.downcase.split('.')
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
  end
  
  #------------------------------------------------------------------------------
  def create_default_roles
    Role.unscoped.create!(name: 'admin',   account_id: self.id)
    Role.unscoped.create!(name: 'beta',    account_id: self.id)
    Role.unscoped.create!(name: 'author',  account_id: self.id)
  end
  
  #------------------------------------------------------------------------------
  def site_enabled?
    preferred_site_enabled?
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
  
  #------------------------------------------------------------------------------
  def theme_data
    Account.theme_data(account_prefix)
  end
  
  # get the account's theme path
  #------------------------------------------------------------------------------
  def theme_path
    Rails.root.join('themes', account_prefix)
  end
  
  # Read the _theme.yml file located in the /site_assets/_account_prefix_/theme folder
  # Returns just the theme data - not the top level account_prefix
  # {todo} make the location a config variable
  #------------------------------------------------------------------------------
  def self.theme_data(theme_name)
    theme_file = Rails.root.join('themes', theme_name, '_theme.yml')
    if File.exists?(theme_file)
      (YAML::load_file(theme_file))[theme_name]
    else
      nil
    end
  end
  
end
