require 'test_helper'

class CobroControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
