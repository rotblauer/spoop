class IndexController < ApplicationController

	def home
		redirect_to current_user if user_signed_in?
	end

	def terms_and_conditions
	end

	def support
	end
end