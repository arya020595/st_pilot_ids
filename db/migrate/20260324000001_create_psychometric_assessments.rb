# frozen_string_literal: true

class CreatePsychometricAssessments < ActiveRecord::Migration[8.1]
  def change
    create_table :psychometric_assessments, id: :bigint, primary_key: :psychometric_assessment_id do |t|
      t.bigint :staff_profile_id, null: false
      t.string :name, null: false
      t.string :grade, null: false
      t.string :position, null: false
      t.string :link_google_drive

      t.timestamps
    end

    add_foreign_key :psychometric_assessments,
                    :staff_profiles,
                    column: :staff_profile_id,
                    primary_key: :staff_profile_id,
                    validate: false
    add_index :psychometric_assessments, :staff_profile_id, unique: true
  end
end
