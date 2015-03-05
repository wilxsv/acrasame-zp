require 'test_helper'

class ScrDetContablesControllerTest < ActionController::TestCase
  setup do
    @scr_det_contable = scr_det_contables(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_det_contables)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_det_contable" do
    assert_difference('ScrDetContable.count') do
      post :create, scr_det_contable: { dConActivo: @scr_det_contable.dConActivo, dConFinPeriodo: @scr_det_contable.dConFinPeriodo, dConIniPeriodo: @scr_det_contable.dConIniPeriodo, dConPagoXMes: @scr_det_contable.dConPagoXMes, dConSimboloMoneda: @scr_det_contable.dConSimboloMoneda, empleado_id: @scr_det_contable.empleado_id, organizacion_id: @scr_det_contable.organizacion_id }
    end

    assert_redirected_to scr_det_contable_path(assigns(:scr_det_contable))
  end

  test "should show scr_det_contable" do
    get :show, id: @scr_det_contable
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_det_contable
    assert_response :success
  end

  test "should update scr_det_contable" do
    patch :update, id: @scr_det_contable, scr_det_contable: { dConActivo: @scr_det_contable.dConActivo, dConFinPeriodo: @scr_det_contable.dConFinPeriodo, dConIniPeriodo: @scr_det_contable.dConIniPeriodo, dConPagoXMes: @scr_det_contable.dConPagoXMes, dConSimboloMoneda: @scr_det_contable.dConSimboloMoneda, empleado_id: @scr_det_contable.empleado_id, organizacion_id: @scr_det_contable.organizacion_id }
    assert_redirected_to scr_det_contable_path(assigns(:scr_det_contable))
  end

  test "should destroy scr_det_contable" do
    assert_difference('ScrDetContable.count', -1) do
      delete :destroy, id: @scr_det_contable
    end

    assert_redirected_to scr_det_contables_path
  end
end
