# frozen_string_literal: true

# Authorization policy for BI Dashboard access.
class BiDashboardPolicy < ApplicationPolicy
  # Permission codes:
  # - bi_dashboards.index

  private

  def permission_resource
    'bi_dashboards'
  end

  # Scope for BI Dashboard queries.
  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'bi_dashboards'
    end
  end
end
