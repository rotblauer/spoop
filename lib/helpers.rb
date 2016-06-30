require 'spoop_constants'
module Helpers

	## TODO: help out with...
	# - merging donor logs + open biome logs, giving preference to ob logs <-- heatmap, list
	# - make heatmap object
	# - move build_stats here
	# 

	# Heatmap. 
	# DEPRECATED. see api#donor_logs_controller#heatmap
	def Helpers.heatmapize(poos)
		heatmap_friendly_obj = {}
		poos.each { |poo| heatmap_friendly_obj[poo.time_of_passage.to_i] = 1 }
		heatmap_friendly_obj # This'll still need to be to_json-ized for talking to cal-heatmap.js
	end

	# Favor ob_logs in case of match with corresponding donor_log.
	def Helpers.merge_poos(donor_logs, ob_logs)
		together = []
		together += donor_logs 
		together += ob_logs

		donor_logs.each do |dl|

			sooner = dl.time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW
			later = dl.time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW

			match = ob_logs.where('time_of_passage > ?', sooner).where('time_of_passage < ?', later).any?

			together.delete(dl) if match
		end
		
		return together.sort_by(&:time_of_passage).reverse
	end

	def Helpers.punchcard_day_hour
		punchcard = {} # set up punchcard holder obj
		hours = Array(1..24)
		days = Array(1..7)
		days.each do |day|
		  punchcard[day] = {}
		  hours.each do |hour|
		    punchcard[day][hour] = 0
		  end
		end
		punchcard
	end

	# Guess class of stuff in string.
	# returns guessed thing.
	# http://stackoverflow.com/questions/1415819/find-type-of-the-content-number-date-time-string-etc-inside-a-string
	def Helpers.to_something(str)
	  duck = (Integer(str) rescue Float(str) rescue Time.parse(str) rescue nil)
	  duck.nil? ? str : duck
	end

	# Make header strings into attribute-worthy strings.
	def Helpers.attributize(string)
		string.strip.squish.downcase.tr(" ", "_")
	end

	# ie 12/3/15
	# useful for :donated_on field from csv 
	def Helpers.parse_date_from_backwards_string(string)
		puts string
		n = string.split('/').map{|a| a.to_i}
		puts n
		if n[2] < 2000
			year = 2000 + n[2]
		else 
			year = n[2]
		end
		month = n[0]
		day = n[1]
		Time.zone.local(year, month, day)
	end 

	def Helpers.get_date_of_passage(time_of_passage)
    Time.zone.local(time_of_passage.getutc.year, time_of_passage.getutc.month, time_of_passage.getutc.day)
 	end

	# fixes times in OB CSVs 
	def Helpers.fix_tzs(val)
	  dst_day = Time.zone.local(2016,3,13,1,59,0) 

	  puts "val -> #{val}" 

	  # if there is data and if its date data
	  if !val.nil? && val.class == ActiveSupport::TimeWithZone
	    if val > dst_day 
	      adjusted = val - 4.hours
	    else 
	      adjusted = val - 5.hours
	    end
	    puts "adjusted -> #{adjusted}"
	    return adjusted
	  end
	  # if nil
	  val
	end

	def Helpers.make_a_time_from_a_strange_number(d)
		# puts "Cell type: #{d.cell_type}  Cell value: #{d.cell_value}"
		possible_time_ratio_of_day =  (d.to_f / (24 * 60 * 60)).to_f
		ratio_in_hours = (24.0 * possible_time_ratio_of_day).to_f #xtraneous to_fs but who cares
		hours = ratio_in_hours.floor # int
		ratio_of_remaining_hour = (ratio_in_hours - hours.to_f).to_f
		minutes = (ratio_of_remaining_hour * 60.0).to_f
		return {
			hours: hours,
			minutes: minutes
		}
	end

	# deprecated. use in matching donor_logs with ob_logs. 
	def Helpers.approximately_the_same_time(datetime1, datetime2)
		return true if datetime2 < datetime1 + 3.minutes && datetime2 > datetime1 - 3.minutes
		false
	end

	def Helpers.encryptify(thing)
		# http://stackoverflow.com/questions/5492377/encrypt-decrypt-using-rails
		crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
		encrypted_thing = crypt.encrypt_and_sign(thing)
		encrypted_thing
	end

	def Helpers.decryptify(secret_thing)
		crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
		uncrypted = crypt.decrypt_and_verify(secret_thing)
		uncrypted
	end

	def Helpers.establish_meta_log(log, minute_window)
		match = MetaLog.find_match(log, minute_window)
		if match.any? 
			match = match.first
			case log.class
			when OpenBiomeLog 
				MetaLog.create!(user_id: log.user_id, donor_log_id: match.id, open_biome_log_id: log.id)	
			when DonorLog
				MetaLog.create!(user_id: log.user_id, donor_log_id: log.id, open_biome_log_id: match.id)
			end
		end
	end

end