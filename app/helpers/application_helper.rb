module ApplicationHelper
	def flash_class(level)
	  case level.to_sym
	  when :success then "alert alert-success"
	  when :notice then "alert alert-info"
	  when :info then "alert alert-info"
	  when :warning then "alert info-warning"
  	when :alert then "alert alert-warning"
	  when :error then "alert alert-danger"
  	when :danger then "alert alert-danger"
	  end
	end

	# deprecated. use en.yml time>formats
	def strf_standard(datetime, length)
		if length == 'short'
			return datetime.strftime('%a %k:%M%P - %b %-d')
		end
	end


	def highlight_hashtags(notes_string)
		
		tags = notes_string.scan(SpoopConstants::HASHTAG_REGEX) #=> [["icecream"], ["sandwhich"]] 
		tags.each do |tag|
			notes_string.gsub!('#'+"#{tag[0].to_s}", '<span class="label label-primary">#' + tag[0].to_s + ' </span>')
		end
		notes_string.html_safe
	end

end
