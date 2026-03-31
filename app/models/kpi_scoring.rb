# frozen_string_literal: true

# Domain configuration for KPI scoring: field definitions, section structure,
# default scores, weights, and position-based rules.
module KpiScoring
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

  QUANTITY_COMPONENTS = [
    ['number_of_involvement', 'Number of Involvement', '20%'],
    ['output_production', 'Output Production', '30%'],
    ['acceptance_of_outputs', 'Acceptance of Outputs', '15%'],
    ['uptake_of_outputs', 'Uptake of Outputs', '10%'],
    ['presentation_state_level', 'Presentation (State - Level)', '10%'],
    ['presentation_national_level', 'Presentation (National - Level)', '15%']
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
