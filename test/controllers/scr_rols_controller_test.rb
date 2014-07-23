require 'test_helper'

class ScrRolsControllerTest < ActionController::TestCase
  setup do
    @scr_rol = scr_rols(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_rols)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_rol" do
    assert_difference('ScrRol.count') do
      post :create, scr_rol: { detallerol: @scr_rol.detallerol, nombrerol: @scr_rol.nombrerol }
    end

    assert_redirected_to scr_rol_path(assigns(:scr_rol))
  end

  test "should show scr_rol" do
    get :show, id: @scr_rol
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_rol
    assert_response :success
  end

  test "should update scr_rol" do
    patch :update, id: @scr_rol, scr_rol: { detallerol: @scr_rol.detallerol, nombrerol: @scr_rol.nombrerol }
    assert_redirected_to scr_rol_path(assigns(:scr_rol))
  end

  test "should destroy scr_rol" do
    assert_difference('ScrRol.count', -1) do
      delete :destroy, id: @scr_rol
    end

    assert_redirected_to scr_rols_path
  end
end
