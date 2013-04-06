namespace :dm_core do

    desc "Create a new site/account"
    task :create_account => :environment do
      puts "\n----- Enter Details of Account/Site to Create -----"
      puts "Company Name: "
      company_name = STDIN.gets.chomp
      puts "Contact Email: "
      contact_email = STDIN.gets.chomp
      puts "Domain Name: "
      domain_name = STDIN.gets.chomp
      puts "Account Prefix (should be less than 6 characters): "
      account_prefix = STDIN.gets.chomp

      separated     = domain_name.downcase.split('.')
      short_domain  = (separated.first == 'www') ? (separated.last(separated.size - 1).join('.')) : domain_name

      current_account = Account.new(:company_name => company_name, :contact_email => contact_email, :domain => domain_name, :account_prefix => account_prefix)
      current_account.save!(validate: false)
      Account.current = current_account
      
      puts "----- Associate an Admin User -----"
      puts "Admin User Email (will be created if it doesn't exist): "
      user_email = STDIN.gets.chomp
      admin_role = Role.find_by_name('admin')
      if !(user = User.find_by_email(user_email))
        puts "  First Name: "
        first_name = STDIN.gets.chomp
        puts "  Last Name: "
        last_name = STDIN.gets.chomp
        puts "  Password (min 6 chars): "
        password = STDIN.gets.chomp
        puts "  Password Confirmation: "
        password_confirm = STDIN.gets.chomp
        user = User.new({ :email => user_email, :first_name => first_name, :last_name => last_name, :password => password, :password_confirmation => password_confirm})
        user.skip_confirmation!
        user.save!
        puts "--- User '#{user_email}' created with password 'admin'"
      end
      user.add_role :admin
      user.save!
      puts "\n--- Finished"
    end

end