require 'test_helper'

class ScrEstadosControllerTest < ActionController::TestCase
  setup do
    @scr_estado = scr_estados(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_estados)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_estado" do
    assert_difference('ScrEstado.count') do
      post :create, scr_estado: { nombreEstado: @scr_estado.nombreEstado }
    end

    assert_redirected_to scr_estado_path(assigns(:scr_estado))
  end

  test "should show scr_estado" do
    get :show, id: @scr_estado
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_estado
    assert_response :success
  end

  test "should update scr_estado" do
    patch :update, id: @scr_estado, scr_estado: { nombreEstado: @scr_estado.nombreEstado }
    assert_redirected_to scr_estado_path(assigns(:scr_estado))
  end

  test "should destroy scr_estado" do
    assert_difference('ScrEstado.count', -1) do
      delete :destroy, id: @scr_estado
    end

    assert_redirected_to scr_estados_path
  end
end
