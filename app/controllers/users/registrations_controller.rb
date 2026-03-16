# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # Use dashboard layout for authenticated profile pages
    layout 'dashboard/application', only: %i[edit update]
  end
end
