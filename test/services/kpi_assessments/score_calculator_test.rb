# frozen_string_literal: true

require 'test_helper'

module KpiAssessments
  class ScoreCalculatorTest < ActiveSupport::TestCase
    test 'default position uses default full scores and weights' do
      calc = ScoreCalculator.new('Research Officer')
      rules = calc.scoring_rules

      assert_equal 10, rules[:full_scores]['proposal_preparation']
      assert_equal 30, rules[:full_scores]['report_writing']
      # Research officer overrides soft skill scores to 20
      assert_equal 20, rules[:full_scores]['writing_skill']
      assert_equal 10, rules[:section_weights]['C']
    end

    test 'research assistant zeroes out non-allowed fields' do
      calc = ScoreCalculator.new('Research Assistant')
      rules = calc.scoring_rules

      assert_equal 0, rules[:full_scores]['proposal_preparation']
      assert_equal 0, rules[:full_scores]['report_writing']
      assert_equal 50, rules[:full_scores]['data_collection']
      assert_equal 50, rules[:full_scores]['data_entry_and_cleaning']
      assert_equal 80, rules[:section_weights]['A']
      assert_equal 0, rules[:section_weights]['B']
      assert_equal 0, rules[:section_weights]['C']
    end

    test 'research associate adjusts scores and weights' do
      calc = ScoreCalculator.new('Research Associate')
      rules = calc.scoring_rules

      assert_equal 15, rules[:full_scores]['proposal_preparation']
      assert_equal 0, rules[:full_scores]['data_entry_and_cleaning']
      assert_equal 60, rules[:section_weights]['A']
      assert_equal 20, rules[:section_weights]['C']
    end

    test 'senior research associate adjusts scores and weights' do
      calc = ScoreCalculator.new('Senior Research Associate')
      rules = calc.scoring_rules

      assert_equal 5, rules[:full_scores]['proposal_preparation']
      assert_equal 0, rules[:full_scores]['data_collection']
      assert_equal 60, rules[:full_scores]['presentation_of_findings']
      assert_equal 30, rules[:full_scores]['leadership']
      assert_equal 50, rules[:section_weights]['A']
      assert_equal 25, rules[:section_weights]['C']
    end

    test 'unknown position uses defaults' do
      calc = ScoreCalculator.new('Unknown Position')
      rules = calc.scoring_rules

      assert_equal KpiScoring::DEFAULT_FULL_SCORES, rules[:full_scores]
      assert_equal KpiScoring::DEFAULT_SECTION_WEIGHTS, rules[:section_weights]
    end

    test 'compute_quality_overall_total calculates weighted average' do
      calc = ScoreCalculator.new('Research Officer')
      params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '0' }.with_indifferent_access
      # Set all section A fields to their full score
      params['proposal_preparation'] = '10'
      params['proposal_presentation'] = '10'
      params['data_collection'] = '10'
      params['data_entry_and_cleaning'] = '10'
      params['report_writing'] = '30'
      params['analysis_of_data'] = '15'
      params['presentation_of_findings'] = '15'

      form = ScoreForm.new(params)
      total = calc.compute_quality_overall_total(form)

      # Section A: 100/100 * 100 = 100% raw * 70% weight = 70
      # Other sections all 0
      assert_equal BigDecimal('70'), total
    end

    test 'with_total_score adds total_score key' do
      calc = ScoreCalculator.new('Research Officer')
      attrs = { 'a' => BigDecimal('5'), 'b' => BigDecimal('10') }
      result = calc.with_total_score(attrs)

      assert_equal BigDecimal('15'), result[:total_score]
      assert_equal BigDecimal('5'), result['a']
    end

    test 'zero_attributes_for returns zero hash' do
      calc = ScoreCalculator.new('Research Officer')
      result = calc.zero_attributes_for(%w[a b c])

      assert_equal({ 'a' => 0.to_d, 'b' => 0.to_d, 'c' => 0.to_d }, result)
    end
  end
end
