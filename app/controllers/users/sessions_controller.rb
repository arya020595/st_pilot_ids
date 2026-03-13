# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # Skip authentication for login pages
    skip_before_action :authenticate_user!, only: %i[new create]

    # Use custom layout for Devise sessions
    layout 'devise/application'

    # POST /resource/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    # DELETE /resource/sign_out
    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      set_flash_message! :notice, :signed_out if signed_out
      yield if block_given?
      respond_to_on_destroy
    end

    protected

    def respond_to_on_destroy
      respond_to do |format|
        format.all { redirect_to new_user_session_path }
      end
    end
  end
end
