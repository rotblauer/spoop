require 'active_resource'
class BaseActiveResourceAPI < ActiveResource::Base
	self.site = Rails.application.secrets.secret_api_address + '/v1'
	headers['Authorization'] = "Token #{Rails.application.secrets.secret_api_token}"
	# self.element_name = "poop"
end