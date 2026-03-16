# frozen_string_literal: true

class KpiAssessmentsController < ApplicationController
  def index
    authorize :kpi_assessment, :index?
  end
end
