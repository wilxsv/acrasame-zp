require 'test_helper'

class ScrActividadsControllerTest < ActionController::TestCase
  setup do
    @scr_actividad = scr_actividads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_actividads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_actividad" do
    assert_difference('ScrActividad.count') do
      post :create, scr_actividad: {  }
    end

    assert_redirected_to scr_actividad_path(assigns(:scr_actividad))
  end

  test "should show scr_actividad" do
    get :show, id: @scr_actividad
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_actividad
    assert_response :success
  end

  test "should update scr_actividad" do
    patch :update, id: @scr_actividad, scr_actividad: {  }
    assert_redirected_to scr_actividad_path(assigns(:scr_actividad))
  end

  test "should destroy scr_actividad" do
    assert_difference('ScrActividad.count', -1) do
      delete :destroy, id: @scr_actividad
    end

    assert_redirected_to scr_actividads_path
  end
end
