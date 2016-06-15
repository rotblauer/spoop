require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get overview" do
    get :overview
    assert_response :success
  end

  test "should get logs" do
    get :logs
    assert_response :success
  end

end
