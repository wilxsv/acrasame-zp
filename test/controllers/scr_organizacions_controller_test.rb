require 'test_helper'

class ScrOrganizacionsControllerTest < ActionController::TestCase
  setup do
    @scr_organizacion = scr_organizacions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_organizacions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_organizacion" do
    assert_difference('ScrOrganizacion.count') do
      post :create, scr_organizacion: { localidad_id: @scr_organizacion.localidad_id, organizacionDescripcion: @scr_organizacion.organizacionDescripcion, organizacionNombre: @scr_organizacion.organizacionNombre }
    end

    assert_redirected_to scr_organizacion_path(assigns(:scr_organizacion))
  end

  test "should show scr_organizacion" do
    get :show, id: @scr_organizacion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_organizacion
    assert_response :success
  end

  test "should update scr_organizacion" do
    patch :update, id: @scr_organizacion, scr_organizacion: { localidad_id: @scr_organizacion.localidad_id, organizacionDescripcion: @scr_organizacion.organizacionDescripcion, organizacionNombre: @scr_organizacion.organizacionNombre }
    assert_redirected_to scr_organizacion_path(assigns(:scr_organizacion))
  end

  test "should destroy scr_organizacion" do
    assert_difference('ScrOrganizacion.count', -1) do
      delete :destroy, id: @scr_organizacion
    end

    assert_redirected_to scr_organizacions_path
  end
end
