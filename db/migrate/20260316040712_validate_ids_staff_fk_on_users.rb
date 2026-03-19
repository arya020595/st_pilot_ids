# frozen_string_literal: true

class ValidateIdsStaffFkOnUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :users, :ids_staff_id, unique: true, algorithm: :concurrently
    validate_foreign_key :users, :ids_staffs
  end
end
