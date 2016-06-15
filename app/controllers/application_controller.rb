class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  after_filter :track_action
  add_flash_types :success, :notice, :info, :warning, :alert, :error, :danger
  
  # Thought of using donor_id as login option, but not so hot on it anymore. They're not that secret. 
  # before_action :configure_permitted_parameters, if: :devise_controller?
  # protected
  # def configure_permitted_parameters
  #   added_attrs = [:donor_id, :email, :password, :password_confirmation, :remember_me]
  #   devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
  #   devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  # end
  
  private

  def track_action
    # https://github.com/ankane/ahoy/issues/98
    ahoy.track "#{controller_name}##{action_name}", request.filtered_parameters #.except("work").except("project").except("diff").except("user")
  end

  def after_sign_in_path_for(resource_or_scope)
   user_path(current_user)
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
  
end
