json.array!(@users) do |user|
  json.extract! user, :id, :donor_id, :role
  json.url user_url(user, format: :json)
end
