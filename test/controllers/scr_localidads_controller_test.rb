require 'test_helper'

class ScrLocalidadsControllerTest < ActionController::TestCase
  setup do
    @scr_localidad = scr_localidads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_localidads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_localidad" do
    assert_difference('ScrLocalidad.count') do
      post :create, scr_localidad: { localidad_descripcion: @scr_localidad.localidad_descripcion, localidad_id: @scr_localidad.localidad_id, localidad_lat: @scr_localidad.localidad_lat, localidad_lon: @scr_localidad.localidad_lon, localidad_nombre: @scr_localidad.localidad_nombre }
    end

    assert_redirected_to scr_localidad_path(assigns(:scr_localidad))
  end

  test "should show scr_localidad" do
    get :show, id: @scr_localidad
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_localidad
    assert_response :success
  end

  test "should update scr_localidad" do
    patch :update, id: @scr_localidad, scr_localidad: { localidad_descripcion: @scr_localidad.localidad_descripcion, localidad_id: @scr_localidad.localidad_id, localidad_lat: @scr_localidad.localidad_lat, localidad_lon: @scr_localidad.localidad_lon, localidad_nombre: @scr_localidad.localidad_nombre }
    assert_redirected_to scr_localidad_path(assigns(:scr_localidad))
  end

  test "should destroy scr_localidad" do
    assert_difference('ScrLocalidad.count', -1) do
      delete :destroy, id: @scr_localidad
    end

    assert_redirected_to scr_localidads_path
  end
end
