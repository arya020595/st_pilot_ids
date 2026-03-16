# frozen_string_literal: true

puts 'Creating default superadmin user...'

superadmin_role = Role.find_by!(name: 'superadmin')

User.find_or_create_by!(email: 'admin@pilotids.com') do |user|
  user.name = 'Super Admin'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = superadmin_role
  user.is_active = true
end

puts "  Created #{User.count} users"
puts '  Default login: admin@pilotids.com / password123'
