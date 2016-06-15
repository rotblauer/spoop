json.array!(@non_donors) do |non_donor|
  json.extract! non_donor, :id, :email, :message, :newsletter_ok
  json.url non_donor_url(non_donor, format: :json)
end
