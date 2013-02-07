#------------------------------------------------------------------------------
class Account < ActiveRecord::Base

  self.table_name   = 'core_accounts'
  attr_accessible   :company_name, :contact_email, :default_site_id, :domain, :account_prefix
  attr_accessible   :preferred_site_enabled, :preferred_site_default_locale,
                    :preferred_site_ssl_enabled, :preferred_webmaster_email,
                    :preferred_support_email, :preferred_google_analytics_tracker_id,
                    :preferred_mailchimp_api_key
  
  preference        :site_ssl_enabled,                :boolean, :default => false
  preference        :site_default_locale,             :string,  :default => 'en'
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
    return self.find_by_domain!(separated.join('.'))
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
  
  #------------------------------------------------------------------------------
  def site_enabled?
    preferred_site_enabled?
  end

end
