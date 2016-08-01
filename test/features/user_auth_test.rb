require "test_helper"

class UserAuthTest < Capybara::Rails::TestCase
  # include ActionDispatch
	# TODO sign up
  
  test 'donor can sign up' do
    visit root_path
    click_link 'Sign up'

    assert_content 'Sign up'

    fill_in 'Email', with: 'test@es.com'
    # Since 'donor' is default selected role no need to explicitly choose it.
    fill_in 'Donor number', with: ENV['valid_donor_numbers'].split(',')[1]
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    find(:css, '#user_read_the_fine_print').set(true)

    click_button 'Sign up'

    assert_equal path_at(current_url), new_user_registration_path
    assert_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

    visit "#{user_confirmation_path}?confirmation_token=#{User.last.confirmation_token}"
    assert path_at(current_url), new_user_session_path
    assert_content "Your email address has been successfully confirmed. Sign on in!"
  end

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
