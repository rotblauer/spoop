require 'test_helper'

class NonDonorsControllerTest < ActionController::TestCase
  setup do
    @non_donor = non_donors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:non_donors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create non_donor" do
    assert_difference('NonDonor.count') do
      post :create, non_donor: { email: @non_donor.email, message: @non_donor.message, newsletter_ok: @non_donor.newsletter_ok }
    end

    assert_redirected_to non_donor_path(assigns(:non_donor))
  end

  test "should show non_donor" do
    get :show, id: @non_donor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @non_donor
    assert_response :success
  end

  test "should update non_donor" do
    patch :update, id: @non_donor, non_donor: { email: @non_donor.email, message: @non_donor.message, newsletter_ok: @non_donor.newsletter_ok }
    assert_redirected_to non_donor_path(assigns(:non_donor))
  end

  test "should destroy non_donor" do
    assert_difference('NonDonor.count', -1) do
      delete :destroy, id: @non_donor
    end

    assert_redirected_to non_donors_path
  end
end
