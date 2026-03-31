# frozen_string_literal: true

require 'test_helper'

module KpiAssessments
  class UpdateServiceTest < ActiveSupport::TestCase
    setup do
      staff = staff_profiles(:research_officer)
      create_params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
                                                      .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '3' })
                                                      .with_indifferent_access
      create_form = ScoreForm.new(create_params)
      @assessment = CreateService.new(
        staff_profile: staff,
        reviewer_email: 'admin@test.com',
        score_form: create_form
      ).call
    end

    test 'updates quality and quantity records' do
      update_params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '8' }
                                                      .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '10' })
                                                      .with_indifferent_access
      update_form = ScoreForm.new(update_params)

      result = UpdateService.new(assessment: @assessment, score_form: update_form).call
      assert result

      @assessment.reload
      quantity = @assessment.quarters.first.quantity_based_kpi
      # 6 fields * 10 = 60
      assert_equal BigDecimal('60'), quantity.overall_total.to_d
    end

    test 'creates missing child records before updating' do
      # Destroy the quarter to simulate missing records
      @assessment.quarters.destroy_all

      update_params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
                                                      .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '5' })
                                                      .with_indifferent_access
      update_form = ScoreForm.new(update_params)

      assert_difference 'Quarter.count', 1 do
        UpdateService.new(assessment: @assessment, score_form: update_form).call
      end
    end

    test 'touches assessment timestamp' do
      old_updated_at = @assessment.updated_at

      update_params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '8' }
                                                      .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '8' })
                                                      .with_indifferent_access
      update_form = ScoreForm.new(update_params)

      travel 1.minute do
        UpdateService.new(assessment: @assessment, score_form: update_form).call
      end

      @assessment.reload
      assert @assessment.updated_at > old_updated_at
    end
  end
end
