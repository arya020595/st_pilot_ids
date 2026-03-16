# frozen_string_literal: true

puts 'Creating permissions...'

permissions_data = [
  { code: 'dashboard.index', name: 'View Dashboard' },
  { code: 'bi_dashboards.index', name: 'View BI Dashboard' },
  { code: 'staff_profiles.index', name: 'View Staff Profile' },
  { code: 'psychometric_assessments.index', name: 'View Psychometric Assessment' },
  { code: 'kpi_assessments.index', name: 'View KPI Assessment' },
  { code: 'master_data.ids_staffs.index', name: 'View IDS Staff' },
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
