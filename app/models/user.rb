# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  self.ignored_columns += ['ids_staff_id', 'staff_profile_id']

  belongs_to :role, optional: true

  validates :name, presence: true

  # Check if user has a specific permission code
  # Superadmin role bypasses all permission checks
  def has_permission?(code)
    return false unless role
    return true if superadmin?

    @permission_codes ||= role.permissions.pluck(:code)
    @permission_codes.include?(code)
  end

  # Check if user has any permission for a resource
  def has_resource_permission?(resource)
    return false unless role
    return true if superadmin?

    @permission_codes ||= role.permissions.pluck(:code)
    @permission_codes.any? { |code| code.start_with?("#{resource}.") }
  end

  # Check if user is superadmin (bypasses all permission checks)
  def superadmin?
    role&.name&.casecmp('superadmin')&.zero?
  end

  # Clear cached permissions (call after role change)
  def clear_permission_cache!
    @permission_codes = nil
  end

  # Ransack configuration - excluding sensitive fields
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name email is_active created_at updated_at role_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[role]
  end
end
