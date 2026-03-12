# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration[7.1]
  def change
    create_table :permissions do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :permissions, :code, unique: true
  end
end
