# frozen_string_literal: true

class ValidateKpiAssessmentTableForeignKeys < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :kpi_assessments,
                         :staff_profiles,
                         column: :staff_profile_id
    validate_foreign_key :quarters,
                         :kpi_assessments,
                         column: :kpi_assessment_id
    validate_foreign_key :quantity_based_kpis,
                         :quarters,
                         column: :quarter_id
    validate_foreign_key :quantity_based_kpis,
                         :output_and_impact_baseds,
                         column: :output_and_impact_based_id
    validate_foreign_key :quality_based_kpis,
                         :quarters,
                         column: :quarter_id
    validate_foreign_key :quality_based_kpis,
                         :research_work_relateds,
                         column: :research_work_id
    validate_foreign_key :quality_based_kpis,
                         :financial_managements,
                         column: :financial_management_id
    validate_foreign_key :quality_based_kpis,
                         :soft_skills,
                         column: :soft_skill_id
    validate_foreign_key :quality_based_kpis,
                         :hard_skills,
                         column: :hard_skill_id
    validate_foreign_key :quality_based_kpis,
                         :other_involvements,
                         column: :other_involvement_id
  end
end