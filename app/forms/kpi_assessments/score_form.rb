# frozen_string_literal: true

module KpiAssessments
  # Parses flat score parameters and validates completeness.
  class ScoreForm
    include KpiScoring

    attr_reader :staff_profile_id, :reviewed_by

    def initialize(params)
      @params = params
      @staff_profile_id = params[:staff_profile_id].presence
      @reviewed_by = params[:reviewed_by].presence
    end

    def quality_input_values
      QUALITY_SCORE_FIELDS.index_with { |field| @params[field].presence }
    end

    def quality_valid?(position)
      missing_quality_fields(position).empty?
    end

    def quantity_valid?
      missing_quantity_fields.empty?
    end

    def missing_quality_fields(position)
      KpiScoring.required_quality_fields(position).select { |f| @params[f].blank? }
    end

    def missing_quantity_fields
      QUANTITY_SCORE_FIELDS.select { |f| @params[f].blank? }
    end

    def quality_component_attributes
      {
        research_work: decimal_attributes_for(RESEARCH_FIELDS),
        financial_management: decimal_attributes_for(FINANCIAL_FIELDS),
        soft_skill: decimal_attributes_for(SOFT_FIELDS),
        hard_skill: decimal_attributes_for(HARD_FIELDS),
        other_involvement: decimal_attributes_for(OTHER_FIELDS)
      }
    end

    def quantity_attributes
      decimal_attributes_for(QUANTITY_SCORE_FIELDS)
    end

    def score_value(field)
      to_decimal(@params[field])
    end

    def previous_step_params(staff = nil)
      {
        staff_profile_id: @staff_profile_id,
        reviewed_by: @reviewed_by || staff&.supervisor_name
      }.merge(quality_input_values.compact)
    end

    private

    def decimal_attributes_for(fields)
      fields.index_with { |field| to_decimal(@params[field]) }
    end

    def to_decimal(value)
      BigDecimal(value.to_s.presence || '0')
    end
  end
end
