require 'test_helper'

class ScrCatCobrosControllerTest < ActionController::TestCase
  setup do
    @scr_cat_cobro = scr_cat_cobros(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cat_cobros)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cat_cobro" do
    assert_difference('ScrCatCobro.count') do
      post :create, scr_cat_cobro: { cCobroDescripcion: @scr_cat_cobro.cCobroDescripcion, cCobroNombre: @scr_cat_cobro.cCobroNombre }
    end

    assert_redirected_to scr_cat_cobro_path(assigns(:scr_cat_cobro))
  end

  test "should show scr_cat_cobro" do
    get :show, id: @scr_cat_cobro
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cat_cobro
    assert_response :success
  end

  test "should update scr_cat_cobro" do
    patch :update, id: @scr_cat_cobro, scr_cat_cobro: { cCobroDescripcion: @scr_cat_cobro.cCobroDescripcion, cCobroNombre: @scr_cat_cobro.cCobroNombre }
    assert_redirected_to scr_cat_cobro_path(assigns(:scr_cat_cobro))
  end

  test "should destroy scr_cat_cobro" do
    assert_difference('ScrCatCobro.count', -1) do
      delete :destroy, id: @scr_cat_cobro
    end

    assert_redirected_to scr_cat_cobros_path
  end
end
