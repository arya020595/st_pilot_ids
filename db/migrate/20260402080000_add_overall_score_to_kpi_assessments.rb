# frozen_string_literal: true

class AddOverallScoreToKpiAssessments < ActiveRecord::Migration[8.1]
  def change
    add_column :kpi_assessments, :overall_score, :decimal, precision: 5, scale: 2
  end
end