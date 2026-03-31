# frozen_string_literal: true

# Thin controller for KPI Assessment — delegates to services, forms, presenters, and Pundit policy scopes.
class KpiAssessmentsController < ApplicationController
  before_action -> { authorize :kpi_assessment, :index? }
  before_action :set_assessment, only: %i[show edit update destroy]

  def index
    @staff_rows = policy_scope(KpiAssessment).order(updated_at: :desc)
  end

  def new
    @staff_profiles = assessable_staff_profiles.order(:fullname)
    @quality_sections = KpiScoring::QUALITY_SECTIONS
    @selected_staff_id = score_form.staff_profile_id
    @reviewed_by = score_form.reviewed_by
    @quality_input_values = score_form.quality_input_values
  end

  def step2
    @quantity_components = KpiScoring::QUANTITY_COMPONENTS
    @selected_staff_id = score_form.staff_profile_id
    @selected_staff = find_assessable_staff(@selected_staff_id)
    @reviewed_by = score_form.reviewed_by || @selected_staff&.supervisor_name
    @quality_input_values = score_form.quality_input_values

    if @selected_staff.blank?
      redirect_to new_kpi_assessment_path,
                  alert: 'Please select a staff from your allowed review list.'
      return
    end

    return if score_form.quality_valid?(@selected_staff.position)

    redirect_to new_kpi_assessment_path(score_form.previous_step_params(@selected_staff)),
                alert: 'Please fill in all quality-based scores before continuing.'
  end

  def show
    load_presenter_data
  end

  def edit
    load_presenter_data
  end

  def update
    if score_form.missing_quality_fields(@assessment.position).any? ||
       score_form.missing_quantity_fields.any?
      load_presenter_data
      flash.now[:alert] = 'Please complete all required score fields before saving.'
      render :edit, status: :unprocessable_entity
      return
    end

    KpiAssessments::UpdateService.new(assessment: @assessment, score_form: score_form).call
    redirect_to kpi_assessment_path(@assessment), notice: 'KPI assessment updated successfully.'
  rescue ActiveRecord::RecordInvalid
    load_presenter_data
    flash.now[:alert] = 'Unable to update KPI assessment. Please review entered values and try again.'
    render :edit, status: :unprocessable_entity
  end

  def destroy
    KpiAssessments::DestroyService.new(@assessment).call
    redirect_to kpi_assessments_path, notice: 'KPI assessment deleted successfully.'
  end

  def submit_preview
    @selected_staff = find_assessable_staff(score_form.staff_profile_id)

    if @selected_staff.blank?
      redirect_to new_kpi_assessment_path,
                  alert: 'Please select a staff from your allowed review list before submitting.'
      return
    end

    unless score_form.quality_valid?(@selected_staff.position)
      redirect_to new_kpi_assessment_path(score_form.previous_step_params(@selected_staff)),
                  alert: 'Please fill in all quality-based scores before continuing.'
      return
    end

    unless score_form.quantity_valid?
      redirect_to step2_kpi_assessments_path(request.request_parameters),
                  alert: 'Please fill in all quantity-based scores before submitting.'
      return
    end

    KpiAssessments::CreateService.new(
      staff_profile: @selected_staff,
      reviewer_email: current_user.email,
      score_form: score_form
    ).call

    redirect_to kpi_assessments_path, notice: 'KPI assessment saved successfully.'
  rescue ActiveRecord::RecordInvalid
    redirect_to step2_kpi_assessments_path(request.request_parameters),
                alert: 'Unable to save KPI assessment. Please review entered values and try again.'
  end

  private

  def score_form
    @score_form ||= KpiAssessments::ScoreForm.new(params)
  end

  def set_assessment
    @assessment = policy_scope(KpiAssessment).find(params[:id])
  end

  def assessable_staff_profiles
    policy_scope(StaffProfile, policy_scope_class: KpiAssessmentPolicy::AssessableStaffScope)
  end

  def find_assessable_staff(staff_profile_id)
    assessable_staff_profiles.find_by(staff_profile_id: staff_profile_id) if staff_profile_id.present?
  end

  def load_presenter_data
    presenter = KpiAssessments::ShowPresenter.new(@assessment)
    @quality_view_sections = presenter.quality_view_sections
    @quantity_view_rows = presenter.quantity_view_rows
    @quality_overall_total = presenter.quality_overall_total
    @quantity_overall_total = presenter.quantity_overall_total
    @reviewed_by = presenter.reviewed_by
  end
end
