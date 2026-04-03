# frozen_string_literal: true

require 'test_helper'

class BiDashboardsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    role = Role.find_or_create_by!(name: 'superadmin')

    @user = User.create!(
      name: 'BI Admin',
      email: "bi-admin-#{SecureRandom.hex(6)}@example.com",
      password: 'password123',
      password_confirmation: 'password123',
      role: role
    )

    sign_in @user
  end

  test 'index renders the power bi iframe' do
    get bi_dashboards_path

    assert_response :success
    assert_select 'iframe[title="IDS_ASSESSMENT DASHBOARD"][src="https://app.powerbi.com/view?r=eyJrIjoiN2NjZDBhZGEtYzY5Yy00YjkxLWEwOTMtMjc2YWU0NWU2MWM2IiwidCI6IjNiNmFjMTJhLTgwMDAtNGYwZS1iYmMyLWYwNzhiNTY0NGFlNiIsImMiOjEwfQ%3D%3D"]'
  end
end
