# frozen_string_literal: true

# Domain model for staff profile records.
class StaffProfile < ApplicationRecord
  self.primary_key = 'staff_profile_id'

  has_one :user, foreign_key: :staff_profile_id, primary_key: :staff_profile_id, inverse_of: :staff_profile, dependent: :nullify

  validates(
    :email,
    :fullname,
    :grade,
    :position,
    :division,
    :supervisor_name,
    :employment_level,
    presence: true
  )
  validates :email, uniqueness: true
  validates :no_of_subordinate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      staff_profile_id
      email
      fullname
      grade
      position
      division
      supervisor_name
      no_of_subordinate
      employment_level
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
