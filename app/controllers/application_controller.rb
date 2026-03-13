class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Pundit::Authorization
  include Pagy::Method

  before_action :authenticate_user!
  before_action :set_current_user

  # Smart layout switching: dashboard for authenticated pages, application for public pages
  layout :set_layout

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_layout
    # Use clean layout for Devise controllers (login, signup, password reset)
    # Use dashboard layout for all other authenticated pages
    devise_controller? ? "application" : "dashboard/application"
  end

  def set_current_user
    Current.user = current_user
  end

  # Override Devise method to redirect users after sign in
  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  # Override Devise method to redirect after sign out
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || dashboard_path)
  end
end
