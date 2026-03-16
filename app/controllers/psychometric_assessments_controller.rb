# frozen_string_literal: true

class PsychometricAssessmentsController < ApplicationController
  def index
    authorize :psychometric_assessment, :index?
  end
end
