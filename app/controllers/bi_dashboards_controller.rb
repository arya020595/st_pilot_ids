# frozen_string_literal: true

class BiDashboardsController < ApplicationController
  def index
    authorize :bi_dashboard, :index?
  end
end
