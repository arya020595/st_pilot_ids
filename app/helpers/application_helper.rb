module ApplicationHelper
  include Pagy::Method

  def safe_image_tag(source, **options)
    return unless source.present?

    image_tag(source, **options)
  rescue Propshaft::MissingAssetError
    content_tag(:span, options[:alt] || "Image", class: options[:class])
  end

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

  # Modal configuration for shared modal component
  def modal_config(id:, default_size: "modal-lg", frame_id: "modal",
                   backdrop: "static", keyboard: false, centered: true)
    {
      modal_id: id,
      default_size: default_size,
      frame_id: frame_id,
      backdrop: backdrop,
      keyboard: keyboard,
      centered: centered
    }
  end

  # Data attributes for links that open modals via Turbo Frames
  def modal_link_data(size: "modal-lg", frame: "modal")
    {
      data: {
        turbo_frame: frame,
        modal_size: size
      }
    }
  end

  # Per-page selector for pagination
  def per_page_selector(current: 10)
    options = [10, 25, 50, 100]
    select_tag :per_page,
               options_for_select(options, current.to_i),
               class: "form-select form-select-sm",
               style: "width: auto;",
               onchange: "this.form ? this.form.submit() : (window.location.search = '?per_page=' + this.value)"
  end
end
