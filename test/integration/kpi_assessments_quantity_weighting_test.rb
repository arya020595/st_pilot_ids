# frozen_string_literal: true

require 'test_helper'

# rubocop:disable Metrics/ClassLength
class KpiAssessmentsQuantityWeightingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    superadmin_role = Role.find_or_create_by!(name: 'superadmin')

    @user = User.create!(
      name: 'Supervisor QA',
      email: "qa-#{SecureRandom.hex(6)}@example.com",
      password: 'password123',
      password_confirmation: 'password123',
      role: superadmin_role
    )

    @staff_profile = StaffProfile.create!(
      fullname: 'Test Staff',
      position: 'Research Assistant',
      division: 'Division A',
      supervisor_name: 'Supervisor QA',
      supervisor_email: @user.email
    )

    sign_in @user
  end

  test 'submit preview computes quantity overall total as 100 for max inputs' do
    post submit_preview_kpi_assessments_path, params: submission_params(quantity_max_inputs)

    assert_redirected_to kpi_assessments_path

    assessment = KpiAssessment.order(created_at: :desc).first
    quarter = assessment.quarters.order(created_at: :desc).first
    quantity_kpi = quarter.quantity_based_kpi
    quality_kpi = quarter.quality_based_kpi
    output = quantity_kpi.output_and_impact_based

    assert_in_delta 100.0, quantity_kpi.overall_total.to_f, 0.01
    assert_in_delta quantity_kpi.overall_total.to_f, assessment.quantity_based_total.to_f, 0.01
    assert_in_delta quality_kpi.overall_total.to_f, assessment.quality_based_total.to_f, 0.01
    expected_overall = (quality_kpi.overall_total.to_d * 0.60) + (quantity_kpi.overall_total.to_d * 0.40)
    assert_in_delta expected_overall.to_f, assessment.overall_score.to_f, 0.01
    assert_in_delta 7.0, output.number_of_involvement.to_f, 0.01
    assert_in_delta 4.0, output.output_production.to_f, 0.01
    assert_in_delta 3.0, output.presentation_national_level.to_f, 0.01
  end

  test 'submit preview computes quantity overall total as 50 for half inputs' do
    post submit_preview_kpi_assessments_path, params: submission_params(quantity_half_inputs)

    assert_redirected_to kpi_assessments_path

    assessment = KpiAssessment.order(created_at: :desc).first
    quarter = assessment.quarters.order(created_at: :desc).first
    quantity_kpi = quarter.quantity_based_kpi
    quality_kpi = quarter.quality_based_kpi

    assert_in_delta 50.0, quantity_kpi.overall_total.to_f, 0.01
    assert_in_delta quantity_kpi.overall_total.to_f, assessment.quantity_based_total.to_f, 0.01
    assert_in_delta quality_kpi.overall_total.to_f, assessment.quality_based_total.to_f, 0.01
    expected_overall = (quality_kpi.overall_total.to_d * 0.60) + (quantity_kpi.overall_total.to_d * 0.40)
    assert_in_delta expected_overall.to_f, assessment.overall_score.to_f, 0.01
  end

  test 'update recalculates overall score when quantity changes' do
    post submit_preview_kpi_assessments_path, params: submission_params(quantity_max_inputs)

    assessment = KpiAssessment.order(created_at: :desc).first
    original_overall = assessment.overall_score.to_f

    patch kpi_assessment_path(assessment), params: submission_params(quantity_half_inputs)

    assert_redirected_to kpi_assessment_path(assessment)

    assessment.reload
    quarter = assessment.quarters.order(created_at: :desc).first
    quality_kpi = quarter.quality_based_kpi
    quantity_kpi = quarter.quantity_based_kpi
    expected_overall = (quality_kpi.overall_total.to_d * 0.60) + (quantity_kpi.overall_total.to_d * 0.40)

    assert_in_delta expected_overall.to_f, assessment.overall_score.to_f, 0.01
    assert_not_equal original_overall.round(2), assessment.overall_score.to_f.round(2)
  end

  test 'submit preview rejects over max quantity input' do
    assert_no_difference 'KpiAssessment.count' do
      post submit_preview_kpi_assessments_path,
           params: submission_params(quantity_max_inputs.merge(number_of_involvement: '8'))
    end

    assert_response :redirect
    assert_includes response.redirect_url, '/kpi_assessments/new'
  end

  test 'show page renders quantity numbers without percent and weighted actual score with percent' do
    post submit_preview_kpi_assessments_path, params: submission_params(quantity_max_inputs)

    assessment = KpiAssessment.order(created_at: :desc).first
    get kpi_assessment_path(assessment)

    assert_response :success
    assert_includes response.body, 'Maximum Number (Qty)'
    assert_includes response.body, 'Actual Number (Qty)'

    row = Nokogiri::HTML(response.body)
      .css('table.kpi-score-table tbody tr')
      .find { |tr| tr.css('td').first&.text&.strip == 'Number of Involvement' }

    assert row.present?, 'Expected to find the Number of Involvement row'
    assert_equal(
      ['Number of Involvement', '20.0%', '7', '7', '20.0%'],
      row.css('td').map { |td| td.text.strip }
    )
  end

  private

  def submission_params(quantity_inputs)
    {
      staff_profile_id: @staff_profile.staff_profile_id,
      reviewed_by: @user.name
    }.merge(quality_inputs).merge(quantity_inputs)
  end

  def quality_inputs
    {
      proposal_preparation: '1',
      proposal_presentation: '1',
      data_collection: '1',
      data_entry_and_cleaning: '1',
      report_writing: '1',
      analysis_of_data: '1',
      presentation_of_findings: '1',
      budgeting: '1',
      record_keeping: '1',
      cashflow_management: '1',
      compliance: '1',
      writing_skill: '1',
      presentation_skill: '1',
      computer_skill: '1',
      management_skill: '1',
      statistical_knowledge: '1',
      communication_skill: '1',
      collaboration_teamwork: '1',
      problem_solving: '1',
      leadership: '1',
      attention_details: '1',
      ideas_platform: '1',
      any_social_media_platform: '1',
      ids_watch_column: '1',
      others: '1'
    }
  end

  def quantity_max_inputs
    {
      number_of_involvement: '7',
      output_production: '4',
      acceptance_of_outputs: '4',
      uptake_of_outputs: '2',
      presentation_state_level: '5',
      presentation_national_level: '3'
    }
  end

  def quantity_half_inputs
    {
      number_of_involvement: '3.5',
      output_production: '2',
      acceptance_of_outputs: '2',
      uptake_of_outputs: '1',
      presentation_state_level: '2.5',
      presentation_national_level: '1.5'
    }
  end
end
# rubocop:enable Metrics/ClassLength
