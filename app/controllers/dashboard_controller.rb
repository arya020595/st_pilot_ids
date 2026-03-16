# frozen_string_literal: true

# Dashboard controller for the main application dashboard
class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?
  end
end
