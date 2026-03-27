# frozen_string_literal: true

class KpiAssessment < ApplicationRecord
  belongs_to :staff_profile, primary_key: :staff_profile_id, foreign_key: :staff_profile_id

  has_many :quarters, dependent: :destroy

  validates :reviewer_email, presence: true, allow_nil: true
end
