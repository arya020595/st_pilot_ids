# frozen_string_literal: true

require 'test_helper'

module KpiAssessments
  class ScoreFormTest < ActiveSupport::TestCase
    def build_form(overrides = {})
      defaults = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
                                                 .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '5' })
                                                 .merge('staff_profile_id' => '1', 'reviewed_by' => 'Reviewer')
      ScoreForm.new(defaults.merge(overrides).with_indifferent_access)
    end

    test 'staff_profile_id and reviewed_by parsed from params' do
      form = build_form
      assert_equal '1', form.staff_profile_id
      assert_equal 'Reviewer', form.reviewed_by
    end

    test 'quality_valid? returns true when all fields present' do
      form = build_form
      assert form.quality_valid?('Research Officer')
    end

    test 'quality_valid? returns false when required field missing' do
      form = build_form('proposal_preparation' => '')
      assert_not form.quality_valid?('Research Officer')
    end

    test 'quality_valid? for research assistant only checks allowed fields' do
      # Research assistant only needs 9 specific fields
      allowed = KpiScoring::QUALITY_ALLOWED_FIELDS_BY_POSITION['research assistant']
      params = allowed.index_with { '5' }
      params['staff_profile_id'] = '1'
      form = ScoreForm.new(params.with_indifferent_access)

      assert form.quality_valid?('Research Assistant')
    end

    test 'quantity_valid? returns true when all quantity fields present' do
      form = build_form
      assert form.quantity_valid?
    end

    test 'quantity_valid? returns false when quantity field missing' do
      form = build_form('number_of_involvement' => '')
      assert_not form.quantity_valid?
    end

    test 'missing_quality_fields returns list of blank fields' do
      form = build_form('proposal_preparation' => '', 'data_collection' => '')
      missing = form.missing_quality_fields('Research Officer')
      assert_includes missing, 'proposal_preparation'
      assert_includes missing, 'data_collection'
    end

    test 'quality_component_attributes groups fields into components' do
      form = build_form
      attrs = form.quality_component_attributes

      assert_equal BigDecimal('5'), attrs[:research_work]['proposal_preparation']
      assert_equal BigDecimal('5'), attrs[:financial_management]['budgeting']
      assert_equal BigDecimal('5'), attrs[:soft_skill]['writing_skill']
      assert_equal BigDecimal('5'), attrs[:hard_skill]['communication_skill']
      assert_equal BigDecimal('5'), attrs[:other_involvement]['ideas_platform']
    end

    test 'quantity_attributes returns decimal hash' do
      form = build_form
      attrs = form.quantity_attributes

      assert_equal BigDecimal('5'), attrs['number_of_involvement']
      assert_equal BigDecimal('5'), attrs['output_production']
    end

    test 'score_value converts param to BigDecimal' do
      form = build_form('proposal_preparation' => '7.5')
      assert_equal BigDecimal('7.5'), form.score_value('proposal_preparation')
    end

    test 'score_value returns zero for missing param' do
      form = ScoreForm.new({}.with_indifferent_access)
      assert_equal BigDecimal('0'), form.score_value('proposal_preparation')
    end

    test 'quality_input_values returns hash with presence values' do
      form = build_form('proposal_preparation' => '5', 'data_collection' => '')
      values = form.quality_input_values

      assert_equal '5', values['proposal_preparation']
      assert_nil values['data_collection']
    end

    test 'previous_step_params includes quality values and staff info' do
      form = build_form
      staff = staff_profiles(:research_officer)
      result = form.previous_step_params(staff)

      assert_equal '1', result[:staff_profile_id]
      assert_equal 'Reviewer', result[:reviewed_by]
      assert_equal '5', result['proposal_preparation']
    end

    test 'previous_step_params falls back to staff supervisor_name' do
      params = { 'staff_profile_id' => '1' }.with_indifferent_access
      form = ScoreForm.new(params)
      staff = staff_profiles(:research_officer)
      result = form.previous_step_params(staff)

      assert_equal staff.supervisor_name, result[:reviewed_by]
    end
  end
end
