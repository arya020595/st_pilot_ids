# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts 'Seeding database...'

# Create Permissions
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

# Create Roles
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

# Create default superadmin user
puts 'Creating default superadmin user...'
User.find_or_create_by!(email: 'admin@pilotids.com') do |user|
  user.name = 'Super Admin'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = superadmin_role
  user.is_active = true
end

# Create Staff Profiles
puts 'Creating staff profiles...'
staff_profiles_data = [
  {
    email: 'amirul_ids@gmail.com', fullname: 'Amirul Amirajafri', grade: '48',
    position: 'Pegawai Teknologi Maklumat', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 4, employment_level: 'Executive'
  },
  {
    email: 'fikri_ids@gmail.com', fullname: 'Fikri Haikal', grade: '51',
    position: 'Ketua Jabatan', division: 'Finance Department', supervisor_name: 'Farah Nabila',
    no_of_subordinate: 8, employment_level: 'Management'
  },
  {
    email: 'nadia_ids@gmail.com', fullname: 'Nadia Natasha', grade: '44',
    position: 'Penolong Pengarah', division: 'Admin Department', supervisor_name: 'Suhaila Ahmad',
    no_of_subordinate: 6, employment_level: 'Senior Executive'
  },
  {
    email: 'sofea_ids@gmail.com', fullname: 'Sofea Aryana', grade: '41',
    position: 'Jurutera Perisian', division: 'IT Department', supervisor_name: 'Amir Hamzah',
    no_of_subordinate: 2, employment_level: 'Executive'
  },
  {
    email: 'abubakar_ids@gmail.com', fullname: 'Abu Bakar', grade: '41',
    position: 'Eksekutif Sumber Manusia', division: 'HR Department', supervisor_name: 'Salina Mohd',
    no_of_subordinate: 3, employment_level: 'Executive'
  },
  {
    email: 'iqmal_ids@gmail.com', fullname: 'Muhd Iqmal', grade: '48',
    position: 'Pereka Grafik', division: 'Corporate Communication', supervisor_name: 'Rina Malik',
    no_of_subordinate: 1, employment_level: 'Executive'
  },
  {
    email: 'nurfatihah_ids@gmail.com', fullname: 'Nur Fatihah', grade: '44',
    position: 'Pegawai Kewangan', division: 'Finance Department', supervisor_name: 'Farah Nabila',
    no_of_subordinate: 2, employment_level: 'Senior Executive'
  },
  {
    email: 'danial_ids@gmail.com', fullname: 'Danial Khairi', grade: '41',
    position: 'Jurutera Sistem', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 2, employment_level: 'Executive'
  },
  {
    email: 'haziq_ids@gmail.com', fullname: 'Haziq Azman', grade: '36',
    position: 'Penolong Pegawai Tadbir', division: 'Admin Department', supervisor_name: 'Suhaila Ahmad',
    no_of_subordinate: 0, employment_level: 'Officer'
  },
  {
    email: 'ain_ids@gmail.com', fullname: 'Nur Ain Syazwani', grade: '29',
    position: 'Pembantu Tadbir', division: 'HR Department', supervisor_name: 'Salina Mohd',
    no_of_subordinate: 0, employment_level: 'Support'
  },
  {
    email: 'shazwan_ids@gmail.com', fullname: 'Shazwan Iskandar', grade: '41',
    position: 'Pegawai Perolehan', division: 'Procurement', supervisor_name: 'Rafidah Ismail',
    no_of_subordinate: 1, employment_level: 'Executive'
  },
  {
    email: 'syasya_ids@gmail.com', fullname: 'Syasya Huda', grade: '36',
    position: 'Eksekutif Latihan', division: 'HR Department', supervisor_name: 'Salina Mohd',
    no_of_subordinate: 0, employment_level: 'Officer'
  },
  {
    email: 'hakim_ids@gmail.com', fullname: 'Hakim Luqman', grade: '44',
    position: 'Penolong Pengarah ICT', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 5, employment_level: 'Senior Executive'
  },
  {
    email: 'khairul_ids@gmail.com', fullname: 'Khairul Nizam', grade: '29',
    position: 'Pembantu Operasi', division: 'Corporate Communication', supervisor_name: 'Rina Malik',
    no_of_subordinate: 0, employment_level: 'Support'
  },
  {
    email: 'nurul_ids@gmail.com', fullname: 'Nurul Hidayah', grade: '36',
    position: 'Pegawai Komunikasi', division: 'Corporate Communication', supervisor_name: 'Rina Malik',
    no_of_subordinate: 1, employment_level: 'Officer'
  },
  {
    email: 'aisyah_ids@gmail.com', fullname: 'Aisyah Sofina', grade: '41',
    position: 'Pegawai Integriti', division: 'Integrity Unit', supervisor_name: 'Hamdan Salleh',
    no_of_subordinate: 2, employment_level: 'Executive'
  },
  {
    email: 'zul_ids@gmail.com', fullname: 'Zulhilmi Razak', grade: '48',
    position: 'Ketua Unit Infrastruktur', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 7, employment_level: 'Management'
  },
  {
    email: 'amira_ids@gmail.com', fullname: 'Amira Syahira', grade: '29',
    position: 'Pembantu Kewangan', division: 'Finance Department', supervisor_name: 'Farah Nabila',
    no_of_subordinate: 0, employment_level: 'Support'
  },
  {
    email: 'zafirah_ids@gmail.com', fullname: 'Zafirah Adiba', grade: '36',
    position: 'Pegawai Audit Dalam', division: 'Internal Audit', supervisor_name: 'Hamdan Salleh',
    no_of_subordinate: 1, employment_level: 'Officer'
  },
  {
    email: 'fahmi_ids@gmail.com', fullname: 'Fahmi Hakimi', grade: '44',
    position: 'Penolong Pengarah Operasi', division: 'Operations', supervisor_name: 'Hamdan Salleh',
    no_of_subordinate: 4, employment_level: 'Senior Executive'
  }
]

staff_profiles_data.each do |profile|
  StaffProfile.find_or_create_by!(email: profile[:email]) do |staff_profile|
    staff_profile.fullname = profile[:fullname]
    staff_profile.grade = profile[:grade]
    staff_profile.position = profile[:position]
    staff_profile.division = profile[:division]
    staff_profile.supervisor_name = profile[:supervisor_name]
    staff_profile.no_of_subordinate = profile[:no_of_subordinate]
    staff_profile.employment_level = profile[:employment_level]
  end
end

puts "  Created #{StaffProfile.count} staff profiles"
puts 'Seeding completed!'
puts '  Default login: admin@pilotids.com / password123'
