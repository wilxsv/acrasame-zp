require 'test_helper'

class ScrCatActividadsControllerTest < ActionController::TestCase
  setup do
    @scr_cat_actividad = scr_cat_actividads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cat_actividads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cat_actividad" do
    assert_difference('ScrCatActividad.count') do
      post :create, scr_cat_actividad: { cActividadNombre: @scr_cat_actividad.cActividadNombre, catActividadDescripcion: @scr_cat_actividad.catActividadDescripcion }
    end

    assert_redirected_to scr_cat_actividad_path(assigns(:scr_cat_actividad))
  end

  test "should show scr_cat_actividad" do
    get :show, id: @scr_cat_actividad
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cat_actividad
    assert_response :success
  end

  test "should update scr_cat_actividad" do
    patch :update, id: @scr_cat_actividad, scr_cat_actividad: { cActividadNombre: @scr_cat_actividad.cActividadNombre, catActividadDescripcion: @scr_cat_actividad.catActividadDescripcion }
    assert_redirected_to scr_cat_actividad_path(assigns(:scr_cat_actividad))
  end

  test "should destroy scr_cat_actividad" do
    assert_difference('ScrCatActividad.count', -1) do
      delete :destroy, id: @scr_cat_actividad
    end

    assert_redirected_to scr_cat_actividads_path
  end
end
