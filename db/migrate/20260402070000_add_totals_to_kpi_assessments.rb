# frozen_string_literal: true

class AddTotalsToKpiAssessments < ActiveRecord::Migration[8.1]
  def change
    add_column :kpi_assessments, :quality_based_total, :decimal, precision: 5, scale: 2
    add_column :kpi_assessments, :quantity_based_total, :decimal, precision: 5, scale: 2
  end
end
