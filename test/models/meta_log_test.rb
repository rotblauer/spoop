require 'test_helper'

class MetaLogTest < ActiveSupport::TestCase

	def create_dl
    DonorLog.create!(donor_logs(:processable).attributes.merge(id: 123, time_of_passage: Time.zone.now, date_of_passage: Time.zone.now.beginning_of_day))
	end
	def create_obl
    OpenBiomeLog.create!(open_biome_logs(:one).attributes.merge(id: 123, time_of_passage: Time.zone.now, donated_on: Time.zone.now.beginning_of_day))
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
    donor_log = create_dl

    m = MetaLog.find_by(donor_log_id: donor_log.id)
    assert_not_nil m
    assert_equal m.donor_log_id, donor_log.id

    donor_log.destroy!
    assert_raises ActiveRecord::RecordNotFound do
      MetaLog.find(m.id)
    end
  end


  test 'destroying solo obl should destroy meta log' do
    obl = create_obl

    m = MetaLog.find_by(open_biome_log_id: obl.id)
    assert_not_nil m
    assert_equal m.open_biome_log_id, obl.id

    obl.destroy!
    assert_raises ActiveRecord::RecordNotFound do
      MetaLog.find(m.id)
    end
  end


  test 'destroying dl then obl for meta log with matching dl and obl' do
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

  test 'own_meta_log consistency between matching obls and dls' do
    n = create_matching_dl_and_obl
    m1 = n[:dl].own_meta_log
    m2 = n[:obl].own_meta_log
    assert_equal m1.id, m2.id
  end

  # Time of passage scenarios
  test 'changing time of passage within the window for a dl which has a matching obl should not effect the meta log' do
    n = create_matching_dl_and_obl

    dl = n[:dl]
    obl = n[:obl]

    t = dl.time_of_passage
    m1 = dl.own_meta_log

    dl.update_attributes(time_of_passage: t + 3.minutes)
    dl.reload
    m2 = dl.own_meta_log

    assert_equal m1.id, m2.id
    assert_equal m1.time_of_passage, m2.time_of_passage # for better or for worse...
  end

  test 'changing time_of_passage beyond window for a solo dl should leave no orphans' do
    dl = create_dl
    m = dl.own_meta_log
    assert_not_nil m.id

    times_to_check = [15.minutes, 15.hours, 15.days]
    times_to_check.each do |t|
      dl.update_attributes(time_of_passage: dl.time_of_passage - t)
      dl.reload

      assert_not_equal m.id, dl.own_meta_log.id
      assert_equal 0, MetaLog.where(donor_log_id: nil).where(open_biome_log_id: nil).count
      assert_raises ActiveRecord::RecordNotFound do
        MetaLog.find(m.id)
      end
    end
  end

  test 'changing time_of_passage beyond window for a dl which has a matching olb should effect the meta log' do
    n = create_matching_dl_and_obl
    dl = n[:dl]
    obl = n[:obl]

    top1 = dl.time_of_passage
    m1 = dl.own_meta_log

    times_to_check = [11.minutes, 1.hour, 1.day]

    times_to_check.each do |time|
      dl.update_attributes(time_of_passage: top1 - time)
      dl.reload
      m2 = dl.own_meta_log

      # ensure another meta log was created for the significantly altered dl
      assert_not_nil m2.id
      # ensure the newly spawned meta log for the changed dl is not that the same as the dl's original meta log
      assert_not_equal m1.id, m2.id
      # ensure the tops match for updated dl and spawned corresponding meta log
      assert_equal m2.time_of_passage, dl.time_of_passage
      # the original meta should still be parented by the unchanged obl
      assert_equal obl.own_meta_log.id, m1.id

      orphaned_mls_c = MetaLog.where(donor_log_id: nil).where(open_biome_log_id: nil).count
      assert_equal 0, orphaned_mls_c, "There are are orphaned meta logs by dl top updated to #{time}"
    end

  end

end
