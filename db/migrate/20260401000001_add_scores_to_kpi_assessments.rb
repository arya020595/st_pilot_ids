# frozen_string_literal: true

class AddScoresToKpiAssessments < ActiveRecord::Migration[8.0]
  def change
    add_column :kpi_assessments, :quality_based_total, :decimal, precision: 5, scale: 2
    add_column :kpi_assessments, :quantity_based_total, :decimal, precision: 5, scale: 2
  end
end
