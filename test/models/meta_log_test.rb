require 'test_helper'

class MetaLogTest < ActiveSupport::TestCase

	def create_dl
		DonorLog.create!(donor_logs(:processable).attributes.merge(id: 123))
	end
	def create_obl
		OpenBiomeLog.create!(open_biome_logs(:one).attributes.merge(id: 123))
	end
	def create_matching_dl_and_obl
		d = DonorLog.create!(donor_logs(:processable).attributes.merge(id: 123, time_of_passage: Time.zone.now, date_of_passage: Time.zone.now.beginning_of_day))
		o = OpenBiomeLog.create!(open_biome_logs(:one).attributes.merge(id: 123, time_of_passage: Time.zone.at(d.time_of_passage + 6.minutes), donated_on: d.date_of_passage))
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

		assert_difference 'MetaLog.count', +1 do
			@n = create_matching_dl_and_obl
		end

		m = MetaLog.last
# check parentage assert_equal @n[:dl].user_id, m.user_id
		assert_equal @n[:dl].id, m.donor_log_id
		assert_equal @n[:obl].id, m.open_biome_log_id
	end

  test 'destroying solo donor_log should destroy meta log' do
    donor_log = DonorLog.create!(donor_logs(:processable).attributes.merge(id: 1123, time_of_passage: Time.zone.now, date_of_passage: Time.zone.now.beginning_of_day))

    m = MetaLog.find_by(donor_log_id: donor_log.id)
    assert_not_nil m

    donor_log.destroy!
    assert_raises ActiveRecord::RecordNotFound do
      MetaLog.find(m.id)
    end
  end


  # test 'destroying solo obl should destroy meta log' do

  # end


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
