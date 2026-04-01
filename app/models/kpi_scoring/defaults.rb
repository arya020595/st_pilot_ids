# frozen_string_literal: true

module KpiScoring
  # Default full-score values and section weights used as the baseline
  # before position-specific overrides are applied.
  module Defaults
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
  end
end
