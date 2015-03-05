require 'test_helper'

class ScrBombeosControllerTest < ActionController::TestCase
  setup do
    @scr_bombeo = scr_bombeos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_bombeos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_bombeo" do
    assert_difference('ScrBombeo.count') do
      post :create, scr_bombeo: { amperaje: @scr_bombeo.amperaje, bombeo_fin: @scr_bombeo.bombeo_fin, bombeo_inicio: @scr_bombeo.bombeo_inicio, empleado_id: @scr_bombeo.empleado_id, fecha: @scr_bombeo.fecha, lectura: @scr_bombeo.lectura, presion: @scr_bombeo.presion, produccion: @scr_bombeo.produccion, voltaje: @scr_bombeo.voltaje }
    end

    assert_redirected_to scr_bombeo_path(assigns(:scr_bombeo))
  end

  test "should show scr_bombeo" do
    get :show, id: @scr_bombeo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_bombeo
    assert_response :success
  end

  test "should update scr_bombeo" do
    patch :update, id: @scr_bombeo, scr_bombeo: { amperaje: @scr_bombeo.amperaje, bombeo_fin: @scr_bombeo.bombeo_fin, bombeo_inicio: @scr_bombeo.bombeo_inicio, empleado_id: @scr_bombeo.empleado_id, fecha: @scr_bombeo.fecha, lectura: @scr_bombeo.lectura, presion: @scr_bombeo.presion, produccion: @scr_bombeo.produccion, voltaje: @scr_bombeo.voltaje }
    assert_redirected_to scr_bombeo_path(assigns(:scr_bombeo))
  end

  test "should destroy scr_bombeo" do
    assert_difference('ScrBombeo.count', -1) do
      delete :destroy, id: @scr_bombeo
    end

    assert_redirected_to scr_bombeos_path
  end
end
