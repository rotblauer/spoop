json.array!(@open_biome_logs) do |open_biome_log|
  json.extract! open_biome_log, :id, :user_id, :donated_on, :donor_group, :donor_number, :sample, :quarantine_state, :product, :usage, :processing_state, :weight, :bristol_score, :batch, :bio_safety_cabinet_number, :buffer_multiplier_used, :number_units_produced, :on_site_donation, :received_by_name, :processed_by_name, :time_of_passage, :time_received, :time_started, :time_finished, :rejection_reason, :rejection_reason_other, :biologics_master_file_version_number
  json.url open_biome_log_url(open_biome_log, format: :json)
end
