require 'test_helper'

class ScrCatOrganizacionsControllerTest < ActionController::TestCase
  setup do
    @scr_cat_organizacion = scr_cat_organizacions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cat_organizacions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cat_organizacion" do
    assert_difference('ScrCatOrganizacion.count') do
      post :create, scr_cat_organizacion: { cOrgDescripcion: @scr_cat_organizacion.cOrgDescripcion, cOrgNombre: @scr_cat_organizacion.cOrgNombre }
    end

    assert_redirected_to scr_cat_organizacion_path(assigns(:scr_cat_organizacion))
  end

  test "should show scr_cat_organizacion" do
    get :show, id: @scr_cat_organizacion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cat_organizacion
    assert_response :success
  end

  test "should update scr_cat_organizacion" do
    patch :update, id: @scr_cat_organizacion, scr_cat_organizacion: { cOrgDescripcion: @scr_cat_organizacion.cOrgDescripcion, cOrgNombre: @scr_cat_organizacion.cOrgNombre }
    assert_redirected_to scr_cat_organizacion_path(assigns(:scr_cat_organizacion))
  end

  test "should destroy scr_cat_organizacion" do
    assert_difference('ScrCatOrganizacion.count', -1) do
      delete :destroy, id: @scr_cat_organizacion
    end

    assert_redirected_to scr_cat_organizacions_path
  end
end
