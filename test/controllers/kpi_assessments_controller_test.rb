# frozen_string_literal: true

require 'test_helper'

class KpiAssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @supervisor = users(:supervisor_user)
    @staff_profile = staff_profiles(:research_officer)
    sign_in @admin
  end

  # -- Helpers --

  def full_quality_params
    KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
  end

  def full_quantity_params
    KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '5' }
  end

  def all_score_params
    full_quality_params.merge(full_quantity_params)
  end

  def create_assessment_via_service!(user: @admin, staff: @staff_profile)
    params_hash = all_score_params.merge(
      staff_profile_id: staff.staff_profile_id.to_s,
      reviewed_by: 'Admin User'
    )
    form = KpiAssessments::ScoreForm.new(params_hash.with_indifferent_access)
    KpiAssessments::CreateService.new(
      staff_profile: staff,
      reviewer_email: user.email,
      score_form: form
    ).call
  end

  # -- Index --

  test 'index returns success for authorized user' do
    get kpi_assessments_path
    assert_response :success
  end

  test 'index scopes assessments to reviewer for non-superadmin' do
    assessment = create_assessment_via_service!(user: @admin)
    sign_in @supervisor

    get kpi_assessments_path
    assert_response :success
    # Supervisor should not see admin's assessment
    assert_no_match assessment.fullname, response.body
  end

  # -- New --

  test 'new returns success with staff dropdown' do
    get new_kpi_assessment_path
    assert_response :success
    assert_match @staff_profile.fullname, response.body
  end

  test 'supervisor sees all staff profiles in new' do
    sign_in @supervisor
    get new_kpi_assessment_path
    assert_response :success
    staff_profiles(:research_associate) # different supervisor
    assert_match 'Bob Wilson', response.body
  end

  # -- Step2 --

  test 'step2 redirects when no staff selected' do
    get step2_kpi_assessments_path
    assert_redirected_to new_kpi_assessment_path
    assert_equal 'Please select a staff from your allowed review list.', flash[:alert]
  end

  test 'step2 redirects when quality scores missing' do
    get step2_kpi_assessments_path(staff_profile_id: @staff_profile.staff_profile_id)
    assert_response :redirect
    assert_match %r{/kpi_assessments/new}, response.location
  end

  test 'step2 renders when all quality scores provided' do
    params = full_quality_params.merge(
      staff_profile_id: @staff_profile.staff_profile_id,
      reviewed_by: 'Admin User'
    )
    get step2_kpi_assessments_path(params)
    assert_response :success
    assert_match 'Output and Impact Based', response.body
  end

  # -- Submit Preview (Create) --

  test 'submit_preview creates assessment with complete params' do
    params = all_score_params.merge(
      staff_profile_id: @staff_profile.staff_profile_id,
      reviewed_by: 'Admin User'
    )

    assert_difference 'KpiAssessment.count', 1 do
      post submit_preview_kpi_assessments_path, params: params
    end

    assert_redirected_to kpi_assessments_path
    assert_equal 'KPI assessment saved successfully.', flash[:notice]
  end

  test 'submit_preview redirects when staff missing' do
    post submit_preview_kpi_assessments_path, params: all_score_params
    assert_redirected_to new_kpi_assessment_path
  end

  test 'submit_preview redirects when quality scores missing' do
    params = full_quantity_params.merge(staff_profile_id: @staff_profile.staff_profile_id)
    post submit_preview_kpi_assessments_path, params: params
    assert_response :redirect
  end

  test 'submit_preview redirects when quantity scores missing' do
    params = full_quality_params.merge(staff_profile_id: @staff_profile.staff_profile_id)
    post submit_preview_kpi_assessments_path, params: params
    assert_response :redirect
    assert_match 'quantity', flash[:alert]
  end

  # -- Show --

  test 'show displays assessment data' do
    assessment = create_assessment_via_service!

    get kpi_assessment_path(assessment)
    assert_response :success
    assert_match assessment.fullname, response.body
  end

  # -- Edit --

  test 'edit displays assessment form' do
    assessment = create_assessment_via_service!

    get edit_kpi_assessment_path(assessment)
    assert_response :success
    assert_match 'Edit Scores', response.body
  end

  # -- Update --

  test 'update saves changes with valid params' do
    assessment = create_assessment_via_service!

    patch kpi_assessment_path(assessment), params: all_score_params
    assert_redirected_to kpi_assessment_path(assessment)
    assert_equal 'KPI assessment updated successfully.', flash[:notice]
  end

  test 'update rejects incomplete params' do
    assessment = create_assessment_via_service!

    patch kpi_assessment_path(assessment), params: { proposal_preparation: '5' }
    assert_response :unprocessable_entity
  end

  # -- Destroy --

  test 'destroy removes assessment and all children' do
    assessment = create_assessment_via_service!

    assert_difference 'KpiAssessment.count', -1 do
      delete kpi_assessment_path(assessment)
    end

    assert_redirected_to kpi_assessments_path
    assert_equal 'KPI assessment deleted successfully.', flash[:notice]
    assert_equal 0, Quarter.where(kpi_assessment_id: assessment.id).count
  end

  # -- Authorization --

  test 'unauthenticated user redirected to sign in' do
    sign_out @admin
    get kpi_assessments_path
    assert_response :redirect
  end
end
