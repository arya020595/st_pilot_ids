# frozen_string_literal: true

# Controller for Staff Profile listing and detail views.
class StaffProfilesController < ApplicationController
  include RansackMultiSort

  before_action :set_staff_profile, only: [:show]

  def index
    authorize StaffProfile, policy_class: StaffProfilePolicy

    apply_ransack_search(
      policy_scope(StaffProfile, policy_scope_class: StaffProfilePolicy::Scope)
        .order(staff_profile_id: :asc)
    )
    @pagy, @staff_profiles = paginate_results(@q.result)
  end

  def show
    authorize @staff_profile, policy_class: StaffProfilePolicy

    redirect_to staff_profiles_path unless turbo_frame_request?
  end

  private

  def set_staff_profile
    @staff_profile = StaffProfile.find(params[:id])
  end
end
