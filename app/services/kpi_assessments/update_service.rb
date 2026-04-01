# frozen_string_literal: true

module KpiAssessments
  # Updates an existing KPI assessment's quality and quantity records.
  # Ensures required child records exist before updating.
  class UpdateService
    include KpiScoring

    def initialize(assessment:, score_form:)
      @assessment = assessment
      @score_form = score_form
      @calculator = ScoreCalculator.new(assessment.position)
    end

    def call
      ActiveRecord::Base.transaction do
        ensure_records!
        update_quality!
        update_quantity!
        @assessment.touch
      end
      true
    end

    private

    def ensure_records!
      @quarter = @assessment.quarters.order(created_at: :desc).first
      @quarter ||= @assessment.quarters.create!(quarter_name: KpiScoring.current_quarter_name)

      @quality_kpi = @quarter.quality_based_kpi || create_blank_quality!
      @quantity_kpi = @quarter.quantity_based_kpi || create_blank_quantity!
    end

    def update_quality!
      attrs = @score_form.quality_component_attributes
      @quality_kpi.research_work.update!(@calculator.with_total_score(attrs[:research_work]))
      @quality_kpi.financial_management.update!(@calculator.with_total_score(attrs[:financial_management]))
      @quality_kpi.soft_skill.update!(@calculator.with_total_score(attrs[:soft_skill]))
      @quality_kpi.hard_skill.update!(@calculator.with_total_score(attrs[:hard_skill]))
      @quality_kpi.other_involvement.update!(@calculator.with_total_score(attrs[:other_involvement]))
      @quality_kpi.update!(overall_total: @calculator.compute_quality_overall_total(@score_form))
    end

    def update_quantity!
      attrs = @score_form.quantity_attributes
      total = attrs.values.sum
      @quantity_kpi.output_and_impact_based.update!(attrs.merge(total_score: total))
      @quantity_kpi.update!(overall_total: total)
    end

    def create_blank_quality!
      research = ResearchWorkRelated.create!(@calculator.zero_attributes_for(SECTION_FIELDS['A']).merge(total_score: 0))
      zero_b = @calculator.zero_attributes_for(SECTION_FIELDS['B'])
      financial = FinancialManagement.create!(zero_b.merge(total_score: 0))
      soft = SoftSkill.create!(@calculator.zero_attributes_for(SECTION_FIELDS['C']).merge(total_score: 0))
      hard = HardSkill.create!(@calculator.zero_attributes_for(SECTION_FIELDS['D']).merge(total_score: 0))
      other = OtherInvolvement.create!(@calculator.zero_attributes_for(SECTION_FIELDS['E']).merge(total_score: 0))

      QualityBasedKpi.create!(
        quarter: @quarter,
        overall_total: 0,
        research_work: research,
        financial_management: financial,
        soft_skill: soft,
        hard_skill: hard,
        other_involvement: other
      )
    end

    def create_blank_quantity!
      zero_qty = @calculator.zero_attributes_for(QUANTITY_SCORE_FIELDS)
      output = OutputAndImpactBased.create!(zero_qty.merge(total_score: 0))
      QuantityBasedKpi.create!(
        quarter: @quarter,
        output_and_impact_based: output,
        overall_total: 0
      )
    end
  end
end
