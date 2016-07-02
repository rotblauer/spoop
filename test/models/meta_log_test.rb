require 'test_helper'

class MetaLogTest < ActiveSupport::TestCase
  
	def create_dl
		DonorLog.create!(donor_logs(:processable).attributes.merge(id: 123))
	end
	def create_obl
		OpenBiomeLog.create!(open_biome_logs(:one).attributes.merge(id: 123))
	end
	def create_matching_dl_and_obl
		d = DonorLog.create!(donor_logs(:processable).attributes.merge(id: 123))
		o = OpenBiomeLog.create!(open_biome_logs(:one).attributes.merge(id: 123, time_of_passage: Time.zone.at(d.time_of_passage + 6.minutes)))
		{dl: d, obl: o}
	end

	test 'creating solo dl should init meta log' do
		m = create_dl.own_meta_log
		assert_not_nil m
	end

	test 'creating solo obl should init meta log' do
		m = create_obl.own_meta_log
		assert_not_nil m
	end

	test 'created matching obl and dl should init one meta log' do
		n = create_matching_dl_and_obl
		assert_equal 1, MetaLog.count #no meta log fixtures
		
		m = MetaLog.first
		
		# check parentage
		assert_equal n[:dl].id, m.donor_log_id
		assert_equal n[:obl].id, m.open_biome_log_id
	end

	test 'destructive capacities' do
		n = create_matching_dl_and_obl
		m = [n[:dl].own_meta_log, n[:obl].own_meta_log].sample #proof via randomness
		
		# donor log unparents meta on its destruction
		n[:dl].destroy!
		m.reload
		assert_nil m.donor_log_id

		# remaining obl destroys meta upon its destruction
		n[:obl].destroy!
		assert_raises ActiveRecord::RecordNotFound do
			MetaLog.find(m.id)
		end
	end

end
