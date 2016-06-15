# require 'devise_helper'
class RegistrationsController < Devise::RegistrationsController
  before_filter :no_editing_the_robot, only: [:edit, :update, :destroy]
  before_action :configure_permitted_parameters

  private

    def no_editing_the_robot
      if current_user.demo
        redirect_to current_user 
        flash[:danger] = "Sorry, you can't tinker with this robot!"
      end
    end

    def after_update_path_for(resource)
      current_user
    end

    # because User#confirmable
    def after_inactive_sign_up_path_for(resource)
      new_user_registration_path #, info: "Please check your email for a link to confirm your account." # Or :prefix_to_your_route
    end

  protected

  def configure_permitted_parameters

    # added_attrs = [:donor_id, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: [:email, :donor_id, :password, :password_confirmation, :read_the_fine_print, :role, :group, :admin_secret]
    devise_parameter_sanitizer.permit :account_update, keys: [:email, :donor_id, :password, :password_confirmation, :current_password]
  end
end