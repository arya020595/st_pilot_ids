# frozen_string_literal: true

puts 'Creating users for IDS staff...'

ids_staff_role = Role.find_by(name: 'staff')
created_or_updated = 0

IdsStaff.order(:id).find_each do |ids_staff|
  user = User.find_or_initialize_by(email: ids_staff.email)
  user.name = ids_staff.fullname
  user.ids_staff_id = ids_staff.id
  user.role ||= ids_staff_role
  user.is_active = true if user.is_active.nil?

  if user.new_record?
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end

  user.save!
  created_or_updated += 1
end

puts "  Upserted #{created_or_updated} ids_staff users"
