# frozen_string_literal: true

class AddUniqueIndexToUsersStaffProfileId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :users, :staff_profile_id, unique: true, algorithm: :concurrently, if_not_exists: true
  end
end
