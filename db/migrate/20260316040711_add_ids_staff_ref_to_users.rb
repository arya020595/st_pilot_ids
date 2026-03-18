# frozen_string_literal: true

class AddIdsStaffRefToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ids_staff_id, :bigint, null: true

    add_foreign_key :users,
                    :ids_staffs,
                    column: :ids_staff_id,
                    on_delete: :nullify,
                    validate: false
  end
end
