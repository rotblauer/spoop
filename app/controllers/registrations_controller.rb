# require 'devise_helper'
class RegistrationsController < Devise::RegistrationsController
  before_filter :no_editing_the_robot, only: [:edit, :update, :destroy]


  private

    def no_editing_the_robot
      if current_user.demo
        redirect_to current_user 
        flash[:danger] = "Sorry, you can't tinker with this robot!"
      end
    end

    def sign_up_params
      params.require(:user).permit(:name, :email, :donor_id, :password, :password_confirmation, :read_the_fine_print, :role, :group, :admin_secret)
    end

    def account_update_params
      params.require(:user).permit(:name, :email, :donor_id, :password, :password_confirmation, :current_password)
    end

    def after_update_path_for(resource)
      current_user
    end

    # because User#confirmable
    def after_inactive_sign_up_path_for(resource)
      new_user_registration_path #, info: "Please check your email for a link to confirm your account." # Or :prefix_to_your_route
    end
end