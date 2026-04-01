# frozen_string_literal: true

puts 'Creating KPI assessments...'

# Define KPI assessment data by staff profile
kpi_assessments_data = [
  {
    staff_profile_id: 1,
    fullname: 'Sharlyna Grace Sebastian',
    position: 'Research Assistant',
    reviewer_email: 'victor.sikain@ids.org.my'
  },
  {
    staff_profile_id: 2,
    fullname: 'Wesly Chong Ming Teck',
    position: 'Research Assistant',
    reviewer_email: 'mansalasah.musa@ids.org.my'
  },
  {
    staff_profile_id: 3,
    fullname: 'Sarah J. Marican',
    position: 'Research Assistant',
    reviewer_email: 'masmidah.arsah@ids.org.my'
  },
  {
    staff_profile_id: 4,
    fullname: 'Nur Fazila Binti Jainal',
    position: 'Research Assistant',
    reviewer_email: 'mansalasah.musa@ids.org.my'
  },
  {
    staff_profile_id: 5,
    fullname: 'Faezah Hassan',
    position: 'Research Officer',
    reviewer_email: 'mansalasah.musa@ids.org.my'
  },
  {
    staff_profile_id: 6,
    fullname: 'Roslina Binti Gumpar',
    position: 'Research Officer',
    reviewer_email: 'masmidah.arsah@ids.org.my'
  },
  {
    staff_profile_id: 7,
    fullname: 'Addellyne Christie Albert',
    position: 'Research Officer',
    reviewer_email: 'anita.limjoon@ids.org.my'
  },
  {
    staff_profile_id: 8,
    fullname: 'Sophia Hong @ Hong Sen Yee',
    position: 'Research Officer',
    reviewer_email: 'masneh.maziah@ids.org.my'
  },
  {
    staff_profile_id: 9,
    fullname: 'Nurul Hafizah Binti Abd Suhud',
    position: 'Research Officer',
    reviewer_email: 'masneh.maziah@ids.org.my'
  },
  {
    staff_profile_id: 10,
    fullname: 'Khairulazizan Safwan Bin Maidol',
    position: 'Research Officer',
    reviewer_email: 'masneh.maziah@ids.org.my'
  },
  {
    staff_profile_id: 11,
    fullname: 'Lailah Chung',
    position: 'Research Associate',
    reviewer_email: 'mansalasah.musa@ids.org.my'
  },
  {
    staff_profile_id: 12,
    fullname: 'Hajah Royaini Matusin',
    position: 'Research Associate',
    reviewer_email: 'anita.limjoon@ids.org.my'
  },
  {
    staff_profile_id: 13,
    fullname: 'Noralizah Halid',
    position: 'Research Associate',
    reviewer_email: 'masmidah.arsah@ids.org.my'
  },
  {
    staff_profile_id: 14,
    fullname: 'Mohd Rizal Bin Muslihin',
    position: 'Research Associate',
    reviewer_email: 'masmidah.arsah@ids.org.my'
  },
  {
    staff_profile_id: 15,
    fullname: 'Siti Farizan Omar',
    position: 'Research Associate',
    reviewer_email: 'masneh.maziah@ids.org.my'
  },
  {
    staff_profile_id: 16,
    fullname: 'Fiona V. Loijon',
    position: 'Research Associate',
    reviewer_email: 'anita.limjoon@ids.org.my'
  },
  {
    staff_profile_id: 17,
    fullname: 'Juliana P. J Ringgigon',
    position: 'Senior Research Associate',
    reviewer_email: 'mansalasah.musa@ids.org.my'
  },
  {
    staff_profile_id: 18,
    fullname: 'Masmidah Arsah',
    position: 'Senior Research Associate',
    reviewer_email: 'victor.sikain@ids.org.my'
  },
  {
    staff_profile_id: 19,
    fullname: 'Masneh Abd. Ghani',
    position: 'Senior Research Associate',
    reviewer_email: 'victor.sikain@ids.org.my'
  },
  {
    staff_profile_id: 20,
    fullname: 'Mansalasah Musa',
    position: 'Senior Research Associate',
    reviewer_email: 'victor.sikain@ids.org.my'
  }
]

kpi_assessments_data.each do |assessment_data|
  # Find or create KPI assessment
  kpi_assessment = KpiAssessment.find_or_initialize_by(staff_profile_id: assessment_data[:staff_profile_id])
  kpi_assessment.assign_attributes(
    fullname: assessment_data[:fullname],
    position: assessment_data[:position],
    reviewer_email: assessment_data[:reviewer_email]
  )
  kpi_assessment.save!
end

puts "  Created #{KpiAssessment.count} KPI assessments"
