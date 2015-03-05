require 'test_helper'

class ScrAreaTrabajosControllerTest < ActionController::TestCase
  setup do
    @scr_area_trabajo = scr_area_trabajos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_area_trabajos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_area_trabajo" do
    assert_difference('ScrAreaTrabajo.count') do
      post :create, scr_area_trabajo: { aTrabajoDescripcion: @scr_area_trabajo.aTrabajoDescripcion, aTrabajoNombre: @scr_area_trabajo.aTrabajoNombre, area_trabajo_id: @scr_area_trabajo.area_trabajo_id, cargo_id: @scr_area_trabajo.cargo_id, organizacion_id: @scr_area_trabajo.organizacion_id }
    end

    assert_redirected_to scr_area_trabajo_path(assigns(:scr_area_trabajo))
  end

  test "should show scr_area_trabajo" do
    get :show, id: @scr_area_trabajo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_area_trabajo
    assert_response :success
  end

  test "should update scr_area_trabajo" do
    patch :update, id: @scr_area_trabajo, scr_area_trabajo: { aTrabajoDescripcion: @scr_area_trabajo.aTrabajoDescripcion, aTrabajoNombre: @scr_area_trabajo.aTrabajoNombre, area_trabajo_id: @scr_area_trabajo.area_trabajo_id, cargo_id: @scr_area_trabajo.cargo_id, organizacion_id: @scr_area_trabajo.organizacion_id }
    assert_redirected_to scr_area_trabajo_path(assigns(:scr_area_trabajo))
  end

  test "should destroy scr_area_trabajo" do
    assert_difference('ScrAreaTrabajo.count', -1) do
      delete :destroy, id: @scr_area_trabajo
    end

    assert_redirected_to scr_area_trabajos_path
  end
end
