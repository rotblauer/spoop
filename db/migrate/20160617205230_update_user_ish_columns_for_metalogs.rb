class UpdateUserIshColumnsForMetalogs < ActiveRecord::Migration
  def change
  	MetaLog.all.each do |m|
 			if m.donor_log.present?
  			m.user_id = m.donor_log.user_id
  			m.donor_id = m.donor_log.donor_number
  		else 
  			m.user_id = m.open_biome_log.user_id
  			m.donor_id = m.open_biome_log.donor_number
  		end
  		puts m.inspect
  		if m.save
  			puts "Saved."
  		else 
  			puts "Shit."
  		end
  	end
  end
end
