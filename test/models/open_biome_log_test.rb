require 'test_helper'

class OpenBiomeLogTest < ActiveSupport::TestCase
  
  # convenience
  def obl
  	open_biome_logs(:one)
  end

	test 'fixtures should be valid' do 
		open_biome_logs.each do |o|
			assert o.valid?
		end
	end

	## Validations
	#
	#OpenBiomeLog.donor_number_matches_donor
	test 'donor number should match user donor id' do 
		# check init
		assert_equal obl.donor_number, obl.user.donor_id, "Fixture donor number should match its users donor id"
		
		obl.update(donor_number: 2)
		assert_includes obl.errors.keys, :donor_number, "Donor number must match user donor id"
	end

	#OpenBiomeLOg.processing_state
	test 'processing state must be present' do
		obl.update(processing_state: nil)
		assert_includes obl.errors.keys, :processing_state, "Processing state must exist"
	end

	test 'should initialize associated meta log' do 
		o = OpenBiomeLog.create(obl.attributes.merge(id: 123123123))
		m = o.own_meta_log
		assert_not_nil m, "Associated meta log should be created when obl is created"
		assert_equal m.time_of_passage, o.time_of_passage, "Meta log and obl should have same top"
	end

	test 'should become parent of existing matching meta log' do
		# create donor_log
		d = DonorLog.create!(donor_logs(:processable).attributes.merge(id: 123123))
		m = d.own_meta_log
		assert_not_nil m, "Creating donor log should create associated meta log"
		
		# create obl with same time as dl
		o = OpenBiomeLog.create!(obl.attributes.merge(id: 121233, time_of_passage: Time.zone.at(d.time_of_passage)))
		m.reload
		assert_equal o.id, m.open_biome_log_id, "OBL should parent matching existing meta log"
	end

	test 'should destroy orphaned meta log on destroy' do
		o = OpenBiomeLog.create!(obl.attributes.merge(id: 43123123, time_of_passage: Time.zone.now, donated_on: Time.zone.now.beginning_of_day))
		m = o.own_meta_log
		assert_not_nil m, "There is a meta log to destroy"
		
		o.destroy!
		assert_raises ActiveRecord::RecordNotFound do
			MetaLog.find(m.id)
		end
	end

	test 'should unparent meta log with dl parent' do 
		d = DonorLog.create!(donor_logs(:processable).attributes.merge(id: 12342342))
		o = OpenBiomeLog.create!(obl.attributes.merge(id: 12341234, time_of_passage: Time.zone.at(d.time_of_passage)))
		m = o.own_meta_log
		assert m.present?, "Created obl with matching dl should have associated meta log"
		assert_equal m.open_biome_log_id, o.id, "Meta log should have obl id"
		assert_equal m.donor_log_id, d.id, "Meta log should have dl id"
		
		o.destroy!
		m.reload
		assert_nil m.open_biome_log_id
	end

end
