# frozen_string_literal: true

class UpdateStaffProfilesTable < ActiveRecord::Migration[8.1]
  def change
    # Remove columns
    safety_assured do
      remove_index :staff_profiles, :email, if_exists: true
      remove_column :staff_profiles, :email, :string, if_exists: true
      remove_column :staff_profiles, :grade, :string, if_exists: true
      remove_column :staff_profiles, :no_of_subordinate, :integer, if_exists: true
      remove_column :staff_profiles, :employment_level, :string, if_exists: true
    end

    # Add supervisor_email column
    add_column :staff_profiles, :supervisor_email, :string, null: false, default: ''
  end
end
