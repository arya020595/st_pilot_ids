# frozen_string_literal: true

# Authorization policy for KPI Assessment access.
class KpiAssessmentPolicy < ApplicationPolicy
  # Permission codes:
  # - kpi_assessments.index

  private

  def permission_resource
    'kpi_assessments'
  end

  # Scope for KPI Assessment queries.
  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'kpi_assessments'
    end
  end
end
