# frozen_string_literal: true

class BiDashboardPolicy < ApplicationPolicy
  # Permission codes:
  # - bi_dashboards.index

  private

  def permission_resource
    'bi_dashboards'
  end

  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'bi_dashboards'
    end
  end
end
