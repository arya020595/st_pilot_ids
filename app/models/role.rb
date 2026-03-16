# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: true

  # Ransack configuration
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[permissions users]
  end
end
