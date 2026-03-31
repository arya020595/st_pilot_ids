# frozen_string_literal: true

# Domain configuration for KPI scoring: field definitions, section structure,
# default scores, weights, and position-based rules.
module KpiScoring
  include ViewConfig
  include Defaults

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

  RESEARCH_FIELDS   = SECTION_FIELDS['A']
  FINANCIAL_FIELDS  = SECTION_FIELDS['B']
  SOFT_FIELDS       = SECTION_FIELDS['C']
  HARD_FIELDS       = SECTION_FIELDS['D']
  OTHER_FIELDS      = SECTION_FIELDS['E']

  def self.current_quarter_name
    case Time.zone.today.month
    when 1..3 then 'Quarter 1'
    when 4..6 then 'Quarter 2'
    when 7..9 then 'Quarter 3'
    else 'Quarter 4'
    end
  end

  def self.required_quality_fields(position)
    position_key = position.to_s.strip.downcase
    QUALITY_ALLOWED_FIELDS_BY_POSITION.fetch(position_key, QUALITY_SCORE_FIELDS)
  end
end
