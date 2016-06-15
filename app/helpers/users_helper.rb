require 'helpers'
module UsersHelper
	include ActsAsTaggableOn::TagsHelper

	def link_for (msg, action, log_type, log_id, user_id)
		if action == 'show'
			if log_type == 'OpenBiomeLog'
				return link_to msg, user_open_biome_log_path(user_id, log_id)
			elsif log_type == 'DonorLog'
				return link_to msg, user_donor_log_path(user_id, log_id)
			end
		elsif action == 'edit'
			if log_type == 'OpenBiomeLog'
				return link_to msg, edit_user_open_biome_log_path(user_id, log_id)
			elsif log_type == 'DonorLog'
				return link_to msg, edit_user_donor_log_path(user_id, log_id)
			end
		end
	end

	def approximately_the_same_time(datetime1, datetime2)
		Helpers.approximately_the_same_time(datetime1, datetime2)		
	end

	def processing_label(log)
		affirmative = {text: '$40', css: 'success'}
		negative = {text: 'REJ', css: 'danger'}
		did_not_donate = {text: 'ND', css: 'warning'}
		
		if log.class == DonorLog
			if log.donated?
				return log.processable? ? affirmative : negative
			else
				return did_not_donate
			end
		elsif log.class == OpenBiomeLog
			return log.processing_state == 'processed' ? affirmative : negative	
		else
			return {text:'wtf', css: 'primary'}
		end
	end
end
