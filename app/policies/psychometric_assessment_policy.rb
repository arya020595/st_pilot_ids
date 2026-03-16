# frozen_string_literal: true

# Authorization policy for Psychometric Assessment access.
class PsychometricAssessmentPolicy < ApplicationPolicy
  # Permission codes:
  # - psychometric_assessments.index

  private

  def permission_resource
    'psychometric_assessments'
  end

  # Scope for Psychometric Assessment queries.
  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'psychometric_assessments'
    end
  end
end
