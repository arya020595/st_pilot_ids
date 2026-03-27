# frozen_string_literal: true

class ValidateUsersStaffProfileForeignKey < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :users, :staff_profiles, column: :staff_profile_id
  end
end
