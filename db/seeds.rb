# TODO: create helper logic module
# TODO: make some donor_logs and open_biome_logs coincide
# TODO: make people poop at appropriate times of day

# Create 50 tags. 

#########################################################

# Create approximately 18 users. 
18.times do |t|
	donor = User.new(	
		name: Faker::Internet.user_name,
		email: Faker::Internet.free_email,
		donor_id: Faker::Number.between(65, 10000),
		password: 'fluffy',
		password_confirmation: 'fluffy',
		role: 'donor',
		)
	donor.skip_confirmation!
	
	if donor.save!

		# Save some donor logs.
		donor_logs_num = Faker::Number.between(4,24)
		donor_logs_num.times do |t|
			# Sometime last two weeks ish.
			ta_min = Faker::Number.between(1, 60)
			ta_hour = Faker::Number.between(1, 24)
			ta_day = Faker::Number.between(0, 14)

			bristol_score = rand < 0.2 ? [2,6].sample : (3..5).to_a.sample
			weight = Faker::Number.between(40, 200)

			l = donor.donor_logs.new(
				bristol_score: bristol_score,
				weight: weight,
				time_of_passage: Time.zone.now - ta_day.days - ta_hour.hours - ta_min.minutes,
				donated: rand > 0.25, 
				processable: (bristol_score < 6 && bristol_score > 2) && weight >= 55 ? true : false,
				notes: Faker::Hipster.sentence
				)

			l.save!
		end

		# Save this many OBLs/person.
		open_biome_logs_num = Faker::Number.between(12, 48)

		# Beautiful humans. 
		def lab_techs 
			lab_techs = []
			8.times do |l|
				lab_techs.append(Faker::Name.name)
			end
			lab_techs
		end


		open_biome_logs_num.times do |t|

			## CONSTANTS

			# Weight limits.
			min_weight = 40
			max_weight = 215

			# Bristol limits.
			min_bristol = 2
			max_bristol = 6

			# Release first x percent.
			portion_to_release = 0.2

			# Screen x percent
			portion_to_screen = 0.05

			# Reject x percent for reason besides bristol. 
			portion_to_reject = 0.03

			# Some inventory stuff. 
			bio_safety_cabinet_number = [2,3,4].sample
			biologics_master_file_version_number = 5

			# How much water to add. 
			buffer_multiplier_scale = {
				'fmp_enema': 2.5,
				'fmp_250': 10.0,
				'gelatin_capsules': 1.0
			}

			# Poop on site usuality. 
			on_site_donation_rate = 0.1


			## CALCULATORS
			# Set bristol_score & weight.
			bristol_score = rand < 0.2 ? [min_bristol,max_bristol].sample : Faker::Number.between(min_bristol + 1, max_bristol - 1) 
			weight = Faker::Number.between(min_weight, max_weight)

			# Sometime last two months ish.
			ta_min = Faker::Number.between(1, 60)
			ta_hour = Faker::Number.between(1, 24)
			ta_day = Faker::Number.between(0, 14)
			ta_week = Faker::Number.between(0, 8)

			# Determine usage.
			usage = rand < portion_to_screen ? 'screening' : 'treatment'

			def decide_processing(bristol, weight, portion_to_reject)
				# Reject for weird reason.
				if rand < portion_to_reject
					processing_state = 'rejected' 
					rejection_reason = nil
					rejection_reason_other = Faker::Lorem.sentence
					
				# Reject for bristol reason.
				elsif (bristol == 6 || bristol == 2)
					processing_state = 'rejected'
					rejection_reason = 'bristol_score'
					rejection_reason_other = nil

				elsif weight < 55
					processing_state = 'rejected'
					rejection_reason = 'too_small'
					rejection_reason_other = nil					
				
				# Accept. 
				else 
					processing_state = 'processed'
					rejection_reason = nil
					rejection_reason_other = nil
				end
				return {
					processing_state: processing_state,
					rejection_reason: rejection_reason,
					rejection_reason_other: rejection_reason_other
				}
			end

			def decide_product(weight, bristol_score, max_weight)
				# If it's a big solid poop, make it an enema.
				if weight > max_weight * 0.9 && bristol_score == (4 || 3)
					product = 'fmp_enema'
					number_units = 1
				# Else if its just pretty big make it gelatin caps.
				elsif weight > max_weight * 0.7 && bristol_score == 4
					product = 'gelatin_capsules'
					number_units = 125
				else 
					product = 'fmp_250'
					number_units = (weight - (weight % 35)) / 35
				end

				return {
					product: product,
					number_units: number_units
				}
			end

			# Set times. 
			time_of_passage = Time.zone.now - ta_week.weeks - ta_day.days - ta_hour.hours - ta_min.minutes
			time_received = time_of_passage + (10..40).to_a.sample.minutes
			time_started = time_received + (5..25).to_a.sample.minutes
			time_finished = time_started + (10..50).to_a.sample.minutes

			# Create the log. 
			l = donor.open_biome_logs.new(
				donated_on: Time.zone.now.beginning_of_day,
				donor_group: 'Ferret',
				donor_number: donor.donor_id,
				sample: "#{donor.donor_id} - 00#{t}",
				quarantine_state: (t < (open_biome_logs_num * portion_to_release)) ? 'released' : 'quarantined',
				product: decide_product(weight, bristol_score, max_weight)[:product],
				usage: usage, # Could be improved with timing.
				processing_state: decide_processing(bristol_score, weight, portion_to_reject)[:processing_state],
				weight: weight,
				bristol_score: bristol_score,
				batch: nil,
				bio_safety_cabinet_number: bio_safety_cabinet_number,
				buffer_multiplier_used: buffer_multiplier_scale[decide_product(weight, bristol_score, max_weight)[:product]],
				number_units_produced: decide_product(weight, bristol_score, max_weight)[:number_units],
				on_site_donation: rand < on_site_donation_rate ? 'TRUE' : 'FALSE',
				received_by_name: lab_techs.sample,
				processed_by_name: lab_techs.sample,
				time_of_passage: time_of_passage,
				time_received: time_received,
				time_started: time_started,
				time_finished: time_finished,
				rejection_reason: decide_processing(bristol_score, weight, portion_to_reject)[:rejection_reason],
				rejection_reason_other: decide_processing(bristol_score, weight, portion_to_reject)[:rejection_reason_other],
				biologics_master_file_version_number: biologics_master_file_version_number
				)
			l.save!
		end
		 
	end # if donor.save!

