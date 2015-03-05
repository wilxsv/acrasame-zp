require 'test_helper'

class ScrCobrosControllerTest < ActionController::TestCase
  setup do
    @scr_cobro = scr_cobros(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cobros)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cobro" do
    assert_difference('ScrCobro.count') do
      post :create, scr_cobro: { cat_cobro_id: @scr_cobro.cat_cobro_id, cobroCodigo: @scr_cobro.cobroCodigo, cobroDescripcion: @scr_cobro.cobroDescripcion, cobroFin: @scr_cobro.cobroFin, cobroInicio: @scr_cobro.cobroInicio, cobroNombre: @scr_cobro.cobroNombre, cobroPermanente: @scr_cobro.cobroPermanente, cobroValor: @scr_cobro.cobroValor }
    end

    assert_redirected_to scr_cobro_path(assigns(:scr_cobro))
  end

  test "should show scr_cobro" do
    get :show, id: @scr_cobro
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cobro
    assert_response :success
  end

  test "should update scr_cobro" do
    patch :update, id: @scr_cobro, scr_cobro: { cat_cobro_id: @scr_cobro.cat_cobro_id, cobroCodigo: @scr_cobro.cobroCodigo, cobroDescripcion: @scr_cobro.cobroDescripcion, cobroFin: @scr_cobro.cobroFin, cobroInicio: @scr_cobro.cobroInicio, cobroNombre: @scr_cobro.cobroNombre, cobroPermanente: @scr_cobro.cobroPermanente, cobroValor: @scr_cobro.cobroValor }
    assert_redirected_to scr_cobro_path(assigns(:scr_cobro))
  end

  test "should destroy scr_cobro" do
    assert_difference('ScrCobro.count', -1) do
      delete :destroy, id: @scr_cobro
    end

    assert_redirected_to scr_cobros_path
  end
end
