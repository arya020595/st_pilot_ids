# frozen_string_literal: true

class QuantityBasedKpi < ApplicationRecord
  belongs_to :quarter
  belongs_to :output_and_impact_based
end
