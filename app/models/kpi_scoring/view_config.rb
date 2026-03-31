# frozen_string_literal: true

module KpiScoring
  # View-layer constants: section layouts for quality and quantity display.
  module ViewConfig
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
  end
end
