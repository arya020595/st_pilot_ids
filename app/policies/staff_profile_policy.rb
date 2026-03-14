# frozen_string_literal: true

# Authorization policy for staff profile access.
class StaffProfilePolicy < ApplicationPolicy
  def show?
    index?
  end

  private

  def permission_resource
    'staff_profiles'
  end

  # Policy scope for staff profile queries.
  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'staff_profiles'
    end
  end
end
