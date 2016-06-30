require 'helpers'
# An ideal poop that exists between the donor log and the open biome log.
# One poop to join them. To bind them. 
class MetaLog < ActiveRecord::Base
	belongs_to :user
	belongs_to :donor_log
	belongs_to :open_biome_log

	before_create :default_values

	scope :non_empty, -> { where.not('donor_log_id IS ? AND open_biome_log_id IS ?', nil, nil) }
	scope :orphans, -> { where('donor_log_id IS ? AND open_biome_log_id IS ?', nil, nil) }

	def default_values
		# choose donor log top as priority over obl
		# will have at least either donor_log or obl
		self.time_of_passage ||= (self.donor_log_id ? DonorLog.find(self.donor_log_id).time_of_passage : OpenBiomeLog.find(self.open_biome_log_id).time_of_passage)
		self.date_of_passage ||= (self.donor_log_id ? DonorLog.find(self.donor_log_id).date_of_passage : Helpers.get_date_of_passage(OpenBiomeLog.find(self.open_biome_log_id).time_of_passage))
		self.donor_id ||= donor_log.present? ? donor_log.donor_number : open_biome_log.donor_number
		self.user_id ||= donor_log.present? ? donor_log.user_id : open_biome_log.user_id
	end

	def self.has_relations
		donor_log_id.present? || open_biome_log_id.present?
	end

	def self.is_orphan
		!has_relations
	end

	# def ensure_one_parent
	# 	self.delete unless donor_log_id.present? || open_biome_log_id.present?
	# end

	# def destroy
	#   return false if donor_log.present? || open_biome_log.present?
	#   super
	# end

	# def destroy_if_empty
	# 	self.delete if (self.donor_log_id.nil? && self.open_biome_log_id.nil?)
	# end

	# Called after db migrate to create joins between already-existing dl and ob logs. 
	# This should only need to be called once, or on the reg in case of updates/whatever. 
	# def self.init_matches
	# 	DonorLog.all.each do |dl|
	# 		match = find_match(dl)
	# 		create_match(dl, match) if match
# 	end
	# 	OpenBiomeLog.all.each do |ob|
	# 		match = find_match(ob)
	# 		create_match(ob, match) if match
	# 	end
	# end

	# def MetaLog.find_match(log, minute_window)
	# 	# decide which direction to look for match, ie donor --> OB || OB --> donor
	# 	parent_log_classes = ['OpenBiomeLog', 'DonorLog']
	# 	the_other_class = Object.const_get parent_log_classes[0] #Object.const_get parent_log_classes.reject!{ |a| a == log.class.to_s }[0]
	# 	match = OpenBiomeLog.where(donor_number: log.donor_number).where('time_of_passage > ?', log.time_of_passage - minute_window).where('time_of_passage < ?', log.time_of_passage + minute_window)
	# 	match
	# end

end