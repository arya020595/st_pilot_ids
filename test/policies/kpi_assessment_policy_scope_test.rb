# frozen_string_literal: true

require 'test_helper'

class KpiAssessmentPolicyScopeTest < ActiveSupport::TestCase
  # -- KpiAssessmentPolicy::Scope (scopes KpiAssessment) --

  test 'superadmin sees all kpi assessments' do
    scope = KpiAssessmentPolicy::Scope.new(users(:admin), KpiAssessment.all).resolve
    assert_equal KpiAssessment.count, scope.count
  end

  test 'non-superadmin only sees own reviews' do
    supervisor = users(:supervisor_user)

    staff = staff_profiles(:research_officer)
    form = KpiAssessments::ScoreForm.new(
      KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
        .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '5' })
        .with_indifferent_access
    )
    KpiAssessments::CreateService.new(
      staff_profile: staff,
      reviewer_email: supervisor.email,
      score_form: form
    ).call

    scope = KpiAssessmentPolicy::Scope.new(supervisor, KpiAssessment.all).resolve
    assert_equal 1, scope.count
    assert_equal supervisor.email, scope.first.reviewer_email
  end

  # -- KpiAssessmentPolicy::AssessableStaffScope (scopes StaffProfile for KPI) --

  test 'superadmin can assess all staff profiles' do
    scope = KpiAssessmentPolicy::AssessableStaffScope.new(users(:admin), StaffProfile.all).resolve
    assert_equal StaffProfile.count, scope.count
  end

  test 'supervisor can assess all staff profiles' do
    scope = KpiAssessmentPolicy::AssessableStaffScope.new(users(:supervisor_user), StaffProfile.all).resolve
    assert_equal StaffProfile.count, scope.count
  end

  test 'regular user sees only direct reports from DB supervisor_name' do
    user = users(:other_supervisor_user)
    scope = KpiAssessmentPolicy::AssessableStaffScope.new(user, StaffProfile.all).resolve

    assert_equal 1, scope.count
    assert_equal 'Bob Wilson', scope.first.fullname
  end

  test 'regular user with no reports sees empty list' do
    user = users(:staff_user)
    scope = KpiAssessmentPolicy::AssessableStaffScope.new(user, StaffProfile.all).resolve

    assert_equal 0, scope.count
  end
end
