# frozen_string_literal: true

module KpiAssessments
  # Position-based scoring rules and weighted total computation.
  # Follows Open/Closed Principle: add new positions without modifying existing logic.
  class ScoreCalculator
    include KpiScoring

    attr_reader :scoring_rules

    def initialize(position)
      @position = position
      @scoring_rules = build_scoring_rules
    end

    def compute_quality_overall_total(score_form)
      scores = @scoring_rules[:full_scores]
      weights = @scoring_rules[:section_weights]

      SECTION_FIELDS.sum do |section_code, fields|
        full_sum = fields.sum { |field| scores[field] }
        next 0.to_d if full_sum.zero?

        achieved_sum = fields.sum { |field| score_form.score_value(field) }
        raw_score = (achieved_sum / full_sum.to_d) * 100
        raw_score * (weights[section_code].to_d / 100)
      end.round(2)
    end

    def with_total_score(attributes)
      attributes.merge(total_score: attributes.values.sum)
    end

    def zero_attributes_for(fields)
      fields.index_with { 0.to_d }
    end

    private

    def build_scoring_rules
      scores = DEFAULT_FULL_SCORES.dup
      weights = DEFAULT_SECTION_WEIGHTS.dup
      apply_position_overrides!(scores, weights)
      { full_scores: scores, section_weights: weights }
    end

    def apply_position_overrides!(scores, weights)
      case @position.to_s.strip.downcase
      when 'research assistant'
        apply_research_assistant!(scores, weights)
      when 'research officer'
        apply_research_officer!(scores, weights)
      when 'research associate'
        apply_research_associate!(scores, weights)
      when 'senior research associate'
        apply_senior_research_associate!(scores, weights)
      end
    end

    def apply_research_assistant!(scores, weights)
      scores.merge!(
        'data_collection' => 50,
        'data_entry_and_cleaning' => 50,
        'communication_skill' => 30,
        'collaboration_teamwork' => 30,
        'attention_details' => 40
      )
      (QUALITY_SCORE_FIELDS - QUALITY_ALLOWED_FIELDS_BY_POSITION['research assistant']).each do |field|
        scores[field] = 0
      end
      weights.merge!('A' => 80, 'B' => 0, 'C' => 0, 'D' => 10, 'E' => 10)
    end

    def apply_research_officer!(scores, weights)
      %w[writing_skill presentation_skill computer_skill management_skill statistical_knowledge].each do |field|
        scores[field] = 20
      end
      weights['C'] = 10
    end

    def apply_research_associate!(scores, weights)
      scores.merge!(
        'proposal_preparation' => 15,
        'proposal_presentation' => 15,
        'data_collection' => 5,
        'data_entry_and_cleaning' => 0,
        'report_writing' => 25,
        'analysis_of_data' => 10,
        'presentation_of_findings' => 30,
        'writing_skill' => 20,
        'presentation_skill' => 20,
        'computer_skill' => 20,
        'management_skill' => 20,
        'statistical_knowledge' => 20
      )
      weights.merge!('A' => 60, 'C' => 20)
    end

    def apply_senior_research_associate!(scores, weights)
      scores.merge!(
        'proposal_preparation' => 5,
        'proposal_presentation' => 5,
        'data_collection' => 0,
        'data_entry_and_cleaning' => 0,
        'report_writing' => 20,
        'analysis_of_data' => 10,
        'presentation_of_findings' => 60,
        'writing_skill' => 20,
        'presentation_skill' => 20,
        'computer_skill' => 20,
        'management_skill' => 20,
        'statistical_knowledge' => 20,
        'leadership' => 30,
        'attention_details' => 10
      )
      weights.merge!('A' => 50, 'B' => 5, 'C' => 25, 'D' => 10, 'E' => 10)
    end
  end
end
