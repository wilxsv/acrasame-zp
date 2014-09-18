require 'test_helper'

class ScrUsuarioRolsControllerTest < ActionController::TestCase
  setup do
    @scr_usuario_rol = scr_usuario_rols(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_usuario_rols)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_usuario_rol" do
    assert_difference('ScrUsuarioRol.count') do
      post :create, scr_usuario_rol: { rol_id: @scr_usuario_rol.rol_id, usuario_id: @scr_usuario_rol.usuario_id }
    end

    assert_redirected_to scr_usuario_rol_path(assigns(:scr_usuario_rol))
  end

  test "should show scr_usuario_rol" do
    get :show, id: @scr_usuario_rol
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_usuario_rol
    assert_response :success
  end

  test "should update scr_usuario_rol" do
    patch :update, id: @scr_usuario_rol, scr_usuario_rol: { rol_id: @scr_usuario_rol.rol_id, usuario_id: @scr_usuario_rol.usuario_id }
    assert_redirected_to scr_usuario_rol_path(assigns(:scr_usuario_rol))
  end

  test "should destroy scr_usuario_rol" do
    assert_difference('ScrUsuarioRol.count', -1) do
      delete :destroy, id: @scr_usuario_rol
    end

    assert_redirected_to scr_usuario_rols_path
  end
end
