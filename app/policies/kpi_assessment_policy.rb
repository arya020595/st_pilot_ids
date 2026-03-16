# frozen_string_literal: true

class KpiAssessmentPolicy < ApplicationPolicy
  # Permission codes:
  # - kpi_assessments.index

  private

  def permission_resource
    'kpi_assessments'
  end

  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'kpi_assessments'
    end
  end
end
