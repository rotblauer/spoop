require 'test_helper'

class DonorLogTest < ActiveSupport::TestCase

	# convenience
	def dl
		donor_logs(:donor_log_processable)
	end

	test 'fixtures should be valid' do 
		assert DonorLog.count == 3, "Should have 3 donor log fixtures"
		donor_logs.each do |d|
			assert d.valid?, "Donor log fixtures should be valid"
		end
	end

	## Validations
	#
	test 'weight must be present' do
		dl.update(weight: nil)
		assert_includes dl.errors.keys, :weight, "Weight must not be nil"
	end
	test 'weight must be a number' do
		dl.update(weight: 'nine')
		assert_includes dl.errors.keys, :weight, "Weight must not be a string"
	end
	test 'bristol score must be present' do
		dl.update(bristol_score: nil)
		assert_includes dl.errors.keys, :bristol_score, "Bristol must be present"
	end
	test 'bristol score must be a number between 1 and 7' do
		dl.bristol_score = 0
		assert_not dl.valid?, "Bristol must not be 0"
		dl.bristol_score = 'eight'
		assert_not dl.valid?, "Bristol must not be eight"
		dl.bristol_score = 5
		assert dl.valid?, "Bristol of 5 should be valid"
	end
	#DonorLog.time_of_passage_is_less_than_or_equal_to_about_now
	test 'top must not be too far in the future' do
		dl.update(time_of_passage: Time.zone.now + 15.minutes)
		assert_includes dl.errors.keys, :time_of_passage, "TOP must not be in the far future"
	end
	#DonorLog.belongs_to_donor
	test 'cant belong to admin' do
		d = DonorLog.new(dl.attributes.merge(user_id: users(:eduardo).id))
		d.save
		assert_includes d.errors.keys, :user_id, "Donor logs must not belong to admins"
	end
	test 'should parse tags from notes' do
		# nogo for fixture dls
		# so make new
		d = DonorLog.create!(dl.attributes.merge(id: 43123123))
		d.reload
		tl = d.tag_list
		assert_not tl.empty?, "Tag list should not be empty"
		assert_includes tl, 'kale', "Tag list should contain kale"
	end
	test 'must be donated to be processable' do
		dl.update(donated: false)
		assert_includes dl.errors.keys, :processable, "Donor log must be donated to be processable"
	end

	test 'should get meta log on creation' do 
		# without matching obl
		d = DonorLog.create!(dl.attributes.merge(id: 43123123))
		m = d.meta_logs.first
		assert m.present?, "Created donor log should have associated meta log"
		assert_equal m.time_of_passage, d.time_of_passage, "Meta log should have same top as donor log"

		# with matching obl
		o = OpenBiomeLog.create!(open_biome_logs(:one).attributes.merge(id: 12341234))
		d = DonorLog.create!(dl.attributes.merge(id: 12342342, time_of_passage: Time.zone.at(open_biome_logs(:one).time_of_passage)))
		m = d.meta_logs.first
		assert m.present?, "Created donor log with matching obl should have associated meta log"
		assert_equal m.donor_log_id, d.id, "Meta log should have donor log id"
		assert_equal m.open_biome_log_id, o.id, "Meta log should have open biome log id"
	end

end
