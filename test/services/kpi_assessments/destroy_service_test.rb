# frozen_string_literal: true

require 'test_helper'

module KpiAssessments
  class DestroyServiceTest < ActiveSupport::TestCase
    setup do
      staff = staff_profiles(:research_officer)
      params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
                                               .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '3' })
                                               .with_indifferent_access
      form = ScoreForm.new(params)
      @assessment = CreateService.new(
        staff_profile: staff,
        reviewer_email: 'admin@test.com',
        score_form: form
      ).call
    end

    test 'destroys assessment and all children' do
      assert_difference 'KpiAssessment.count', -1 do
        assert_difference 'Quarter.count', -1 do
          assert_difference 'QualityBasedKpi.count', -1 do
            assert_difference 'QuantityBasedKpi.count', -1 do
              DestroyService.new(@assessment).call
            end
          end
        end
      end
    end

    test 'destroys component records' do
      assert_difference [
        'ResearchWorkRelated.count',
        'FinancialManagement.count',
        'SoftSkill.count',
        'HardSkill.count',
        'OtherInvolvement.count',
        'OutputAndImpactBased.count'
      ], -1 do
        DestroyService.new(@assessment).call
      end
    end
  end
end
