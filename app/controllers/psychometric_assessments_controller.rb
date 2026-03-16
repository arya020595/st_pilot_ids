# frozen_string_literal: true

# Controller for Psychometric Assessment listing.
class PsychometricAssessmentsController < ApplicationController
  def index
    authorize :psychometric_assessment, :index?
  end
end
