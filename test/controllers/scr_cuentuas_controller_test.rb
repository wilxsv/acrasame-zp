require 'test_helper'

class ScrCuentuasControllerTest < ActionController::TestCase
  setup do
    @scr_cuentua = scr_cuentuas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cuentuas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cuentua" do
    assert_difference('ScrCuentua.count') do
      post :create, scr_cuentua: { cat_cuenta_id: @scr_cuentua.cat_cuenta_id, cuentaActivo: @scr_cuentua.cuentaActivo, cuentaCodigo: @scr_cuentua.cuentaCodigo, cuentaDebe: @scr_cuentua.cuentaDebe, cuentaDescripcion: @scr_cuentua.cuentaDescripcion, cuentaHaber: @scr_cuentua.cuentaHaber, cuentaNegativa: @scr_cuentua.cuentaNegativa, cuentaNombre: @scr_cuentua.cuentaNombre, cuentaRegistro: @scr_cuentua.cuentaRegistro }
    end

    assert_redirected_to scr_cuentua_path(assigns(:scr_cuentua))
  end

  test "should show scr_cuentua" do
    get :show, id: @scr_cuentua
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cuentua
    assert_response :success
  end

  test "should update scr_cuentua" do
    patch :update, id: @scr_cuentua, scr_cuentua: { cat_cuenta_id: @scr_cuentua.cat_cuenta_id, cuentaActivo: @scr_cuentua.cuentaActivo, cuentaCodigo: @scr_cuentua.cuentaCodigo, cuentaDebe: @scr_cuentua.cuentaDebe, cuentaDescripcion: @scr_cuentua.cuentaDescripcion, cuentaHaber: @scr_cuentua.cuentaHaber, cuentaNegativa: @scr_cuentua.cuentaNegativa, cuentaNombre: @scr_cuentua.cuentaNombre, cuentaRegistro: @scr_cuentua.cuentaRegistro }
    assert_redirected_to scr_cuentua_path(assigns(:scr_cuentua))
  end

  test "should destroy scr_cuentua" do
    assert_difference('ScrCuentua.count', -1) do
      delete :destroy, id: @scr_cuentua
    end

    assert_redirected_to scr_cuentuas_path
  end
end
