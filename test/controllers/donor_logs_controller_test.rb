require 'test_helper'

class DonorLogsControllerTest < ActionController::TestCase
  setup do
    @donor_log = donor_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:donor_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create donor_log" do
    assert_difference('DonorLog.count') do
      post :create, donor_log: { bristol_score: @donor_log.bristol_score, date_of_passage: @donor_log.date_of_passage, donated: @donor_log.donated, notes: @donor_log.notes, processable: @donor_log.processable, time_of_passage: @donor_log.time_of_passage, user_id: @donor_log.user_id, weight: @donor_log.weight }
    end

    assert_redirected_to user_donor_log_path(@user, assigns(:donor_log))
  end

  test "should show donor_log" do
    get :show, id: @donor_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @donor_log
    assert_response :success
  end

  test "should update donor_log" do
    patch :update, id: @donor_log, donor_log: { bristol_score: @donor_log.bristol_score, date_of_passage: @donor_log.date_of_passage, donated: @donor_log.donated, notes: @donor_log.notes, processable: @donor_log.processable, time_of_passage: @donor_log.time_of_passage, user_id: @donor_log.user_id, weight: @donor_log.weight }
    assert_redirected_to user_donor_log_path(@user, assigns(:donor_log))
  end

  test "should destroy donor_log" do
    assert_difference('DonorLog.count', -1) do
      delete :destroy, id: @donor_log
    end

    assert_redirected_to user_donor_logs_path(@user)
  end
end
