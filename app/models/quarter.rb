# frozen_string_literal: true

class Quarter < ApplicationRecord
  belongs_to :kpi_assessment

  has_one :quality_based_kpi, dependent: :destroy
  has_one :quantity_based_kpi, dependent: :destroy
end
