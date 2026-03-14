# frozen_string_literal: true

class StaffProfilePolicy < ApplicationPolicy
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
