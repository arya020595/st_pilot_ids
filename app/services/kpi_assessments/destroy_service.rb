# frozen_string_literal: true

module KpiAssessments
  # Cascade-deletes an assessment and all its child records.
  class DestroyService
    def initialize(assessment)
      @assessment = assessment
    end

    def call
      @assessment.quarters.find_each do |quarter|
        destroy_quality!(quarter)
        destroy_quantity!(quarter)
        quarter.destroy!
      end

      @assessment.destroy!
    end

    private

    def destroy_quality!(quarter)
      quality = quarter.quality_based_kpi
      return unless quality

      components = [
        quality.research_work,
        quality.financial_management,
        quality.soft_skill,
        quality.hard_skill,
        quality.other_involvement
      ]

      quality.destroy!
      components.each { |c| c&.destroy! }
    end

    def destroy_quantity!(quarter)
      quantity = quarter.quantity_based_kpi
      return unless quantity

      output = quantity.output_and_impact_based
      quantity.destroy!
      output&.destroy!
    end
  end
end
