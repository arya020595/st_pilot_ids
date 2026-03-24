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

  def data
    authorize StaffProfile, :index?, policy_class: StaffProfilePolicy

    current_user = User.find_by(id: params[:current_user_id])
    current_staff_profile_id = current_user&.staff_profile_id

    base_scope = policy_scope(StaffProfile, policy_scope_class: StaffProfilePolicy::Scope)
      .left_outer_joins(:user)

    available_scope = base_scope.where(users: { id: nil })
    if current_staff_profile_id.present?
      available_scope = available_scope.or(base_scope.where(staff_profile_id: current_staff_profile_id))
    end

    staff_profiles = available_scope
                      .order(fullname: :asc)
                      .select(:staff_profile_id, :fullname, :email)
                      .distinct

    render json: staff_profiles
  end

  private

  def set_staff_profile
    @staff_profile = StaffProfile.find(params[:id])
  end
end
