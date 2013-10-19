#--- Make sure console user knows this app is mult-tenant
if defined?(Rails::Console)
  puts "-------------------------------------------------------------------------------------"
  puts " App is Multi-Tenant.  Make sure to issue the following command before anything else."
  puts "    account('specify_account_prefix')                                                "
  puts "-------------------------------------------------------------------------------------"
end
