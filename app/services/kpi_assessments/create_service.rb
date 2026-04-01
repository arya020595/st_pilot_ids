# frozen_string_literal: true

module KpiAssessments
  # Creates a full KPI assessment tree in a single transaction:
  # KpiAssessment → Quarter → QualityBasedKpi (+ components) → QuantityBasedKpi (+ output)
  class CreateService
    def initialize(staff_profile:, reviewer_email:, score_form:)
      @staff_profile = staff_profile
      @reviewer_email = reviewer_email
      @score_form = score_form
      @calculator = ScoreCalculator.new(staff_profile.position)
    end

    def call
      ActiveRecord::Base.transaction do
        assessment = create_assessment!
        quarter = assessment.quarters.create!(quarter_name: KpiScoring.current_quarter_name)
        create_quality_records!(quarter)
        create_quantity_records!(quarter)
        assessment
      end
    end

    private

    def create_assessment!
      KpiAssessment.create!(
        staff_profile_id: @staff_profile.staff_profile_id,
        fullname: @staff_profile.fullname,
        position: @staff_profile.position,
        grade: 'N/A',
        employment_level: @staff_profile.division.presence || 'N/A',
        reviewer_email: @reviewer_email
      )
    end

    def create_quality_records!(quarter)
      attrs = @score_form.quality_component_attributes
      components = create_components!(attrs)

      QualityBasedKpi.create!(
        quarter: quarter,
        overall_total: @calculator.compute_quality_overall_total(@score_form),
        **components
      )
    end

    def create_components!(attrs)
      {
        research_work: ResearchWorkRelated.create!(@calculator.with_total_score(attrs[:research_work])),
        financial_management: FinancialManagement.create!(@calculator.with_total_score(attrs[:financial_management])),
        soft_skill: SoftSkill.create!(@calculator.with_total_score(attrs[:soft_skill])),
        hard_skill: HardSkill.create!(@calculator.with_total_score(attrs[:hard_skill])),
        other_involvement: OtherInvolvement.create!(@calculator.with_total_score(attrs[:other_involvement]))
      }
    end

    def create_quantity_records!(quarter)
      attrs = @score_form.quantity_attributes
      total = attrs.values.sum
      output = OutputAndImpactBased.create!(attrs.merge(total_score: total))

      QuantityBasedKpi.create!(
        quarter: quarter,
        output_and_impact_based: output,
        overall_total: total
      )
    end
  end
end
