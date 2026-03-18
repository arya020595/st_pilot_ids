# frozen_string_literal: true

puts 'Creating IDS staffs...'

ids_staff_data = [
  { code: 'IDS001', email: 'azlan.ids@pilotids.com', fullname: 'Azlan Hakim', grade: '48', division: 'IT Department' },
  { code: 'IDS002', email: 'balqis.ids@pilotids.com', fullname: 'Balqis Hanani', grade: '44',
    division: 'Finance Department' },
  { code: 'IDS003', email: 'chong.ids@pilotids.com', fullname: 'Chong Wei Jian', grade: '41', division: 'Operations' },
  { code: 'IDS004', email: 'danish.ids@pilotids.com', fullname: 'Danish Firdaus', grade: '36',
    division: 'HR Department' },
  { code: 'IDS005', email: 'ezzati.ids@pilotids.com', fullname: 'Ezzati Nadia', grade: '41',
    division: 'Admin Department' },
  { code: 'IDS006', email: 'farid.ids@pilotids.com', fullname: 'Farid Iskandar', grade: '48',
    division: 'Integrity Unit' },
  { code: 'IDS007', email: 'grace.ids@pilotids.com', fullname: 'Grace Lim', grade: '36',
    division: 'Corporate Communication' },
  { code: 'IDS008', email: 'hafiz.ids@pilotids.com', fullname: 'Hafiz Ramli', grade: '44', division: 'Internal Audit' },
  { code: 'IDS009', email: 'ilham.ids@pilotids.com', fullname: 'Ilham Syafiq', grade: '29', division: 'Procurement' },
  { code: 'IDS010', email: 'jasmine.ids@pilotids.com', fullname: 'Jasmine Kaur', grade: '51',
    division: 'Strategy Office' }
]

ids_staff_data.each do |data|
  ids_staff = IdsStaff.find_or_initialize_by(code: data[:code])
  ids_staff.email = data[:email]
  ids_staff.fullname = data[:fullname]
  ids_staff.grade = data[:grade]
  ids_staff.division = data[:division]
  ids_staff.save!
end

puts "  Upserted #{ids_staff_data.size} ids_staff records"
