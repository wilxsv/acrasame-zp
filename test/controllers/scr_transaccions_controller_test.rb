require 'test_helper'

class ScrTransaccionsControllerTest < ActionController::TestCase
  setup do
    @scr_transaccion = scr_transaccions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_transaccions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_transaccion" do
    assert_difference('ScrTransaccion.count') do
      post :create, scr_transaccion: { cuenta_id: @scr_transaccion.cuenta_id, empleado_id: @scr_transaccion.empleado_id, pcontable_id: @scr_transaccion.pcontable_id, transaxDebeHaber: @scr_transaccion.transaxDebeHaber, transaxFecha: @scr_transaccion.transaxFecha, transaxMonto: @scr_transaccion.transaxMonto, transaxRegistro: @scr_transaccion.transaxRegistro, transaxSecuencia: @scr_transaccion.transaxSecuencia }
    end

    assert_redirected_to scr_transaccion_path(assigns(:scr_transaccion))
  end

  test "should show scr_transaccion" do
    get :show, id: @scr_transaccion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_transaccion
    assert_response :success
  end

  test "should update scr_transaccion" do
    patch :update, id: @scr_transaccion, scr_transaccion: { cuenta_id: @scr_transaccion.cuenta_id, empleado_id: @scr_transaccion.empleado_id, pcontable_id: @scr_transaccion.pcontable_id, transaxDebeHaber: @scr_transaccion.transaxDebeHaber, transaxFecha: @scr_transaccion.transaxFecha, transaxMonto: @scr_transaccion.transaxMonto, transaxRegistro: @scr_transaccion.transaxRegistro, transaxSecuencia: @scr_transaccion.transaxSecuencia }
    assert_redirected_to scr_transaccion_path(assigns(:scr_transaccion))
  end

  test "should destroy scr_transaccion" do
    assert_difference('ScrTransaccion.count', -1) do
      delete :destroy, id: @scr_transaccion
    end

    assert_redirected_to scr_transaccions_path
  end
end
