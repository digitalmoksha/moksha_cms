# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#--- load 
DmCore::Engine.load_seed

#--- Creates a sysadmin role, that spans all site/accounts
Role.unscoped.create!(name: 'sysadmin', account_id: 0)

puts "---------------------------------------------------------------------------------"
puts " Successfully loaded initial data."
puts " You should now run 'rake dm_core:create_site' to create the first site and user"
puts "---------------------------------------------------------------------------------"
