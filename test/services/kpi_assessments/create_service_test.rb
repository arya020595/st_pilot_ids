# frozen_string_literal: true

require 'test_helper'

module KpiAssessments
  class CreateServiceTest < ActiveSupport::TestCase
    setup do
      @staff = staff_profiles(:research_officer)
      @params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
                                                .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '3' })
                                                .with_indifferent_access
      @form = ScoreForm.new(@params)
    end

    test 'creates full assessment tree' do
      assert_difference [
        'KpiAssessment.count',
        'Quarter.count',
        'QualityBasedKpi.count',
        'QuantityBasedKpi.count',
        'ResearchWorkRelated.count',
        'FinancialManagement.count',
        'SoftSkill.count',
        'HardSkill.count',
        'OtherInvolvement.count',
        'OutputAndImpactBased.count'
      ], 1 do
        CreateService.new(
          staff_profile: @staff,
          reviewer_email: 'admin@test.com',
          score_form: @form
        ).call
      end
    end

    test 'sets correct assessment attributes' do
      assessment = CreateService.new(
        staff_profile: @staff,
        reviewer_email: 'admin@test.com',
        score_form: @form
      ).call

      assert_equal @staff.fullname, assessment.fullname
      assert_equal @staff.position, assessment.position
      assert_equal 'admin@test.com', assessment.reviewer_email
      assert_equal @staff.staff_profile_id, assessment.staff_profile_id
    end

    test 'computes quality overall total' do
      assessment = CreateService.new(
        staff_profile: @staff,
        reviewer_email: 'admin@test.com',
        score_form: @form
      ).call

      quality = assessment.quarters.first.quality_based_kpi
      assert quality.overall_total.to_d > 0
    end

    test 'computes quantity overall total' do
      assessment = CreateService.new(
        staff_profile: @staff,
        reviewer_email: 'admin@test.com',
        score_form: @form
      ).call

      quantity = assessment.quarters.first.quantity_based_kpi
      # 6 fields * 3 = 18
      assert_equal BigDecimal('18'), quantity.overall_total.to_d
    end

    test 'sets current quarter name' do
      assessment = CreateService.new(
        staff_profile: @staff,
        reviewer_email: 'admin@test.com',
        score_form: @form
      ).call

      assert_equal KpiScoring.current_quarter_name, assessment.quarters.first.quarter_name
    end
  end
end
