require 'test_helper'

class UserTest < ActiveSupport::TestCase

	def valid_donor_ids
		ENV['valid_donor_numbers'].split(',')
	end

	def valid_donor_attrs
		{email:'jeff@yahoo.com', donor_id: valid_donor_ids[1], role: 'donor', group: 'open_biome', password:'asdfasdf', password_confirmation:'asdfasdf', read_the_fine_print: true}
	end
	def valid_admin_attrs
		{email:'jeff@yahoo.com', admin_secret: ENV['admin_secret'], donor_id: nil, role: 'admin', group: 'open_biome', password:'asdfasdf', password_confirmation:'asdfasdf', read_the_fine_print: true}
	end

	## Meta
	#
  test 'fixtures are valid' do
		users.each do |u|
			assert u.name.length > 0, "User has no name"
			assert u.valid?, "Fixture user is invalid"
		end
	end

  ## Donors
  #
  test 'donor_with_valid_params_can_be_created' do
  	u = User.new(valid_donor_attrs)
  	assert u.save
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
  	u.update(donor_id: 99999)
  	assert_not u.valid?
  	assert_includes u.errors.keys, :donor_id, 'Validated illegit donor_id.'

  	u.update(donor_id: nil)
  	assert_not u.valid?
  	assert_includes u.errors.keys, :donor_id, 'Validated without donor_id.'

  	u.update(donor_id: users(:mrroboto).donor_id)
  	assert_not u.valid?
  	assert_includes u.errors.keys, :donor_id, 'Validated with duplicate donor_id.'
  end

  ## Admins
  #
  test 'admin_creation_validates_admin_secret' do
  	a = User.new(valid_admin_attrs.merge(admin_secret: 'itsnotthis'))
  	assert_not a.save
  	assert_includes a.errors.keys, :admin_secret, "Saved admin with wrong secret"
  end

  test 'admin_with_valid_params_can_be_created' do
  	a = User.new(valid_admin_attrs)
  	assert a.save
  end

  ## Api keys
  #
  test 'each_has_one_api_key' do
  	assert_equal User.count, ApiKey.count, "Not equal numbers of users and api keys"
  end
  #User.create_user_api_key
  test 'gets_api_key_on_create' do
    u = User.new(valid_donor_attrs)
    assert_difference 'ApiKey.count', +1 do
      u.save
      u.reload # api key create on #after_save
    end

    # Check attrs of api key compared to user.
  	assert_not_nil u.api_key, "User should have child api key created when user is created"
  	assert_equal u.api_key.user_id, u.id, "Api key should have same id as user"
  	assert_equal u.api_key.role, u.role, "Api key has different role from created user"

  end

  #User.sync_api_key_role
  test 'api_key_updates_role_on_role_changed' do
  	u = users(:ob_donor)
    assert_equal u.api_key.role, u.role

    u.update(role: 'public')
    u.reload
  	assert_equal u.api_key.role, u.role, "Api key has different role when user changed roles"
  end

  #User.has_one :api_key, dependent: :destroy
  test 'api_key_is_destroyed_with_user_destroy' do
  	# assert_equal User.count, ApiKey.count, "Not equal numbers of users and api keys."
  	i = users(:ob_donor)
  	assert i.api_key.present?, "User doesnt have an api key to begin with"
  	n = i.id
  	i.destroy!
  	assert_not ApiKey.find_by(user_id: n), "Did not destroy api key along with user"
  end


end
