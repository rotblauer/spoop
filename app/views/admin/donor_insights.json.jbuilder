# # @comments = @post.comments

# json.array! @comments do |comment|
#   next if comment.marked_as_spam_by?(current_user)

#   json.body comment.body
#   json.author do
#     json.first_name comment.author.first_name
#     json.last_name comment.author.last_name
#   end
# end

# => [ { "body": "great post...", "author": { "first_name": "Joe", "last_name": "Bloe" }} ]


json.logs(@donor_logs) do |log|
	# http://stackoverflow.com/questions/23027644/how-to-extract-all-attributes-with-rails-jbuilder
	json.merge! log.attributes
	json.has_match log.open_biome_logs.any?
	json.tags log.tag_list.to_a
end

json.tags(@donor_logs) do |log| 
	json.id log.id
	json.donor_number log.donor_number
	json.bristol_score log.bristol_score
	json.notes log.notes
	json.donated log.donated
	json.processable log.processable
	json.tag_list log.tag_list 
end