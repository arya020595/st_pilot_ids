# frozen_string_literal: true

# Authorization policy for Dashboard access.
class DashboardPolicy < ApplicationPolicy
  # Permission codes:
  # - dashboard.index

  private

  def permission_resource
    'dashboard'
  end

  # Scope for Dashboard queries.
  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'dashboard'
    end
  end
end
