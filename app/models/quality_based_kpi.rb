# frozen_string_literal: true

class QualityBasedKpi < ApplicationRecord
  belongs_to :quarter
  belongs_to :research_work, class_name: 'ResearchWorkRelated'
  belongs_to :financial_management
  belongs_to :soft_skill
  belongs_to :hard_skill
  belongs_to :other_involvement
end
