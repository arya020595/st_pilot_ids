# frozen_string_literal: true

# Domain model for staff profile records.
class StaffProfile < ApplicationRecord
  self.primary_key = 'staff_profile_id'

  validates(
    :fullname,
    :position,
    :supervisor_name,
    :supervisor_email,
    presence: true
  )

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      staff_profile_id
      fullname
      position
      division
      supervisor_name
      supervisor_email
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
