class Api::ApiController < ApplicationController
	# before_action :ensure_json_request  
	skip_before_filter  :verify_authenticity_token

	private

		def ensure_json_request  
			# puts request.format
		  return if request.format == :json || request.format.xml?
		  render :nothing => true, :status => 406  
		end  

		def handle_key(key)
	    if key && !key.expired?
      	return @api_user = User.find(key.user_id)
      else 
      	return false
      end
		end

		# Inherited to child api controllers as :before_action callback.
	  def authenticate
	  	if !params[:access_token].nil?
	  		key = ApiKey.find_by_access_token(params[:access_token])
			  	handle_key(key)
	  	elsif user_signed_in?
	  		return @api_user = User.find(current_user.id)
	  	else
		    authenticate_or_request_with_http_token do |token, options|
		    	key = ApiKey.find_by_access_token(token)
	  		  handle_key(key)
		    end
		  end
	  end		

end
