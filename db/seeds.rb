# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create Permissions
puts "Creating permissions..."
permissions_data = [
  { code: 'dashboard.index', name: 'View Dashboard' },
  { code: 'user_management.users.index', name: 'View Users' },
  { code: 'user_management.users.show', name: 'Show User' },
  { code: 'user_management.users.create', name: 'Create User' },
  { code: 'user_management.users.update', name: 'Update User' },
  { code: 'user_management.users.destroy', name: 'Delete User' },
  { code: 'user_management.roles.index', name: 'View Roles' },
  { code: 'user_management.roles.show', name: 'Show Role' },
  { code: 'user_management.roles.create', name: 'Create Role' },
  { code: 'user_management.roles.update', name: 'Update Role' },
  { code: 'user_management.roles.destroy', name: 'Delete Role' }
]

permissions_data.each do |perm|
  Permission.find_or_create_by!(code: perm[:code]) do |p|
    p.name = perm[:name]
  end
end
puts "  Created #{Permission.count} permissions"

# Create Roles
puts "Creating roles..."
superadmin_role = Role.find_or_create_by!(name: 'superadmin')

# Assign all permissions to superadmin
Permission.find_each do |permission|
  RolePermission.find_or_create_by!(role: superadmin_role, permission: permission)
end
puts "  Created #{Role.count} roles"

# Create default superadmin user
puts "Creating default superadmin user..."
User.find_or_create_by!(email: 'admin@pilotids.com') do |user|
  user.name = 'Super Admin'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = superadmin_role
  user.is_active = true
end

puts "Seeding completed!"
puts "  Default login: admin@pilotids.com / password123"
