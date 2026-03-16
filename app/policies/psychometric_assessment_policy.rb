# frozen_string_literal: true

class PsychometricAssessmentPolicy < ApplicationPolicy
  # Permission codes:
  # - psychometric_assessments.index

  private

  def permission_resource
    'psychometric_assessments'
  end

  class Scope < ApplicationPolicy::Scope
    private

    def permission_resource
      'psychometric_assessments'
    end
  end
end
