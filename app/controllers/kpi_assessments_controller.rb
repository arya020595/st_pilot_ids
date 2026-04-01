# frozen_string_literal: true

# Controller for KPI Assessment listing.
# rubocop:disable Metrics/ClassLength
class KpiAssessmentsController < ApplicationController
  QUALITY_SCORE_FIELDS = %w[
    proposal_preparation
    proposal_presentation
    data_collection
    data_entry_and_cleaning
    report_writing
    analysis_of_data
    presentation_of_findings
    budgeting
    record_keeping
    cashflow_management
    compliance
    writing_skill
    presentation_skill
    computer_skill
    management_skill
    statistical_knowledge
    communication_skill
    collaboration_teamwork
    problem_solving
    leadership
    attention_details
    ideas_platform
    any_social_media_platform
    ids_watch_column
    others
  ].freeze

  QUANTITY_SCORE_FIELDS = %w[
    number_of_involvement
    output_production
    acceptance_of_outputs
    uptake_of_outputs
    presentation_state_level
    presentation_national_level
  ].freeze

  QUANTITY_COMPONENTS = [
    {
      field: 'number_of_involvement',
      label: 'Number of Involvement',
      weight_percent: 20,
      max_input_percent: 7
    },
    {
      field: 'output_production',
      label: 'Output Production',
      weight_percent: 30,
      max_input_percent: 4
    },
    {
      field: 'acceptance_of_outputs',
      label: 'Acceptance of Outputs',
      weight_percent: 15,
      max_input_percent: 4
    },
    {
      field: 'uptake_of_outputs',
      label: 'Uptake of Outputs',
      weight_percent: 10,
      max_input_percent: 2
    },
    {
      field: 'presentation_state_level',
      label: 'Presentation (State - Level)',
      weight_percent: 10,
      max_input_percent: 5
    },
    {
      field: 'presentation_national_level',
      label: 'Presentation (National - Level)',
      weight_percent: 15,
      max_input_percent: 3
    }
  ].freeze

  # Position-based Step 1 scope. Keep as allow-list so future roles can be added safely.
  QUALITY_ALLOWED_FIELDS_BY_POSITION = {
    'research assistant' => %w[
      data_collection
      data_entry_and_cleaning
      communication_skill
      collaboration_teamwork
      attention_details
      ideas_platform
      any_social_media_platform
      ids_watch_column
      others
    ].freeze,
    'research associate' => (QUALITY_SCORE_FIELDS - %w[data_entry_and_cleaning]).freeze,
    'senior research associate' => (QUALITY_SCORE_FIELDS - %w[data_collection data_entry_and_cleaning]).freeze
  }.freeze

  SECTION_FIELDS = {
    'A' => %w[
      proposal_preparation
      proposal_presentation
      data_collection
      data_entry_and_cleaning
      report_writing
      analysis_of_data
      presentation_of_findings
    ].freeze,
    'B' => %w[budgeting record_keeping cashflow_management compliance].freeze,
    'C' => %w[writing_skill presentation_skill computer_skill management_skill statistical_knowledge].freeze,
    'D' => %w[communication_skill collaboration_teamwork problem_solving leadership attention_details].freeze,
    'E' => %w[ideas_platform any_social_media_platform ids_watch_column others].freeze
  }.freeze

  RESEARCH_FIELDS = %w[
    proposal_preparation
    proposal_presentation
    data_collection
    data_entry_and_cleaning
    report_writing
    analysis_of_data
    presentation_of_findings
  ].freeze

  FINANCIAL_FIELDS = %w[
    budgeting
    record_keeping
    cashflow_management
    compliance
  ].freeze

  SOFT_FIELDS = %w[
    writing_skill
    presentation_skill
    computer_skill
    management_skill
    statistical_knowledge
  ].freeze

  HARD_FIELDS = %w[
    communication_skill
    collaboration_teamwork
    problem_solving
    leadership
    attention_details
  ].freeze

  OTHER_FIELDS = %w[
    ideas_platform
    any_social_media_platform
    ids_watch_column
    others
  ].freeze

  QUALITY_SECTIONS = [
    {
      title: 'A. Research Work Related',
      section_weight: '70%',
      rows: [
        ['proposal_preparation', 'Proposal Preparation', '10%'],
        ['proposal_presentation', 'Proposal Presentation', '10%'],
        ['data_collection', 'Data Collection', '10%'],
        ['data_entry_and_cleaning', 'Data Entry and Cleaning', '10%'],
        ['report_writing', 'Report Writing', '30%'],
        ['analysis_of_data', 'Analysis of Data', '15%'],
        ['presentation_of_findings', 'Presentation of Findings', '15%']
      ]
    },
    {
      title: 'B. Financial Management',
      section_weight: '10%',
      rows: [
        ['budgeting', 'Budgeting', '25%'],
        ['record_keeping', 'Record-keeping', '25%'],
        ['cashflow_management', 'Cash-flow Management', '25%'],
        ['compliance', 'Compliance', '25%']
      ]
    },
    {
      title: 'C. Soft-Skill',
      section_weight: '10%',
      rows: [
        ['writing_skill', 'Writing Skill', '25%'],
        ['presentation_skill', 'Presentation Skill', '25%'],
        ['computer_skill', 'Computer Skills', '25%'],
        ['management_skill', 'Management Skill', '25%'],
        ['statistical_knowledge', 'Statistical Knowledge', '25%']
      ]
    },
    {
      title: 'D. Hard-skill',
      section_weight: '5%',
      rows: [
        ['communication_skill', 'Communication Skill', '20%'],
        ['collaboration_teamwork', 'Collaboration and Team Work', '20%'],
        ['problem_solving', 'Problem Solving', '20%'],
        ['leadership', 'Leadership', '20%'],
        ['attention_details', 'Attention to Details', '20%']
      ]
    },
    {
      title: 'E. Other Involvement',
      section_weight: '5%',
      rows: [
        ['ideas_platform', 'IDEAS Platform', '25%'],
        ['any_social_media_platform', 'Any Social Media Platforms', '25%'],
        ['ids_watch_column', 'IDS Watch Column', '25%'],
        ['others', 'Others', '25%']
      ]
    }
  ].freeze

  DEFAULT_FULL_SCORES = {
    'proposal_preparation' => 10,
    'proposal_presentation' => 10,
    'data_collection' => 10,
    'data_entry_and_cleaning' => 10,
    'report_writing' => 30,
    'analysis_of_data' => 15,
    'presentation_of_findings' => 15,
    'budgeting' => 25,
    'record_keeping' => 25,
    'cashflow_management' => 25,
    'compliance' => 25,
    'writing_skill' => 25,
    'presentation_skill' => 25,
    'computer_skill' => 25,
    'management_skill' => 25,
    'statistical_knowledge' => 25,
    'communication_skill' => 20,
    'collaboration_teamwork' => 20,
    'problem_solving' => 20,
    'leadership' => 20,
    'attention_details' => 20,
    'ideas_platform' => 25,
    'any_social_media_platform' => 25,
    'ids_watch_column' => 25,
    'others' => 25
  }.freeze

  DEFAULT_SECTION_WEIGHTS = {
    'A' => 70,
    'B' => 10,
    'C' => 10,
    'D' => 5,
    'E' => 5
  }.freeze

  SUPERVISOR_STAFF_MAP = {
    'victor sikain' => [
      'Sharlyna Grace Sebastian',
      'Masmidah Arsah',
      'Masneh Abd. Ghani',
      'Mansalasah Musa'
    ].freeze,
    'mansalasah musa' => [
      'Wesly Chong Ming Teck',
      'Nur Fazila Binti Jainal',
      'Faezah Hassan',
      'Lailah Chung',
      'Juliana P.J Ringgigon'
    ].freeze,
    'masmidah arsah' => [
      'Sarah J. Marican',
      'Roslina Binti Gumpar',
      'Noralizah Halid',
      'Mohd Rizal Bin Muslihin'
    ].freeze,
    'anita limjoon' => [
      'Hajah Royaini Matusin',
      'Fiona V. Loijon',
      'Addellyne Christie Albert'
    ].freeze
  }.freeze

  before_action :set_assessment, only: %i[show edit update destroy]

  def index
    authorize :kpi_assessment, :index?

    @staff_rows = scoped_kpi_history.order(updated_at: :desc)
  end

  def new
    authorize :kpi_assessment, :index?

    @staff_profiles = available_staff_profiles.order(:fullname)
    @quality_sections = quality_sections
    @selected_staff_id = params[:staff_profile_id].presence
    @reviewed_by = params[:reviewed_by].presence
    @quality_input_values = quality_input_values_from_params
  end

  def step2
    authorize :kpi_assessment, :index?

    @quantity_components = quantity_components
    @selected_staff_id = params[:staff_profile_id].presence
    @selected_staff = find_selected_staff(@selected_staff_id)
    @reviewed_by = params[:reviewed_by].presence || @selected_staff&.supervisor_name
    @quality_input_values = quality_input_values_from_params

    if @selected_staff.blank?
      redirect_to new_kpi_assessment_path,
                  alert: 'Please select a staff from your allowed review list.'
      return
    end

    return unless missing_quality_score_fields.any? || @selected_staff_id.blank?

    redirect_to new_kpi_assessment_path(previous_step_params),
                alert: 'Please fill in all quality-based scores before continuing.'
  end

  def show
    authorize :kpi_assessment, :index?

    build_assessment_view_data
  end

  def edit
    authorize :kpi_assessment, :index?

    build_assessment_view_data
  end

  def update
    authorize :kpi_assessment, :index?

    ensure_assessment_records_for_update!

    missing_quality = missing_quality_for_position(@assessment.position)
    missing_quantity = missing_quantity_score_fields

    if missing_quality.any? || missing_quantity.any?
      build_assessment_view_data
      flash.now[:alert] = 'Please complete all required score fields before saving.'
      render :edit, status: :unprocessable_entity
      return
    end

    if quantity_scores_out_of_range_fields.any?
      build_assessment_view_data
      flash.now[:alert] = quantity_out_of_range_message
      render :edit, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      update_quality_records!(@quality_kpi, @assessment.position)
      update_quantity_records!(@quantity_kpi)
      @assessment.touch
    end

    redirect_to kpi_assessment_path(@assessment), notice: 'KPI assessment updated successfully.'
  rescue ActiveRecord::RecordInvalid
    build_assessment_view_data
    flash.now[:alert] = 'Unable to update KPI assessment. Please review entered values and try again.'
    render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize :kpi_assessment, :index?

    destroy_assessment_tree!(@assessment)
    redirect_to kpi_assessments_path, notice: 'KPI assessment deleted successfully.'
  end

  def submit_preview
    authorize :kpi_assessment, :index?

    @selected_staff_id = params[:staff_profile_id].presence
    @selected_staff = find_selected_staff(@selected_staff_id)

    if @selected_staff.blank?
      redirect_to new_kpi_assessment_path,
                  alert: 'Please select a staff from your allowed review list before submitting.'
      return
    end

    if missing_quality_score_fields.any?
      redirect_to new_kpi_assessment_path(previous_step_params),
                  alert: 'Please fill in all quality-based scores before continuing.'
      return
    end

    if missing_quantity_score_fields.any?
      redirect_to step2_kpi_assessments_path(request.request_parameters),
                  alert: 'Please fill in all quantity-based scores before submitting.'
      return
    end

    if quantity_scores_out_of_range_fields.any?
      redirect_to step2_kpi_assessments_path(request.request_parameters),
                  alert: quantity_out_of_range_message
      return
    end

    begin
      ActiveRecord::Base.transaction do
        create_assessment_records!(@selected_staff)
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to step2_kpi_assessments_path(request.request_parameters),
                  alert: 'Unable to save KPI assessment. Please review entered values and try again.'
      return
    end

    redirect_to kpi_assessments_path,
                notice: 'KPI assessment saved successfully.'
  end

  private

  def missing_quality_score_fields
    required_quality_score_fields.select { |field| params[field].blank? }
  end

  def missing_quality_for_position(position)
    required_quality_fields_for_position(position).select { |field| params[field].blank? }
  end

  def required_quality_score_fields
    return QUALITY_SCORE_FIELDS if @selected_staff.blank?

    position_key = @selected_staff.position.to_s.strip.downcase
    QUALITY_ALLOWED_FIELDS_BY_POSITION.fetch(position_key, QUALITY_SCORE_FIELDS)
  end

  def required_quality_fields_for_position(position)
    position_key = position.to_s.strip.downcase
    QUALITY_ALLOWED_FIELDS_BY_POSITION.fetch(position_key, QUALITY_SCORE_FIELDS)
  end

  def missing_quantity_score_fields
    QUANTITY_SCORE_FIELDS.select { |field| params[field].blank? }
  end

  def quality_input_values_from_params
    QUALITY_SCORE_FIELDS.index_with { |field| params[field].presence }
  end

  def previous_step_params
    {
      staff_profile_id: @selected_staff_id,
      reviewed_by: @reviewed_by || @selected_staff&.supervisor_name
    }.merge(quality_input_values_from_params.compact)
  end

  def find_selected_staff(staff_profile_id)
    return nil if staff_profile_id.blank?

    available_staff_profiles.find_by(staff_profile_id: staff_profile_id)
  end

  def available_staff_profiles
    return StaffProfile.all if current_user.superadmin?
    return StaffProfile.all if current_user.role&.name == 'supervisor'

    supervisor_name = current_user.name.to_s.strip.downcase
    staff_names = SUPERVISOR_STAFF_MAP.fetch(supervisor_name, [])
    scoped_profiles = StaffProfile.where('LOWER(supervisor_name) = ?', supervisor_name)

    return scoped_profiles if staff_names.blank?

    normalized_allowed = staff_names.map { |name| normalize_name_key(name) }
    allowed_ids = scoped_profiles
                  .select { |profile| normalized_allowed.include?(normalize_name_key(profile.fullname)) }
                  .map(&:staff_profile_id)

    scoped_profiles.where(staff_profile_id: allowed_ids)
  end

  def normalize_name_key(value)
    value.to_s.downcase.gsub(/[^a-z0-9]/, '')
  end

  def quality_sections
    QUALITY_SECTIONS
  end

  def quantity_components
    QUANTITY_COMPONENTS
  end

  def create_assessment_records!(staff_profile)
    assessment = KpiAssessment.create!(
      staff_profile_id: staff_profile.staff_profile_id,
      fullname: staff_profile.fullname,
      position: staff_profile.position,
      grade: 'N/A',
      employment_level: staff_profile.division.presence || 'N/A',
      reviewer_email: current_user.email
    )

    quarter = assessment.quarters.create!(quarter_name: current_quarter_name)
    create_quality_records!(quarter, staff_profile.position)
    create_quantity_records!(quarter)
  end

  def update_quality_records!(quality_kpi, position)
    scoring = scoring_rules_for(position)

    quality_attrs = quality_component_attributes
    update_quality_component_records!(quality_kpi, quality_attrs)

    quality_kpi.update!(overall_total: compute_quality_overall_total(scoring))
  end

  def create_quality_records!(quarter, position)
    scoring = scoring_rules_for(position)

    quality_attrs = quality_component_attributes
    components = create_quality_component_records!(quality_attrs)

    QualityBasedKpi.create!(
      quarter: quarter,
      overall_total: compute_quality_overall_total(scoring),
      research_work: components[:research_work],
      financial_management: components[:financial_management],
      soft_skill: components[:soft_skill],
      hard_skill: components[:hard_skill],
      other_involvement: components[:other_involvement]
    )
  end

  def quality_component_attributes
    {
      research_work: attributes_for(RESEARCH_FIELDS),
      financial_management: attributes_for(FINANCIAL_FIELDS),
      soft_skill: attributes_for(SOFT_FIELDS),
      hard_skill: attributes_for(HARD_FIELDS),
      other_involvement: attributes_for(OTHER_FIELDS)
    }
  end

  def update_quality_component_records!(quality_kpi, quality_attrs)
    quality_kpi.research_work.update!(with_total_score(quality_attrs[:research_work]))
    quality_kpi.financial_management.update!(with_total_score(quality_attrs[:financial_management]))
    quality_kpi.soft_skill.update!(with_total_score(quality_attrs[:soft_skill]))
    quality_kpi.hard_skill.update!(with_total_score(quality_attrs[:hard_skill]))
    quality_kpi.other_involvement.update!(with_total_score(quality_attrs[:other_involvement]))
  end

  def create_quality_component_records!(quality_attrs)
    {
      research_work: ResearchWorkRelated.create!(with_total_score(quality_attrs[:research_work])),
      financial_management: FinancialManagement.create!(with_total_score(quality_attrs[:financial_management])),
      soft_skill: SoftSkill.create!(with_total_score(quality_attrs[:soft_skill])),
      hard_skill: HardSkill.create!(with_total_score(quality_attrs[:hard_skill])),
      other_involvement: OtherInvolvement.create!(with_total_score(quality_attrs[:other_involvement]))
    }
  end

  def with_total_score(attributes)
    attributes.merge(total_score: attributes.values.sum)
  end

  def create_quantity_records!(quarter)
    output_attrs = attributes_for(QUANTITY_SCORE_FIELDS)
    output_total = output_attrs.values.sum
    weighted_total = compute_quantity_overall_total(output_attrs)
    output_and_impact = OutputAndImpactBased.create!(output_attrs.merge(total_score: output_total))

    QuantityBasedKpi.create!(
      quarter: quarter,
      output_and_impact_based: output_and_impact,
      overall_total: weighted_total
    )
  end

  def update_quantity_records!(quantity_kpi)
    output_attrs = attributes_for(QUANTITY_SCORE_FIELDS)
    output_total = output_attrs.values.sum
    weighted_total = compute_quantity_overall_total(output_attrs)

    quantity_kpi.output_and_impact_based.update!(output_attrs.merge(total_score: output_total))
    quantity_kpi.update!(overall_total: weighted_total)
  end

  def compute_quantity_overall_total(values)
    quantity_components.sum do |component|
      max_input = component[:max_input_percent].to_d
      next 0.to_d if max_input.zero?

      actual_input = values[component[:field]].to_d
      weight = component[:weight_percent].to_d
      (actual_input / max_input) * weight
    end.round(2)
  end

  def compute_quality_overall_total(scoring)
    SECTION_FIELDS.sum do |section_code, fields|
      full_sum = fields.sum { |field| scoring[:full_scores][field] }
      next 0.to_d if full_sum.zero?

      achieved_sum = fields.sum { |field| to_decimal(params[field]) }
      raw_score = (achieved_sum / full_sum.to_d) * 100
      raw_score * (scoring[:section_weights][section_code].to_d / 100)
    end.round(2)
  end

  def attributes_for(fields)
    fields.index_with { |field| to_decimal(params[field]) }
  end

  def to_decimal(value)
    BigDecimal(value.to_s.presence || '0')
  end

  def current_quarter_name
    case Time.zone.today.month
    when 1..3 then 'Quarter 1'
    when 4..6 then 'Quarter 2'
    when 7..9 then 'Quarter 3'
    else 'Quarter 4'
    end
  end

  # rubocop:disable Metrics/MethodLength
  def scoring_rules_for(position)
    position_key = position.to_s.strip.downcase
    full_scores = DEFAULT_FULL_SCORES.dup
    section_weights = DEFAULT_SECTION_WEIGHTS.dup

    case position_key
    when 'research assistant'
      full_scores.merge!(
        'data_collection' => 50,
        'data_entry_and_cleaning' => 50,
        'communication_skill' => 30,
        'collaboration_teamwork' => 30,
        'attention_details' => 40
      )
      (QUALITY_SCORE_FIELDS - QUALITY_ALLOWED_FIELDS_BY_POSITION['research assistant']).each do |field|
        full_scores[field] = 0
      end
      section_weights.merge!('A' => 80, 'B' => 0, 'C' => 0, 'D' => 10, 'E' => 10)
    when 'research officer'
      %w[writing_skill presentation_skill computer_skill management_skill statistical_knowledge].each do |field|
        full_scores[field] = 20
      end
      section_weights['C'] = 10
    when 'research associate'
      full_scores.merge!(
        'proposal_preparation' => 15,
        'proposal_presentation' => 15,
        'data_collection' => 5,
        'data_entry_and_cleaning' => 0,
        'report_writing' => 25,
        'analysis_of_data' => 10,
        'presentation_of_findings' => 30,
        'writing_skill' => 20,
        'presentation_skill' => 20,
        'computer_skill' => 20,
        'management_skill' => 20,
        'statistical_knowledge' => 20
      )
      section_weights.merge!('A' => 60, 'C' => 20)
    when 'senior research associate'
      full_scores.merge!(
        'proposal_preparation' => 5,
        'proposal_presentation' => 5,
        'data_collection' => 0,
        'data_entry_and_cleaning' => 0,
        'report_writing' => 20,
        'analysis_of_data' => 10,
        'presentation_of_findings' => 60,
        'writing_skill' => 20,
        'presentation_skill' => 20,
        'computer_skill' => 20,
        'management_skill' => 20,
        'statistical_knowledge' => 20,
        'leadership' => 30,
        'attention_details' => 10
      )
      section_weights.merge!('A' => 50, 'B' => 5, 'C' => 25, 'D' => 10, 'E' => 10)
    end

    { full_scores: full_scores, section_weights: section_weights }
  end
  # rubocop:enable Metrics/MethodLength

  def set_assessment
    @assessment = scoped_kpi_history.find(params[:id])
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def build_assessment_view_data
    @quarter = @assessment.quarters.order(created_at: :desc).first
    @quality_kpi = @quarter&.quality_based_kpi
    @quantity_kpi = @quarter&.quantity_based_kpi

    scoring = scoring_rules_for(@assessment.position)
    @quality_view_sections = build_quality_sections_for_display(scoring)
    @quantity_view_rows = build_quantity_rows_for_display
    @quality_overall_total =
      @quality_kpi&.overall_total&.to_d&.round(2) ||
      @quality_view_sections.sum { |section| section[:weighted_score].to_d }.round(2)
    @quantity_overall_total =
      @quantity_kpi&.overall_total&.to_d&.round(2) ||
      @quantity_view_rows.sum { |row| row[:weighted_score].to_d }.round(2)
    @reviewed_by = reviewed_by_label(@assessment)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def reviewed_by_label(assessment)
    reviewer_email = assessment.reviewer_email.to_s
    User.find_by(email: reviewer_email)&.name.presence || reviewer_email
  end

  # rubocop:disable Metrics/AbcSize
  def ensure_assessment_records_for_update!
    @quarter = @assessment.quarters.order(created_at: :desc).first
    @quarter ||= @assessment.quarters.create!(quarter_name: current_quarter_name)

    @quality_kpi = @quarter.quality_based_kpi
    if @quality_kpi.nil?
      research = ResearchWorkRelated.create!(zero_attributes_for(SECTION_FIELDS['A']).merge(total_score: 0))
      financial = FinancialManagement.create!(zero_attributes_for(SECTION_FIELDS['B']).merge(total_score: 0))
      soft = SoftSkill.create!(zero_attributes_for(SECTION_FIELDS['C']).merge(total_score: 0))
      hard = HardSkill.create!(zero_attributes_for(SECTION_FIELDS['D']).merge(total_score: 0))
      other = OtherInvolvement.create!(zero_attributes_for(SECTION_FIELDS['E']).merge(total_score: 0))

      @quality_kpi = QualityBasedKpi.create!(
        quarter: @quarter,
        overall_total: 0,
        research_work: research,
        financial_management: financial,
        soft_skill: soft,
        hard_skill: hard,
        other_involvement: other
      )
    end

    @quantity_kpi = @quarter.quantity_based_kpi
    return unless @quantity_kpi.nil?

    output = OutputAndImpactBased.create!(zero_attributes_for(QUANTITY_SCORE_FIELDS).merge(total_score: 0))
    @quantity_kpi = QuantityBasedKpi.create!(
      quarter: @quarter,
      output_and_impact_based: output,
      overall_total: 0
    )
  end
  # rubocop:enable Metrics/AbcSize

  def zero_attributes_for(fields)
    fields.index_with { 0.to_d }
  end

  def build_quality_sections_for_display(scoring)
    quality_values = quality_value_map

    quality_sections.map do |section|
      section_code = section[:title].split('.').first
      rows = section[:rows].map do |field, label, _default_full|
        full_score = scoring[:full_scores][field]
        actual = quality_values[field]
        {
          field: field,
          label: label,
          full_score: full_score,
          actual_score: actual,
          locked: full_score.to_d.zero?
        }
      end

      section_total_full = rows.sum { |row| row[:full_score].to_d }
      section_total_actual = rows.sum { |row| row[:actual_score].to_d }
      section_raw = section_total_full.zero? ? 0.to_d : (section_total_actual / section_total_full) * 100
      section_weight = scoring[:section_weights][section_code].to_d
      weighted_score = section_raw * (section_weight / 100)

      {
        title: section[:title],
        code: section_code,
        rows: rows,
        section_weight: section_weight,
        weighted_score: weighted_score.round(2)
      }
    end
  end

  def build_quantity_rows_for_display
    output = @quantity_kpi&.output_and_impact_based

    quantity_components.map do |component|
      actual_score = output&.public_send(component[:field]).to_d
      max_input_score = component[:max_input_percent].to_d
      weighted_score =
        if max_input_score.zero?
          0.to_d
        else
          (actual_score / max_input_score) * component[:weight_percent].to_d
        end

      {
        field: component[:field],
        label: component[:label],
        weight_percent: component[:weight_percent].to_d,
        max_input_percent: max_input_score,
        actual_score: actual_score,
        weighted_score: weighted_score.round(2)
      }
    end
  end

  def quantity_scores_out_of_range_fields
    quantity_components.filter_map do |component|
      raw_value = params[component[:field]]
      next if raw_value.blank?

      score = to_decimal(raw_value)
      max_input = component[:max_input_percent].to_d
      component[:label] if score.negative? || score > max_input
    end
  end

  def quantity_out_of_range_message
    labels = quantity_scores_out_of_range_fields.join(', ')
    "Quantity-based scores must be between 0 and the configured maximum score for: #{labels}."
  end

  # rubocop:disable Metrics/AbcSize
  def quality_value_map
    return {} unless @quality_kpi

    {
      'proposal_preparation' => @quality_kpi.research_work.proposal_preparation,
      'proposal_presentation' => @quality_kpi.research_work.proposal_presentation,
      'data_collection' => @quality_kpi.research_work.data_collection,
      'data_entry_and_cleaning' => @quality_kpi.research_work.data_entry_and_cleaning,
      'report_writing' => @quality_kpi.research_work.report_writing,
      'analysis_of_data' => @quality_kpi.research_work.analysis_of_data,
      'presentation_of_findings' => @quality_kpi.research_work.presentation_of_findings,
      'budgeting' => @quality_kpi.financial_management.budgeting,
      'record_keeping' => @quality_kpi.financial_management.record_keeping,
      'cashflow_management' => @quality_kpi.financial_management.cashflow_management,
      'compliance' => @quality_kpi.financial_management.compliance,
      'writing_skill' => @quality_kpi.soft_skill.writing_skill,
      'presentation_skill' => @quality_kpi.soft_skill.presentation_skill,
      'computer_skill' => @quality_kpi.soft_skill.computer_skill,
      'management_skill' => @quality_kpi.soft_skill.management_skill,
      'statistical_knowledge' => @quality_kpi.soft_skill.statistical_knowledge,
      'communication_skill' => @quality_kpi.hard_skill.communication_skill,
      'collaboration_teamwork' => @quality_kpi.hard_skill.collaboration_teamwork,
      'problem_solving' => @quality_kpi.hard_skill.problem_solving,
      'leadership' => @quality_kpi.hard_skill.leadership,
      'attention_details' => @quality_kpi.hard_skill.attention_details,
      'ideas_platform' => @quality_kpi.other_involvement.ideas_platform,
      'any_social_media_platform' => @quality_kpi.other_involvement.any_social_media_platform,
      'ids_watch_column' => @quality_kpi.other_involvement.ids_watch_column,
      'others' => @quality_kpi.other_involvement.others
    }
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def destroy_assessment_tree!(assessment)
    assessment.quarters.find_each do |quarter|
      quality = quarter.quality_based_kpi
      if quality
        research_work = quality.research_work
        financial_management = quality.financial_management
        soft_skill = quality.soft_skill
        hard_skill = quality.hard_skill
        other_involvement = quality.other_involvement

        quality.destroy!

        research_work&.destroy!
        financial_management&.destroy!
        soft_skill&.destroy!
        hard_skill&.destroy!
        other_involvement&.destroy!
      end

      quantity = quarter.quantity_based_kpi
      if quantity
        output_and_impact_based = quantity.output_and_impact_based

        quantity.destroy!
        output_and_impact_based&.destroy!
      end

      quarter.destroy!
    end

    assessment.destroy!
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def scoped_kpi_history
    return KpiAssessment.all if current_user.superadmin?

    KpiAssessment.where(reviewer_email: current_user.email)
  end
end
# rubocop:enable Metrics/ClassLength
