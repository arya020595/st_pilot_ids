# frozen_string_literal: true

class IdsStaff < ApplicationRecord
  has_one :user, foreign_key: :ids_staff_id, inverse_of: :ids_staff, dependent: :nullify

  validates :code, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :fullname, presence: true
  validates :grade, presence: true
  validates :division, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id code email fullname grade division created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
