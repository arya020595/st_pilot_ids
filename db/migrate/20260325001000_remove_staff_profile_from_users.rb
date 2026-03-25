# frozen_string_literal: true

class RemoveStaffProfileFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :staff_profile_id, if_exists: true
    remove_foreign_key :users, :staff_profiles, if_exists: true
    safety_assured { remove_column :users, :staff_profile_id, :bigint, if_exists: true }
  end
end
