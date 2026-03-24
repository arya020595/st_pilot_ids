# frozen_string_literal: true

puts 'Creating staff profiles...'

staff_profiles_data = [
  {
    email: 'amirul_ids@gmail.com', fullname: 'Amirul Amirajafri', grade: '48',
    position: 'Senior Research Associate', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 4, employment_level: 'Senior Associate'
  },
  {
    email: 'fikri_ids@gmail.com', fullname: 'Fikri Haikal', grade: '51',
    position: 'Senior Research Associate', division: 'Finance Department', supervisor_name: 'Farah Nabila',
    no_of_subordinate: 8, employment_level: 'Senior Associate'
  },
  {
    email: 'nadia_ids@gmail.com', fullname: 'Nadia Natasha', grade: '44',
    position: 'Research Associate', division: 'Admin Department', supervisor_name: 'Suhaila Ahmad',
    no_of_subordinate: 6, employment_level: 'Associate'
  },
  {
    email: 'sofea_ids@gmail.com', fullname: 'Sofea Aryana', grade: '41',
    position: 'Research Officer', division: 'IT Department', supervisor_name: 'Amir Hamzah',
    no_of_subordinate: 2, employment_level: 'Officer'
  },
  {
    email: 'abubakar_ids@gmail.com', fullname: 'Abu Bakar', grade: '41',
    position: 'Research Officer', division: 'HR Department', supervisor_name: 'Salina Mohd',
    no_of_subordinate: 3, employment_level: 'Officer'
  },
  {
    email: 'iqmal_ids@gmail.com', fullname: 'Muhd Iqmal', grade: '48',
    position: 'Senior Research Associate', division: 'Corporate Communication', supervisor_name: 'Rina Malik',
    no_of_subordinate: 1, employment_level: 'Senior Associate'
  },
  {
    email: 'nurfatihah_ids@gmail.com', fullname: 'Nur Fatihah', grade: '44',
    position: 'Research Associate', division: 'Finance Department', supervisor_name: 'Farah Nabila',
    no_of_subordinate: 2, employment_level: 'Associate'
  },
  {
    email: 'danial_ids@gmail.com', fullname: 'Danial Khairi', grade: '41',
    position: 'Research Officer', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 2, employment_level: 'Officer'
  },
  {
    email: 'haziq_ids@gmail.com', fullname: 'Haziq Azman', grade: '36',
    position: 'Research Assistant', division: 'Admin Department', supervisor_name: 'Suhaila Ahmad',
    no_of_subordinate: 0, employment_level: 'Assistant'
  },
  {
    email: 'ain_ids@gmail.com', fullname: 'Nur Ain Syazwani', grade: '29',
    position: 'Research Assistant', division: 'HR Department', supervisor_name: 'Salina Mohd',
    no_of_subordinate: 0, employment_level: 'Assistant'
  },
  {
    email: 'shazwan_ids@gmail.com', fullname: 'Shazwan Iskandar', grade: '41',
    position: 'Research Officer', division: 'Procurement', supervisor_name: 'Rafidah Ismail',
    no_of_subordinate: 1, employment_level: 'Officer'
  },
  {
    email: 'syasya_ids@gmail.com', fullname: 'Syasya Huda', grade: '36',
    position: 'Research Assistant', division: 'HR Department', supervisor_name: 'Salina Mohd',
    no_of_subordinate: 0, employment_level: 'Assistant'
  },
  {
    email: 'hakim_ids@gmail.com', fullname: 'Hakim Luqman', grade: '44',
    position: 'Research Associate', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 5, employment_level: 'Associate'
  },
  {
    email: 'khairul_ids@gmail.com', fullname: 'Khairul Nizam', grade: '29',
    position: 'Research Assistant', division: 'Corporate Communication', supervisor_name: 'Rina Malik',
    no_of_subordinate: 0, employment_level: 'Assistant'
  },
  {
    email: 'nurul_ids@gmail.com', fullname: 'Nurul Hidayah', grade: '36',
    position: 'Research Assistant', division: 'Corporate Communication', supervisor_name: 'Rina Malik',
    no_of_subordinate: 1, employment_level: 'Assistant'
  },
  {
    email: 'aisyah_ids@gmail.com', fullname: 'Aisyah Sofina', grade: '41',
    position: 'Research Officer', division: 'Integrity Unit', supervisor_name: 'Hamdan Salleh',
    no_of_subordinate: 2, employment_level: 'Officer'
  },
  {
    email: 'zul_ids@gmail.com', fullname: 'Zulhilmi Razak', grade: '48',
    position: 'Senior Research Associate', division: 'IT Department', supervisor_name: 'Rashid Johan',
    no_of_subordinate: 7, employment_level: 'Senior Associate'
  },
  {
    email: 'amira_ids@gmail.com', fullname: 'Amira Syahira', grade: '29',
    position: 'Research Assistant', division: 'Finance Department', supervisor_name: 'Farah Nabila',
    no_of_subordinate: 0, employment_level: 'Assistant'
  },
  {
    email: 'zafirah_ids@gmail.com', fullname: 'Zafirah Adiba', grade: '36',
    position: 'Research Assistant', division: 'Internal Audit', supervisor_name: 'Hamdan Salleh',
    no_of_subordinate: 1, employment_level: 'Assistant'
  },
  {
    email: 'fahmi_ids@gmail.com', fullname: 'Fahmi Hakimi', grade: '44',
    position: 'Research Associate', division: 'Operations', supervisor_name: 'Hamdan Salleh',
    no_of_subordinate: 4, employment_level: 'Associate'
  }
]

staff_profiles_data.each do |profile|
  staff_profile = StaffProfile.find_or_initialize_by(email: profile[:email])
  staff_profile.assign_attributes(
    fullname: profile[:fullname],
    grade: profile[:grade],
    position: profile[:position],
    division: profile[:division],
    supervisor_name: profile[:supervisor_name],
    no_of_subordinate: profile[:no_of_subordinate],
    employment_level: profile[:employment_level]
  )
  staff_profile.save!
end

puts "  Created #{StaffProfile.count} staff profiles"
