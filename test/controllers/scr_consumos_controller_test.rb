require 'test_helper'

class ScrConsumosControllerTest < ActionController::TestCase
  setup do
    @scr_consumo = scr_consumos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_consumos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_consumo" do
    assert_difference('ScrConsumo.count') do
      post :create, scr_consumo: { cantidad: @scr_consumo.cantidad, cobro_id: @scr_consumo.cobro_id, factura_id: @scr_consumo.factura_id, registro: @scr_consumo.registro }
    end

    assert_redirected_to scr_consumo_path(assigns(:scr_consumo))
  end

  test "should show scr_consumo" do
    get :show, id: @scr_consumo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_consumo
    assert_response :success
  end

  test "should update scr_consumo" do
    patch :update, id: @scr_consumo, scr_consumo: { cantidad: @scr_consumo.cantidad, cobro_id: @scr_consumo.cobro_id, factura_id: @scr_consumo.factura_id, registro: @scr_consumo.registro }
    assert_redirected_to scr_consumo_path(assigns(:scr_consumo))
  end

  test "should destroy scr_consumo" do
    assert_difference('ScrConsumo.count', -1) do
      delete :destroy, id: @scr_consumo
    end

    assert_redirected_to scr_consumos_path
  end
end
