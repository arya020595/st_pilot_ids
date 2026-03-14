# frozen_string_literal: true

class CreateStaffProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_profiles, id: :bigint, primary_key: :staff_profile_id do |t|
      t.string :email, null: false
      t.string :fullname, null: false
      t.string :grade, null: false
      t.string :position, null: false
      t.string :division, null: false
      t.string :supervisor_name, null: false
      t.integer :no_of_subordinate, null: false, default: 0
      t.string :employment_level, null: false

      t.timestamps
    end

    add_index :staff_profiles, :email, unique: true
    add_index :staff_profiles, :grade
    add_index :staff_profiles, :position
    add_index :staff_profiles, :division
  end
end
