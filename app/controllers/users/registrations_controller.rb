# frozen_string_literal: true

module Users
  # Custom Devise registrations controller for user account management.
  class RegistrationsController < Devise::RegistrationsController
    # Use dashboard layout for authenticated profile pages
    layout 'dashboard/application', only: %i[edit update]
  end
end
