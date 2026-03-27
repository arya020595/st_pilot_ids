# frozen_string_literal: true

class ValidatePsychometricAssessmentsStaffProfileFk < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :psychometric_assessments,
                         :staff_profiles,
                         column: :staff_profile_id
  end
end
