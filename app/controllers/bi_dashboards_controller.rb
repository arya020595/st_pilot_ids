# frozen_string_literal: true

# Controller for BI Dashboard.
class BiDashboardsController < ApplicationController
  def index
    authorize :bi_dashboard, :index?
  end
end
