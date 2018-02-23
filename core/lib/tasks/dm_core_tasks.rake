namespace :dm_core do
  desc "Create a new site/account"
  task create_site: :environment do
    puts "\n"
    puts "---------------------------------------------------------------------------------"
    puts " Creates a new account/site and an associated admin account"
    puts "---------------------------------------------------------------------------------"
    puts "\n"
    puts "----- Enter Details of Account/Site to Create -----"
    puts "Company Name: "
    company_name = STDIN.gets.chomp
    puts "\nContact Email: "
    contact_email = STDIN.gets.chomp
    puts "\nDomain Name: (use 'localhost' for initial development setup)"
    domain_name = STDIN.gets.chomp
    puts "\nAccount Prefix (use 'local' for initial development setup):"
    account_prefix = STDIN.gets.chomp

    current_account = Account.new(company_name: company_name, contact_email: contact_email, domain: domain_name, account_prefix: account_prefix)

    current_account.save!(validate: false)
    Account.current = current_account
    Account.current_by_prefix(account_prefix)

    puts "\n"
    puts "----- Associate an Admin User -----"
    puts "Admin User Email (will be created if it doesn't exist): "
    user_email = STDIN.gets.chomp

    unless (user = User.find_by_email(user_email))
      begin
        puts "\nFirst Name (required): "
        first_name = STDIN.gets.chomp
      end while first_name.blank?
      begin
        puts "\nLast Name (required): "
        last_name = STDIN.gets.chomp
      end while last_name.blank?
      begin
        puts "\nPassword (min 8 chars): "
        password = STDIN.gets.chomp
      end while password.length < 8
      user = User.new({ email: user_email, password: password, password_confirmation: password,
                        user_profile: UserProfile.new(first_name: first_name, last_name: last_name, public_name: 'admin') })
      user.skip_confirmation!
      user.save!
      puts "\n--- User '#{user_email}' created"
    end

    user.add_role :admin
    #--- add as sysadmin if this is the only user
    sysadmin = Role.unscoped.where(name: 'sysadmin').first
    user.roles << sysadmin if User.all.count == 1
    user.save!
    puts "\n--- Finished"
  end
end
