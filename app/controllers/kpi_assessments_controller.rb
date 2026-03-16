# frozen_string_literal: true

# Controller for KPI Assessment listing.
class KpiAssessmentsController < ApplicationController
  def index
    authorize :kpi_assessment, :index?
  end
end
