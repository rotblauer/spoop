require 'test_helper'

class Api::V1::DonorLogsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:ob_donor)
    @token = @user.api_key.access_token

    sign_in_as @user
    
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end

  def valid_dl_params
    {
      user_id: @user.id,
      bristol_score: [3,4,5].sample,
      weight: Array(65..150).sample,
      donated: true,
      processable: true,
      notes: 'I eat #kale.',
      time_of_passage: Time.zone.now,
      date_of_passage: Time.zone.now.beginning_of_day,
      is_private: true,
      donor_number: @user.donor_id,
    }
  end

  def tweaked_dl_params
    {
      id: 123,
      time_of_passage: Time.zone.now - 19.minutes,
      date_of_passage: Time.zone.now.beginning_of_day
    }
  end
  def tweaked_obl_params
    {
      id: 123,
      sample: '0438-999',
      time_of_passage: Time.zone.now - 20.minutes, 
      time_received: Time.zone.now + 15.minutes,
      donated_on: Time.zone.now.beginning_of_day
    }
  end
  def make_logs_with_meta_logs
    @user.donor_logs.create!(donor_logs(:processable).attributes.merge(tweaked_dl_params))
    @user.open_biome_logs.create!(open_biome_logs(:one).attributes.merge(tweaked_obl_params))
  end

  test 'should get index' do
    # @request.headers["Accept"] = "application/json"
    get :index, {access_token: @token}
    assert_response :success
    body = JSON.parse(response.body)
    assert_not_nil body
  end

  test 'should get show' do 
    get :show, {id: donor_logs(:processable).id, access_token: @token}
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal body['notes'], 'I eat #kale.' #check identifiable attribute
  end

  test 'should successfully create a new donor log' do
    assert_difference 'DonorLog.count' do
      post(:create, valid_dl_params.merge(access_token: @token))
    end
    
    assert_response :success
    
    json_response = json @response.body
    assert_equal json_response['notes'], 'I eat #kale.'
  end

  test 'should update a donor log' do
    put(:update, {id: donor_logs(:processable).id, notes: 'I eat spinach.', access_token: @token})

    assert_response :success 

    json_response = json @response.body
    assert_equal json_response['notes'], 'I eat spinach.'
  end

  test 'should destroy a donor log' do
    assert_difference 'DonorLog.count', -1 do
      delete(:destroy, {id: donor_logs(:processable).id, access_token: @token})
    end
  end

  test 'should get heatmap' do
    make_logs_with_meta_logs
    get(:heatmap, {access_token: @token})
    
    assert_response :success

    # check that body looks like this
    # {12341312312: 1, 1231231231: 1, ...}
    res = json @response.body
    res.each do |k,v|
      assert_includes [1], v, 'Reponse vals should only be 1\'s'
    end

    # TODO prove response contains our create affiliate meta log top
  end

  test 'should get dayhour' do
    get(:dayhour, {access_token: @token})
    assert_response :success

    # TODO prove response accuracy
  end

  test 'should get statistics' do
    get(:statistics, {access_token: @token})
    assert_response :success
  end

  ## Test for requiring authentication
  # status 401 is Unauthorized
  test 'should require access token' do
    get :index
    assert_response 401
    post :create, valid_dl_params
    assert_response 401
    get :show, id: donor_logs(:processable).id
    assert_response 401
    put :update, id: donor_logs(:processable).id, notes: 'I eat spinach.'
    assert_response 401
    delete :destroy, id: donor_logs(:processable).id
    assert_response 401
    get :heatmap
    assert_response 401
    get :dayhour
    assert_response 401
    get :statistics
    assert_response 401
  end

end





