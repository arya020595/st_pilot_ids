module ApplicationHelper
  include Pagy::Method

  # Check if current page matches any of the given paths
  def active_nav_item?(*paths)
    paths.any? { |path| current_page?(path) }
  end

  # Check if current controller matches any of the given controller paths
  def active_controller?(*controllers)
    controllers.any? { |controller| controller_path.start_with?(controller) }
  end

  # Check if user has permission to view a menu item
  def can_view_menu?(permission_code)
    return true unless current_user

    current_user.has_permission?(permission_code)
  end

  # Returns a policy instance for the given record and policy class
  def record_policy(record, policy_class)
    policy_class.new(current_user, record)
  end
end
