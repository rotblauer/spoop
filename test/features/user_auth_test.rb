require "test_helper"

class UserAuthTest < Capybara::Rails::TestCase

	# TODO sign up
	# TODO edit user

  test 'user sign in and out' do
  	do_sign_in(user)

  	page.click_link '', href: destroy_user_session_path
  	assert path_at(current_url), '/'
  end

  test 'demo log in' do
  	visit root_path
  	click_button 'Demo'
  	assert_content 'Mr. Roboto'
  end

  test 'user editing' do
  	do_sign_in(user)

  	# skip clicking around
  	visit edit_user_registration_path
  	assert path_at(current_url), edit_user_registration_path

  	fill_in 'Current password', with: password
  	# don't actually change anything. will still make put request
  	click_button 'Update'

  	assert path_at(current_url), user_path(user)
  end

  # TODO (needs js driver for modal)
  # test 'user destruction' do
  # 	do_sign_in(user)
  # 	visit edit_user_registration_path
  # 	click_button 'Destroy my account'
  # 	accept_confirm 'OK'
  # 	assert path_at(current_url), root_path
  # end


end
