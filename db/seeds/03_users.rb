# frozen_string_literal: true

puts 'Creating default superadmin user...'

superadmin_role = Role.find_by!(name: 'superadmin')
supervisor_role = Role.find_by!(name: 'supervisor')

User.find_or_create_by!(email: 'admin@pilotids.com') do |user|
  user.name = 'Super Admin'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = superadmin_role
  user.is_active = true
end

puts "  Superadmin user created/verified"
puts '  Default login: admin@pilotids.com / password123'

puts 'Creating supervisor users...'

supervisor_password = 'supervisor123'
supervisors = [
  { name: 'Victor Sikain', email: 'victor.sikain@ids.org.my' },
  { name: 'Mansalasah Musa', email: 'mansalasah.musa@ids.org.my' },
  { name: 'Masmidah Arsah', email: 'masmidah.arsah@ids.org.my' },
  { name: 'Anita Limjoon', email: 'anita.limjoon@ids.org.my' },
  { name: 'Masneh Maziah', email: 'masneh.maziah@ids.org.my' }
]

supervisors.each do |supervisor|
  user = User.find_or_initialize_by(email: supervisor[:email])
  user.assign_attributes(
    name: supervisor[:name],
    role: supervisor_role,
    is_active: true
  )

  if user.new_record?
    user.password = supervisor_password
    user.password_confirmation = supervisor_password
  end

  user.save!
end

puts "  Created #{supervisors.size} supervisor users"
puts "  Supervisor default password: #{supervisor_password}"
