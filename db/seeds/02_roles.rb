# frozen_string_literal: true

puts 'Creating roles...'

superadmin_role = Role.find_or_create_by!(name: 'superadmin')

# Assign all permissions to superadmin
Permission.find_each do |permission|
  RolePermission.find_or_create_by!(role: superadmin_role, permission: permission)
end

# Create staff role with limited permissions
staff_role = Role.find_or_create_by!(name: 'staff')

staff_permission_codes = %w[
  dashboard.index
  bi_dashboards.index
  staff_profiles.index
  psychometric_assessments.index
  kpi_assessments.index
  master_data.ids_staffs.index
]

staff_permission_codes.each do |code|
  permission = Permission.find_by!(code: code)
  RolePermission.find_or_create_by!(role: staff_role, permission: permission)
end

puts "  Created #{Role.count} roles"
