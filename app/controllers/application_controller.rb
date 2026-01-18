class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  include Pagy::Backend

  helper_method :show_help_fab?

  private

  def show_help_fab?
    return false if devise_controller?
    return false if controller_path.start_with?("admin/")
    return false if controller_name == "home" && action_name == "guide"

    true
  end

  def configure_permitted_parameters
    added = [ :nickname ]
    devise_parameter_sanitizer.permit(:sign_up,        keys: added)
    devise_parameter_sanitizer.permit(:account_update, keys: added)
  end
end
