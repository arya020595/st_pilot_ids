# frozen_string_literal: true

class RemoveIdsStaffAndAddStaffProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    # Remove foreign key and index from users table
    remove_foreign_key :users, :ids_staffs, if_exists: true
    remove_index :users, :ids_staff_id, if_exists: true

    # Remove ids_staff_id column from users table
    safety_assured do
      remove_column :users, :ids_staff_id, :bigint, if_exists: true
    end

    # Add staff_profile_id column to users table
    add_column :users, :staff_profile_id, :bigint, if_not_exists: true

    # Add foreign key without validating existing rows first
    add_foreign_key :users, :staff_profiles,
                    column: :staff_profile_id,
                    primary_key: :staff_profile_id,
                    on_delete: :nullify,
                    if_not_exists: true,
                    validate: false

    # Drop ids_staffs table
    safety_assured do
      drop_table :ids_staffs, if_exists: true
    end
  end
end
