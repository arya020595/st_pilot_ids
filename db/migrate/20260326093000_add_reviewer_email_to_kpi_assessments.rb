# frozen_string_literal: true

class AddReviewerEmailToKpiAssessments < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :kpi_assessments, :reviewer_email, :string
    add_index :kpi_assessments, :reviewer_email, algorithm: :concurrently
  end
end