end

############################################################

tags_pool = []
75.times do |t|
	tags_pool.append(Faker::Hipster.word)
end

DonorLog.all.each do |dl|
	n = (rand*3).round
	dl.notes = Faker::Hipster.sentence
	n.times do |t|
		random_tag = tags_pool.sample
		puts "Tagging log #{dl.id} by #{dl.user.email}'s from #{dl.time_of_passage} with: #{random_tag}."
		dl.notes += " ##{random_tag}"
	end
	dl.save!
end


User.find_by_donor_id(438).donor_logs.create([
  {
    bristol_score: 4,
    weight: 72,
    donated: true,
    processable: true,
    notes: "",
    time_of_passage: "2016-05-26T11:51:28.954-04:00",
    created_at: "2016-05-26T11:51:45.448-04:00",
    updated_at: "2016-05-26T11:51:45.448-04:00",
    date_of_passage: "2016-05-26T00:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 81,
    donated: true,
    processable: true,
    notes: "sneaked pre chipotle blowout. a trail mix.",
    time_of_passage: "2016-05-25T07:11:00.000-04:00",
    created_at: "2016-05-25T07:20:52.585-04:00",
    updated_at: "2016-05-25T07:20:52.585-04:00",
    date_of_passage: "2016-05-25T00:00:00.000-04:00"
  },
  {
    bristol_score: 5,
    weight: 62,
    donated: true,
    processable: true,
    notes: "meh",
    time_of_passage: "2016-05-24T07:06:51.268-04:00",
    created_at: "2016-05-24T07:07:17.142-04:00",
    updated_at: "2016-05-24T07:07:17.142-04:00",
    date_of_passage: "2016-05-24T00:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 195,
    donated: true,
    processable: true,
    notes: "tower of holy shit. day one painting, early breaky eggs and bread, late lunch salad, cott, mac and. water.",
    time_of_passage: "2016-05-23T16:11:48.666-04:00",
    created_at: "2016-05-23T16:12:41.541-04:00",
    updated_at: "2016-05-23T16:12:41.541-04:00",
    date_of_passage: "2016-05-23T00:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 180,
    donated: true,
    processable: true,
    notes: "unexact weight. off to paint.",
    time_of_passage: "2016-05-23T07:14:41.906-04:00",
    created_at: "2016-05-23T07:15:01.359-04:00",
    updated_at: "2016-05-23T07:15:01.359-04:00",
    date_of_passage: "2016-05-23T00:00:00.000-04:00"
  },
  {
    bristol_score: 5,
    weight: 95,
    donated: true,
    processable: false,
    notes: "red wine, kippered herring, hotdogs, kimchi. reddish?",
    time_of_passage: "2016-05-22T09:37:31.966-04:00",
    created_at: "2016-05-22T09:37:54.611-04:00",
    updated_at: "2016-05-23T16:12:57.287-04:00",
    date_of_passage: "2016-05-22T00:00:00.000-04:00"
  },
  {
    bristol_score: 5,
    weight: 75,
    donated: true,
    processable: true,
    notes: "light color. scallops, saison, beans+sandwhich dub lunch.",
    time_of_passage: "2016-05-21T12:58:51.389-04:00",
    created_at: "2016-05-21T12:59:34.373-04:00",
    updated_at: "2016-05-21T14:51:42.454-04:00",
    date_of_passage: "2016-05-21T00:00:00.000-04:00"
  },
  {
    bristol_score: 6,
    weight: 267,
    donated: true,
    processable: false,
    notes: "267 grams. american niagara. cow plop.",
    time_of_passage: "2016-05-20T10:37:48.352-04:00",
    created_at: "2016-05-20T10:38:13.348-04:00",
    updated_at: "2016-05-23T16:13:21.431-04:00",
    date_of_passage: "2016-05-20T00:00:00.000-04:00"
  },
  {
    bristol_score: 3,
    weight: 77,
    donated: true,
    processable: true,
    notes: "",
    time_of_passage: "2016-05-20T07:51:51.111-04:00",
    created_at: "2016-05-20T07:52:11.191-04:00",
    updated_at: "2016-05-20T07:52:11.191-04:00",
    date_of_passage: "2016-05-20T00:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 52,
    donated: false,
    processable: false,
    notes: "late bloomer and no cigar. pathetic",
    time_of_passage: "2016-05-19T10:59:29.096-04:00",
    created_at: "2016-05-19T11:19:01.203-04:00",
    updated_at: "2016-05-20T09:38:46.743-04:00",
    date_of_passage: "2016-05-19T00:00:00.000-04:00"
  },
  {
    bristol_score: 5,
    weight: 97,
    donated: true,
    processable: true,
    notes: "thick slick and soft. bacon, banana, coff+.5.5 2nd breaky. lunch -> jaja's pasta with chicken balls.",
    time_of_passage: "2016-05-18T12:56:24.193-04:00",
    created_at: "2016-05-18T12:56:24.194-04:00",
    updated_at: "2016-05-18T13:01:27.104-04:00",
    date_of_passage: "2016-05-17T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 109,
    donated: true,
    processable: true,
    notes: "beaut! turkish coffee, cott cheese+muesli breaky",
    time_of_passage: "2016-05-18T07:47:51.372-04:00",
    created_at: "2016-05-18T07:47:51.373-04:00",
    updated_at: "2016-05-18T07:48:30.054-04:00",
    date_of_passage: "2016-05-17T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 107,
    donated: true,
    processable: true,
    notes: "on site. pretty picturesque. 😊",
    time_of_passage: "2016-05-17T16:13:27.189-04:00",
    created_at: "2016-05-17T16:13:27.191-04:00",
    updated_at: "2016-05-17T23:08:56.113-04:00",
    date_of_passage: "2016-05-16T20:00:00.000-04:00"
  },
  {
    bristol_score: 5,
    weight: 81,
    donated: true,
    processable: true,
    notes: "coffee + 1/2&1/2 straight up at 5:45am. ital sausage din",
    time_of_passage: "2016-05-17T08:00:21.653-04:00",
    created_at: "2016-05-17T08:00:21.655-04:00",
    updated_at: "2016-05-19T07:49:08.225-04:00",
    date_of_passage: "2016-05-16T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 57,
    donated: true,
    processable: true,
    notes: "barely",
    time_of_passage: "2016-05-16T14:56:29.911-04:00",
    created_at: "2016-05-16T14:56:29.914-04:00",
    updated_at: "2016-05-17T10:38:33.698-04:00",
    date_of_passage: "2016-05-15T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 100,
    donated: true,
    processable: true,
    notes: "",
    time_of_passage: "2016-05-16T06:54:00.000-04:00",
    created_at: "2016-05-16T06:56:59.512-04:00",
    updated_at: "2016-05-17T10:38:33.693-04:00",
    date_of_passage: "2016-05-15T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 92,
    donated: true,
    processable: true,
    notes: "perfect. yestersay run dusty. eggs breaky. rings tabata wod.",
    time_of_passage: "2016-05-15T10:36:53.445-04:00",
    created_at: "2016-05-15T10:36:53.446-04:00",
    updated_at: "2016-05-17T11:21:18.663-04:00",
    date_of_passage: "2016-05-14T20:00:00.000-04:00"
  },
  {
    bristol_score: 3,
    weight: 111,
    donated: false,
    processable: false,
    notes: "",
    time_of_passage: "2016-05-14T08:10:00.000-04:00",
    created_at: "2016-05-14T08:47:00.071-04:00",
    updated_at: "2016-05-17T10:38:33.660-04:00",
    date_of_passage: "2016-05-13T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 65,
    donated: true,
    processable: true,
    notes: "",
    time_of_passage: "2016-05-13T16:58:55.392-04:00",
    created_at: "2016-05-13T16:58:55.394-04:00",
    updated_at: "2016-05-19T07:49:08.204-04:00",
    date_of_passage: "2016-05-12T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 65,
    donated: true,
    processable: true,
    notes: "tuna feast",
    time_of_passage: "2016-05-13T12:35:07.367-04:00",
    created_at: "2016-05-13T12:35:07.368-04:00",
    updated_at: "2016-05-19T07:49:08.218-04:00",
    date_of_passage: "2016-05-12T20:00:00.000-04:00"
  },
  {
    bristol_score: 5,
    weight: 84,
    donated: true,
    processable: true,
    notes: "life alive. cereal.",
    time_of_passage: "2016-05-13T09:51:28.971-04:00",
    created_at: "2016-05-13T09:51:28.975-04:00",
    updated_at: "2016-05-17T10:38:33.666-04:00",
    date_of_passage: "2016-05-12T20:00:00.000-04:00"
  },
  {
    bristol_score: 3,
    weight: 120,
    donated: true,
    processable: true,
    notes: "dub coffee & trail mix fruhstuck",
    time_of_passage: "2016-05-12T13:08:21.468-04:00",
    created_at: "2016-05-12T13:08:21.469-04:00",
    updated_at: "2016-05-17T10:38:33.671-04:00",
    date_of_passage: "2016-05-11T20:00:00.000-04:00"
  },
  {
    bristol_score: 4,
    weight: 83,
    donated: true,
    processable: true,
    notes: "",
    time_of_passage: "2016-05-12T08:00:00.000-04:00",
    created_at: "2016-05-12T11:13:08.591-04:00",
    updated_at: "2016-05-17T10:38:33.645-04:00",
    date_of_passage: "2016-05-11T20:00:00.000-04:00"
  }
])