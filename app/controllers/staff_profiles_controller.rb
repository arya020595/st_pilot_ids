# frozen_string_literal: true

class StaffProfilesController < ApplicationController
  before_action :set_staff_profile, only: [:show]

  def index
    authorize StaffProfile, policy_class: StaffProfilePolicy

    @q = policy_scope(StaffProfile, policy_scope_class: StaffProfilePolicy::Scope)
         .order(staff_profile_id: :asc)
         .ransack(params[:q])

    @per_page = sanitize_per_page(params[:per_page])
    @pagy, @staff_profiles = pagy(@q.result, limit: @per_page)
  end

  def show
    authorize @staff_profile, policy_class: StaffProfilePolicy
  end

  private

  def set_staff_profile
    @staff_profile = StaffProfile.find(params[:id])
  end

  def sanitize_per_page(value)
    per_page = value.to_i
    allowed_limits = [6, 10, 25, 50, 100]

    allowed_limits.include?(per_page) ? per_page : 6
  end
end
