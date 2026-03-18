# frozen_string_literal: true

class CreateIdsStaff < ActiveRecord::Migration[8.1]
  def change
    create_table :ids_staffs, id: :bigint do |t|
      t.string :code, null: false
      t.string :email, null: false
      t.string :fullname, null: false
      t.string :grade, null: false
      t.string :division, null: false
      t.timestamps
    end

    add_index :ids_staffs, :code, unique: true
    add_index :ids_staffs, :email, unique: true
    add_index :ids_staffs, %i[division grade]
  end
end
