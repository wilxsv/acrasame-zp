require 'test_helper'

class CargoControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
