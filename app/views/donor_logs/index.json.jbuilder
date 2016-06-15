json.array!(@donor_logs) do |donor_log|
  json.extract! donor_log, :id, :user_id, :bristol_score, :weight, :donated, :processable, :notes, :time_of_passage, :date_of_passage
  json.url donor_log_url(donor_log, format: :json)
end
