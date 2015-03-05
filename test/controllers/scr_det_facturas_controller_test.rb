require 'test_helper'

class ScrDetFacturasControllerTest < ActionController::TestCase
  setup do
    @scr_det_factura = scr_det_facturas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_det_facturas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_det_factura" do
    assert_difference('ScrDetFactura.count') do
      post :create, scr_det_factura: { cancelada: @scr_det_factura.cancelada, det_factur_fecha: @scr_det_factura.det_factur_fecha, det_factur_numero: @scr_det_factura.det_factur_numero, fecha_cancelada: @scr_det_factura.fecha_cancelada, limite_pago: @scr_det_factura.limite_pago, socio_id: @scr_det_factura.socio_id, total: @scr_det_factura.total }
    end

    assert_redirected_to scr_det_factura_path(assigns(:scr_det_factura))
  end

  test "should show scr_det_factura" do
    get :show, id: @scr_det_factura
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_det_factura
    assert_response :success
  end

  test "should update scr_det_factura" do
    patch :update, id: @scr_det_factura, scr_det_factura: { cancelada: @scr_det_factura.cancelada, det_factur_fecha: @scr_det_factura.det_factur_fecha, det_factur_numero: @scr_det_factura.det_factur_numero, fecha_cancelada: @scr_det_factura.fecha_cancelada, limite_pago: @scr_det_factura.limite_pago, socio_id: @scr_det_factura.socio_id, total: @scr_det_factura.total }
    assert_redirected_to scr_det_factura_path(assigns(:scr_det_factura))
  end

  test "should destroy scr_det_factura" do
    assert_difference('ScrDetFactura.count', -1) do
      delete :destroy, id: @scr_det_factura
    end

    assert_redirected_to scr_det_facturas_path
  end
end
