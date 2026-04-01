# frozen_string_literal: true

module KpiAssessments
  # Prepares assessment data for show/edit views.
  class ShowPresenter
    include KpiScoring

    attr_reader :assessment

    def initialize(assessment)
      @assessment = assessment
      @calculator = ScoreCalculator.new(assessment.position)
      @quarter = assessment.quarters.order(created_at: :desc).first
      @quality_kpi = @quarter&.quality_based_kpi
      @quantity_kpi = @quarter&.quantity_based_kpi
    end

    def quality_view_sections
      @quality_view_sections ||= build_quality_sections
    end

    def quantity_view_rows
      @quantity_view_rows ||= build_quantity_rows
    end

    def quality_overall_total
      @quality_overall_total ||=
        @quality_kpi&.overall_total&.to_d&.round(2) ||
        quality_view_sections.sum { |s| s[:weighted_score].to_d }.round(2)
    end

    def quantity_overall_total
      @quantity_overall_total ||=
        @quantity_kpi&.overall_total&.to_d&.round(2) ||
        quantity_view_rows.sum { |r| r[:actual_score].to_d }.round(2)
    end

    def reviewed_by
      @reviewed_by ||= begin
        email = assessment.reviewer_email.to_s
        User.find_by(email: email)&.name.presence || email
      end
    end

    COMPONENT_ASSOCIATIONS = {
      research_work: RESEARCH_FIELDS,
      financial_management: FINANCIAL_FIELDS,
      soft_skill: SOFT_FIELDS,
      hard_skill: HARD_FIELDS,
      other_involvement: OTHER_FIELDS
    }.freeze

    private

    def build_quality_sections
      values = quality_value_map
      scoring = @calculator.scoring_rules

      QUALITY_SECTIONS.map do |section|
        section_code = section[:title].split('.').first
        rows = section[:rows].map do |field, label, _|
          full_score = scoring[:full_scores][field]
          {
            field: field,
            label: label,
            full_score: full_score,
            actual_score: values[field],
            locked: full_score.to_d.zero?
          }
        end

        total_full = rows.sum { |r| r[:full_score].to_d }
        total_actual = rows.sum { |r| r[:actual_score].to_d }
        raw = total_full.zero? ? 0.to_d : (total_actual / total_full) * 100
        weight = scoring[:section_weights][section_code].to_d
        weighted = raw * (weight / 100)

        {
          title: section[:title],
          code: section_code,
          rows: rows,
          section_weight: weight,
          weighted_score: weighted.round(2)
        }
      end
    end

    def build_quantity_rows
      output = @quantity_kpi&.output_and_impact_based

      QUANTITY_COMPONENTS.map do |field, label, full_score|
        {
          field: field,
          label: label,
          full_score: full_score.delete('%').to_d,
          actual_score: output&.public_send(field).to_d
        }
      end
    end

    def quality_value_map
      return {} unless @quality_kpi

      COMPONENT_ASSOCIATIONS.each_with_object({}) do |(assoc, fields), map|
        component = @quality_kpi.public_send(assoc)
        fields.each { |field| map[field] = component.public_send(field) }
      end
    end
  end
end
