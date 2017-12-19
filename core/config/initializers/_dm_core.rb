#--- Make sure console user knows this app is mult-tenant
if defined?(Rails::Console)
  puts "-------------------------------------------------------------------------------------"
  puts " App is Multi-Tenant.  Make sure to issue the following command before anything else."
  puts "    Account.current_by_prefix('specify_account_prefix')                              "
  puts "-------------------------------------------------------------------------------------"
  puts "Input your account prefix:"
  prefix = gets.chomp
  puts "--> Account.current_by_prefix('#{prefix}')"
  Account.current_by_prefix(prefix)
end
