# frozen_string_literal: true

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
