# frozen_string_literal: true

require 'test_helper'

module KpiAssessments
  class ShowPresenterTest < ActiveSupport::TestCase
    setup do
      staff = staff_profiles(:research_officer)
      params = KpiScoring::QUALITY_SCORE_FIELDS.index_with { '5' }
                                               .merge(KpiScoring::QUANTITY_SCORE_FIELDS.index_with { '3' })
                                               .with_indifferent_access
      form = ScoreForm.new(params)
      @assessment = CreateService.new(
        staff_profile: staff,
        reviewer_email: users(:admin).email,
        score_form: form
      ).call
    end

    test 'quality_view_sections returns 5 sections' do
      presenter = ShowPresenter.new(@assessment)
      sections = presenter.quality_view_sections

      assert_equal 5, sections.length
      assert_equal 'A. Research Work Related', sections[0][:title]
      assert_equal 'E. Other Involvement', sections[4][:title]
    end

    test 'each section has rows with field, label, full_score, actual_score' do
      presenter = ShowPresenter.new(@assessment)
      section_a = presenter.quality_view_sections.first
      row = section_a[:rows].first

      assert_equal 'proposal_preparation', row[:field]
      assert_equal 'Proposal Preparation', row[:label]
      assert row.key?(:full_score)
      assert row.key?(:actual_score)
      assert row.key?(:locked)
    end

    test 'quantity_view_rows returns 6 rows' do
      presenter = ShowPresenter.new(@assessment)
      rows = presenter.quantity_view_rows

      assert_equal 6, rows.length
      assert_equal 'number_of_involvement', rows[0][:field]
    end

    test 'quality_overall_total returns numeric value' do
      presenter = ShowPresenter.new(@assessment)
      total = presenter.quality_overall_total

      assert_kind_of BigDecimal, total
      assert total >= 0
    end

    test 'quantity_overall_total returns numeric value' do
      presenter = ShowPresenter.new(@assessment)
      total = presenter.quantity_overall_total

      assert_kind_of BigDecimal, total
      # 6 fields * 3 = 18
      assert_equal BigDecimal('18'), total
    end

    test 'reviewed_by resolves email to user name' do
      presenter = ShowPresenter.new(@assessment)

      assert_equal 'Admin User', presenter.reviewed_by
    end

    test 'reviewed_by falls back to email when user not found' do
      @assessment.update!(reviewer_email: 'unknown@test.com')
      presenter = ShowPresenter.new(@assessment)

      assert_equal 'unknown@test.com', presenter.reviewed_by
    end
  end
end
