#------------------------------------------------------------------------------
class Account < ActiveRecord::Base

  self.table_name   = 'core_accounts'
  attr_accessible   :company_name, :contact_email, :default_site_id, :domain, :account_prefix

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
  # def site_disabled?
  #   preferred_site_disabled?
  # end

end
