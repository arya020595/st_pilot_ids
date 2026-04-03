# frozen_string_literal: true

puts 'Creating staff profiles...'

staff_profiles_data = [
  {
    fullname: 'Sharlyna Grace Sebastian',
    position: 'Research Assistant', division: 'CRO Office', supervisor_name: 'Victor Sikain',
    supervisor_email: 'victor.sikain@ids.org.my'
  },
  {
    fullname: 'Wesly Chong Ming Teck',
    position: 'Research Assistant', division: 'SPPD', supervisor_name: 'Mansalasah Musa',
    supervisor_email: 'mansalasah.musa@ids.org.my'
  },
  {
    fullname: 'Sarah J. Marican',
    position: 'Research Assistant', division: 'GED', supervisor_name: 'Masmidah Arsah',
    supervisor_email: 'masmidah.arsah@ids.org.my'
  },
  {
    fullname: 'Nur Fazila Binti Jainal',
    position: 'Research Assistant', division: 'SPPD', supervisor_name: 'Mansalasah Musa',
    supervisor_email: 'mansalasah.musa@ids.org.my'
  },
  {
    fullname: 'Faezah Hassan',
    position: 'Research Officer', division: 'SPPD', supervisor_name: 'Mansalasah Musa',
    supervisor_email: 'mansalasah.musa@ids.org.my'
  },
  {
    fullname: 'Roslina Binti Gumpar',
    position: 'Research Officer', division: 'GED', supervisor_name: 'Masmidah Arsah',
    supervisor_email: 'masmidah.arsah@ids.org.my'
  },
  {
    fullname: 'Addellyne Christie Albert',
    position: 'Research Officer', division: 'RDD', supervisor_name: 'Anita Limjoon',
    supervisor_email: 'anita.limjoon@ids.org.my'
  },
  {
    fullname: 'Sophia Hong @ Hong Sen Yee',
    position: 'Research Officer', division: 'SDD', supervisor_name: 'Masneh Maziah',
    supervisor_email: 'masneh.maziah@ids.org.my'
  },
  {
    fullname: 'Nurul Hafizah Binti Abd Suhud',
    position: 'Research Officer', division: 'SDD', supervisor_name: 'Masneh Maziah',
    supervisor_email: 'masneh.maziah@ids.org.my'
  },
  {
    fullname: 'Khairulazizan Safwan Bin Maidol',
    position: 'Research Officer', division: 'SDD', supervisor_name: 'Masneh Maziah',
    supervisor_email: 'masneh.maziah@ids.org.my'
  },
  {
    fullname: 'Lailah Chung',
    position: 'Research Associate', division: 'SPPD', supervisor_name: 'Mansalasah Musa',
    supervisor_email: 'mansalasah.musa@ids.org.my'
  },
  {
    fullname: 'Fernando Jerry',
    position: 'Research Officer', division: '', supervisor_name: 'Alexzander Bin Palik',
    supervisor_email: 'alexzander.palik@ids.org.my'
  },
  {
    fullname: 'Noralizah Halid',
    position: 'Research Associate', division: 'GED', supervisor_name: 'Masmidah Arsah',
    supervisor_email: 'masmidah.arsah@ids.org.my'
  },
  {
    fullname: 'Mohd Rizal Bin Muslihin',
    position: 'Research Associate', division: 'GED', supervisor_name: 'Masmidah Arsah',
    supervisor_email: 'masmidah.arsah@ids.org.my'
  },
  {
    fullname: 'Siti Farizan Omar',
    position: 'Research Associate', division: 'SDD', supervisor_name: 'Masneh Maziah',
    supervisor_email: 'masneh.maziah@ids.org.my'
  },
  {
    fullname: 'Fiona V. Loijon',
    position: 'Research Associate', division: 'RDD', supervisor_name: 'Anita Limjoon',
    supervisor_email: 'anita.limjoon@ids.org.my'
  },
  {
    fullname: 'Juliana P. J Ringgigon',
    position: 'Senior Research Associate', division: 'SPPD', supervisor_name: 'Mansalasah Musa',
    supervisor_email: 'mansalasah.musa@ids.org.my'
  },
  {
    fullname: 'Masmidah Arsah',
    position: 'Senior Research Associate', division: 'Head of GED', supervisor_name: 'Victor Sikain',
    supervisor_email: 'victor.sikain@ids.org.my'
  },
  {
    fullname: 'Masneh Abd. Ghani',
    position: 'Senior Research Associate', division: 'Head of SDD', supervisor_name: 'Victor Sikain',
    supervisor_email: 'victor.sikain@ids.org.my'
  },
  {
    fullname: 'Mansalasah Musa',
    position: 'Senior Research Associate', division: 'Head of SPPD', supervisor_name: 'Victor Sikain',
    supervisor_email: 'victor.sikain@ids.org.my'
  }
]

staff_profiles_data.each_with_index do |profile, index|
  staff_profile = StaffProfile.find_or_initialize_by(staff_profile_id: index + 1)
  staff_profile.assign_attributes(
    fullname: profile[:fullname],
    position: profile[:position],
    division: profile[:division],
    supervisor_name: profile[:supervisor_name],
    supervisor_email: profile[:supervisor_email]
  )
  staff_profile.save!
end

puts "  Created #{StaffProfile.count} staff profiles"
