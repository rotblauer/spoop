require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase

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

	test 'equal number of api keys and users' do 
		assert_equal ApiKey.count, User.count
	end

	


end
