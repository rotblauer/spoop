require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase

	# ApiKeys are only either created or destroyed. 
	# One per user.
	# Access token and expiration are generated automatically in ApiKey.before_validation

	def valid_api_key_attrs
		{role: 'donor', user_id: 14, expires_at: Time.zone.now+6.months, access_token: 'asdf'}
	end

	test 'fixtures are valid' do 
		api_keys.each do |k|
			assert k.valid?
		end
	end

	test 'valid_api_key_attrs_are_valid' do 
		k = ApiKey.new(valid_api_key_attrs)
		assert k.valid?, "Valid api key attrs should be valid"
	end

	test 'equal number of api keys and users' do 
		assert_equal ApiKey.count, User.count
	end

	test 'role must be present' do 
		k = ApiKey.new(valid_api_key_attrs.merge(role: nil))
		assert_not k.valid?
		assert_includes k.errors.keys, :role, "Api key should not be valid without role"
	end

	test 'user id must be present' do 
		k = ApiKey.new(valid_api_key_attrs.merge(user_id: nil))
		assert_not k.valid?
		assert_includes k.errors.keys, :user_id, "Api key should not be valid without user_id"
	end

	test 'user id must be unique' do 
		k = ApiKey.new(valid_api_key_attrs.merge(user_id: users(:isaac).id))
		assert_not k.valid?
		assert_includes k.errors.keys, :user_id, "Api key should not be valid without user_id"
	end

	test 'creation generates access token' do
		# get rid of existing valid fixture
		a = api_keys(:one)
		u = a.user
		a.destroy!
		assert_raises ActiveRecord::RecordNotFound do 
			a.reload
		end

		# create without access token or expiration attrs
		na = ApiKey.create!(user_id: u.id, role: u.role)
		assert_not_nil na.access_token
		assert_not_nil na.expires_at
	end

	# #ApiKey.before_validation :generate_access_token
	# test 'access token is present even if you try to make it not present' do 
	# 	a = api_keys(:one)
	# 	assert a.update(access_token: nil) 
	# 	assert_not_nil a.access_token
	# end
	# test 'access token is unique even if you try to make it not' do 
	# 	a = ApiKey.new(valid_api_key_attrs.merge(access_token: api_keys(:one).access_token))
	# 	assert a.valid?
	# end


end
