# frozen_string_literal: true

class StaffProfilePolicy < ApplicationPolicy
  # Permission codes:
  # - staff_profiles.index
  # - staff_profiles.show

  def show?
    index?
  end

  private

  def permission_resource
    'staff_profiles'
  end

  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'staff_profiles'
    end
  end
end
