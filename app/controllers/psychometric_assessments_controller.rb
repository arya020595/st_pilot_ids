# frozen_string_literal: true

# Controller for Psychometric Assessment listing.
class PsychometricAssessmentsController < ApplicationController
  def index
    authorize :psychometric_assessment, :index?

    @psychometric_assessment = assessment_for_user
  end

  private

  def assessment_for_user
    return PsychometricAssessment.new if current_user.superadmin?

    staff_email = current_user.email
      staff_profile = StaffProfile.find_by(email: staff_email)
    staff_profile ||= StaffProfile.find_by(fullname: current_user.name) if current_user.name.present?

    return PsychometricAssessment.new unless staff_profile

    PsychometricAssessment.find_or_initialize_by(staff_profile_id: staff_profile.staff_profile_id)
  end
end
