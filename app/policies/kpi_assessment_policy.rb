# frozen_string_literal: true

# Authorization policy for KPI Assessment access.
class KpiAssessmentPolicy < ApplicationPolicy
  # Permission codes:
  # - kpi_assessments.index

  private

  def permission_resource
    'kpi_assessments'
  end

  # Scope for KPI Assessment queries — non-superadmins see only own reviews.
  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'kpi_assessments'
    end

    def apply_role_based_scope
      scope.where(reviewer_email: user.email)
    end
  end

  # Scope for StaffProfile records this user can assess via KPI.
  # Superadmins see all (handled by parent). Supervisors see all.
  # Others see only staff whose supervisor_name matches their name.
  class AssessableStaffScope < ApplicationPolicy::Scope
    private

    def permission_resource
      'kpi_assessments'
    end

    def apply_role_based_scope
      return scope.all if user.role&.name == 'supervisor'

      scope.where('LOWER(supervisor_name) = ?', user.name.to_s.strip.downcase)
    end
  end
end
