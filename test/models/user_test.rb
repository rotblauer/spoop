require 'test_helper'

class UserTest < ActiveSupport::TestCase

	def valid_donor_ids
		ENV['valid_donor_numbers'].split(',')
	end

	def valid_user_params
		{email:'jeff@yahoo.com', donor_id: valid_donor_ids[5], role: 'donor', group: 'open_biome', password:'asdfasdf', password_confirmation:'asdfasdf', read_the_fine_print: true}
	end

  
  test 'email_must_be_present' do 
  	u = User.new
  	assert_not u.valid?
  	assert_includes u.errors.keys, :email, 'Validated without email.'
  	u = User.new(email:'')
  	assert_not u.valid?
  	assert_includes u.errors.keys, :email, 'Validated with blank email.'
  end

  test 'email_must_be_unique' do 
  	u = users(:ob_donor)
  	n = User.create(email: u.email, password:'asdfasdf', password_confirmation:'asdfasdf')
  	assert_not n.valid?
  	assert_includes n.errors.keys, :email, 'Signed up with nonunique email.'
  end


  test 'email_must_have_valid_format' do 
  	u = users(:ob_donor)
  	assert_not u.update(email: 'm')
  	assert_includes u.errors.keys, :email, 'Validated bad email.'
  	assert_not u.update(email: 'm@m') # Devise will actually validate this. Suckers. 
  	assert_includes u.errors.keys, :email, 'Validated bad email.'
  end

  test 'read_fine_print_must_be_true' do 
  	u = User.new
  	assert_not u.valid?
  	assert_includes u.errors.keys, :read_the_fine_print, 'Validated without reading fine print.'
  	u = User.new(read_the_fine_print: false)
  	assert_not u.valid?
  	assert_includes u.errors.keys, :read_the_fine_print, 'Validated without reading fine print.'
  end

  test 'must_have_adequate_role' do 
  	u = User.new
  	assert_not u.valid?
  	assert_includes u.errors.keys, :role, 'Validated without role.'
  	
  	u = users(:ob_donor)
  	u.update(role: 'smartass')
  	assert_not u.valid?
  	assert_includes u.errors.keys, :role, 'Validated with role "smartass".'

  	u.update(role: '')
  	assert_not u.valid?
  	assert_includes u.errors.keys, :role, 'Validated with blank role.'
  end

  test 'donor_must_have_legit_donor_id' do 
  	u = users(:ob_donor)
  	u.update(donor_id: 1999)
  	assert_not u.valid?
  	assert_includes u.errors.keys, :donor_id, 'Validated illegit donor_id.'
  	
  	u.update(donor_id: nil)
  	assert_not u.valid?
  	assert_includes u.errors.keys, :donor_id, 'Validated without donor_id.'

  	u.update(donor_id: valid_donor_ids[1])
  	assert_not u.valid?
  	assert_includes u.errors.keys, :donor_id, 'Validated with duplicate donor_id.'
  end

  #User.create_user_api_key
  test 'gets_api_key_on_create' do
  	u = User.new(valid_user_params)
  	n = ApiKey.count
  	u.save
  	assert_equal n+1, ApiKey.count, "Api key was not created upon user creation."
  	assert_equal u.api_key.role, u.role, "Api key has different role from created user."
  end

  #User.sync_api_key_role
  test 'api_key_updates_role_on_role_changed' do 
  	u = User.create(valid_user_params)
  	u.update(role: 'public')
  	assert_equal u.api_key.role, u.role, "Api key has different role when user changed roles."
  end


end
