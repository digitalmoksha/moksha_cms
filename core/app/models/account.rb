#------------------------------------------------------------------------------
class Account < ActiveRecord::Base

  class DomainNotFound < StandardError
  end
  
  self.table_name   = 'core_accounts'
  attr_accessible   :company_name, :contact_email, :default_site_id, :domain, :account_prefix
  attr_accessible   :preferred_site_enabled, :preferred_default_locale, :preferred_locales,
                    :preferred_ssl_enabled, :preferred_webmaster_email,
                    :preferred_support_email, :preferred_google_analytics_tracker_id,
                    :preferred_mailchimp_api_key, :preferred_site_title

  validates_presence_of   :domain
  validates_presence_of   :account_prefix
  validates_presence_of   :preferred_default_locale
  validates_presence_of   :preferred_locales

  after_create      :create_default_roles

  preference        :site_title,                      :string
  preference        :ssl_enabled,                     :boolean, :default => false
  preference        :default_locale,                  :string,  :default => 'en'
  preference        :locales,                         :string,  :default => 'en, de'
  preference        :site_enabled,                    :boolean, :default => false
  preference        :google_analytics_tracker_id,     :string
  preference        :webmaster_email,                 :string
  preference        :support_email,                   :string
  preference        :mailchimp_api_key,               :string

  #--- eager load all preferences when an object is found
  after_find        :preferences
  
  # Find the account using the specified host (usually from the request url).
  # Check for certain special subdomains before lookup:
  #   dev, www, backoffice, staging, stg-
  #------------------------------------------------------------------------------
  def self.find_account(host)
    host      ||= ""
    separated   = host.downcase.split('.')
    separated   = separated.delete_if { |x| x == "dev" || x == 'www' || x == 'backoffice' || x =~ /stg-/ || x == 'staging' }
    self.find_by_domain(separated.join('.')) or raise Account::DomainNotFound.new('Invalid domain')
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
end
