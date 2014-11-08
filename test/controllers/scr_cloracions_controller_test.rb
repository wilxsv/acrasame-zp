require 'test_helper'

class ScrCloracionsControllerTest < ActionController::TestCase
  setup do
    @scr_cloracion = scr_cloracions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cloracions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cloracion" do
    assert_difference('ScrCloracion.count') do
      post :create, scr_cloracion: { empleado_id: @scr_cloracion.empleado_id, fecha: @scr_cloracion.fecha, gramos: @scr_cloracion.gramos, hora: @scr_cloracion.hora, localidad_id: @scr_cloracion.localidad_id, observacion: @scr_cloracion.observacion }
    end

    assert_redirected_to scr_cloracion_path(assigns(:scr_cloracion))
  end

  test "should show scr_cloracion" do
    get :show, id: @scr_cloracion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cloracion
    assert_response :success
  end

  test "should update scr_cloracion" do
    patch :update, id: @scr_cloracion, scr_cloracion: { empleado_id: @scr_cloracion.empleado_id, fecha: @scr_cloracion.fecha, gramos: @scr_cloracion.gramos, hora: @scr_cloracion.hora, localidad_id: @scr_cloracion.localidad_id, observacion: @scr_cloracion.observacion }
    assert_redirected_to scr_cloracion_path(assigns(:scr_cloracion))
  end

  test "should destroy scr_cloracion" do
    assert_difference('ScrCloracion.count', -1) do
      delete :destroy, id: @scr_cloracion
    end

    assert_redirected_to scr_cloracions_path
  end
end
