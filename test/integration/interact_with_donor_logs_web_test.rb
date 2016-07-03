require 'test_helper'

class InteractWithDonorLogsWebTest < ActionDispatch::IntegrationTest
  
  def user
  	users(:ob_donor)
  end
  def at_user
  	user_path(user)
  end

  def dl
  	donor_logs(:processable) #belongs to users(:ob_donor)
  end

  def sign_in_as_user
  	sign_in_as(user)
  	assert_response :success
  end

  def valid_dl_params
  	{
  		time_of_passage: Time.zone.now,
  		weight: 75.0,
  		bristol_score: 4,
  		notes: 'I eat yogurt.',
  		donated: true,
  		processable: true
  	}
  end

  test 'sign in' do
  	get new_user_session_path
  	assert_response :success

  	sign_in_as_user

  	assert_equal at_user, path  	
  end

  test 'create donor log' do
  	sign_in_as_user

  	get new_user_donor_log_path(user)
  	assert_response :success

    assert_difference 'DonorLog.count', +1 do 
  	 post user_donor_logs_path, {user_id: user.id, donor_log: valid_dl_params}
    end
    assert_redirected_to user_path(user)
	end

	test 'edit donor log' do
		sign_in_as_user

		get edit_user_donor_log_path(user, dl)
		assert_response :success

		put user_donor_log_path, {user_id: user.id, donor_log: {notes: 'I eat beans.'}}
		assert_redirected_to user_path(user)

		dl.reload
		assert_equal 'I eat beans.', dl.notes
	end

	test 'destroy donor log' do
		sign_in_as_user
		assert_difference 'DonorLog.count', -1 do 
			delete user_donor_log_path(user, dl)
		end

		assert_redirected_to user_path(user)
	end

	test 'toggle dl privacy' do
		sign_in_as_user
		patch toggle_private_user_donor_log_path(user, dl), format: :js
		dl.reload
		assert_equal false, dl.is_private
	end

end
