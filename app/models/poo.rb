class Poo 
	include ActiveModel::Model
	# include ActiveModel::Validations
	# extend ActiveModel::Callbacks
	

	attr_accessor :log_id, :log_type, :user_id, :time_of_passage, :bristol_score, :weight, :donated, :processable, :notes

	# belongs_to :user
	

	# def Poo.merged_logs(open_biome_logs, donor_logs, options={limit: nil})

	# 	set = []
	# 	limit = options[:limit]
		
	# 	set += open_biome_logs.order('time_of_passage DESC').first(limit).map do |obl|
	# 	  # TODO fix :processable; finish implementation here with helper functions
	# 	  Poo.new(log_id: obl.id, log_type: 'obl', user_id: obl.user_id, time_of_passage: obl.time_of_passage, bristol_score: obl.bristol_score, weight: obl.weight, donated: obl.present?, processable: (obl.processing_state == 'processed' ? true : false), notes: 'Open Biome Log')
	# 	end

	# 	set += donor_logs.order('time_of_passage DESC').first(limit).map do |dl|
	# 	  Poo.new(log_id: dl.id, log_type: 'dl', user_id: dl.user_id, time_of_passage: dl.time_of_passage, bristol_score: dl.bristol_score, weight: dl.weight, donated: dl.donated, processable: dl.processable, notes: dl.notes)
	# 	end
		
	# 	sorted_set = set.sort_by(&:time_of_passage).reverse[0,limit]
	# 	sorted_set[0..(limit-1)]
	# end 
	
end
