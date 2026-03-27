# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class CreateKpiAssessmentTables < ActiveRecord::Migration[8.1]
  def change
    create_table :kpi_assessments do |t|
      t.string :fullname, null: false
      t.string :grade, null: false
      t.string :position, null: false
      t.string :employment_level, null: false
      t.bigint :staff_profile_id, null: false

      t.timestamps
    end

    add_foreign_key(
      :kpi_assessments,
      :staff_profiles,
      column: :staff_profile_id,
      primary_key: :staff_profile_id,
      validate: false
    )
    add_index :kpi_assessments, :staff_profile_id

    create_table :quarters do |t|
      t.string :quarter_name, null: false
      t.bigint :kpi_assessment_id, null: false

      t.timestamps
    end

    add_foreign_key :quarters, :kpi_assessments, validate: false
    add_index :quarters, :kpi_assessment_id
    add_index :quarters, %i[kpi_assessment_id quarter_name], unique: true

    create_table :output_and_impact_baseds do |t|
      t.decimal :number_of_involvement, precision: 5, scale: 2
      t.decimal :output_production, precision: 5, scale: 2
      t.decimal :acceptance_of_outputs, precision: 5, scale: 2
      t.decimal :uptake_of_outputs, precision: 5, scale: 2
      t.decimal :presentation_state_level, precision: 5, scale: 2
      t.decimal :presentation_national_level, precision: 5, scale: 2
      t.decimal :total_score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :quantity_based_kpis do |t|
      t.bigint :quarter_id, null: false
      t.decimal :overall_total, precision: 5, scale: 2
      t.bigint :output_and_impact_based_id, null: false

      t.timestamps
    end

    add_foreign_key :quantity_based_kpis, :quarters, validate: false
    add_foreign_key :quantity_based_kpis, :output_and_impact_baseds, validate: false
    add_index :quantity_based_kpis, :quarter_id, unique: true
    add_index :quantity_based_kpis, :output_and_impact_based_id

    create_table :research_work_relateds do |t|
      t.decimal :proposal_preparation, precision: 5, scale: 2
      t.decimal :proposal_presentation, precision: 5, scale: 2
      t.decimal :data_collection, precision: 5, scale: 2
      t.decimal :data_entry_and_cleaning, precision: 5, scale: 2
      t.decimal :report_writing, precision: 5, scale: 2
      t.decimal :analysis_of_data, precision: 5, scale: 2
      t.decimal :presentation_of_findings, precision: 5, scale: 2
      t.decimal :total_score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :financial_managements do |t|
      t.decimal :budgeting, precision: 5, scale: 2
      t.decimal :record_keeping, precision: 5, scale: 2
      t.decimal :cashflow_management, precision: 5, scale: 2
      t.decimal :compliance, precision: 5, scale: 2
      t.decimal :total_score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :soft_skills do |t|
      t.decimal :writing_skill, precision: 5, scale: 2
      t.decimal :presentation_skill, precision: 5, scale: 2
      t.decimal :computer_skill, precision: 5, scale: 2
      t.decimal :management_skill, precision: 5, scale: 2
      t.decimal :statistical_knowledge, precision: 5, scale: 2
      t.decimal :total_score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :hard_skills do |t|
      t.decimal :communication_skill, precision: 5, scale: 2
      t.decimal :collaboration_teamwork, precision: 5, scale: 2
      t.decimal :problem_solving, precision: 5, scale: 2
      t.decimal :leadership, precision: 5, scale: 2
      t.decimal :attention_details, precision: 5, scale: 2
      t.decimal :total_score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :other_involvements do |t|
      t.decimal :ideas_platform, precision: 5, scale: 2
      t.decimal :any_social_media_platform, precision: 5, scale: 2
      t.decimal :ids_watch_column, precision: 5, scale: 2
      t.decimal :others, precision: 5, scale: 2
      t.decimal :total_score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :quality_based_kpis do |t|
      t.bigint :quarter_id, null: false
      t.decimal :overall_total, precision: 5, scale: 2
      t.bigint :research_work_id, null: false
      t.bigint :financial_management_id, null: false
      t.bigint :soft_skill_id, null: false
      t.bigint :hard_skill_id, null: false
      t.bigint :other_involvement_id, null: false

      t.timestamps
    end

    add_foreign_key :quality_based_kpis, :quarters, validate: false
    add_foreign_key :quality_based_kpis, :research_work_relateds, column: :research_work_id, validate: false
    add_foreign_key :quality_based_kpis, :financial_managements, validate: false
    add_foreign_key :quality_based_kpis, :soft_skills, validate: false
    add_foreign_key :quality_based_kpis, :hard_skills, validate: false
    add_foreign_key :quality_based_kpis, :other_involvements, validate: false
    add_index :quality_based_kpis, :quarter_id, unique: true
    add_index :quality_based_kpis, :research_work_id
    add_index :quality_based_kpis, :financial_management_id
    add_index :quality_based_kpis, :soft_skill_id
    add_index :quality_based_kpis, :hard_skill_id
    add_index :quality_based_kpis, :other_involvement_id
  end
end
# rubocop:enable Metrics/ClassLength
