require 'test_helper'

class ScrProveedorsControllerTest < ActionController::TestCase
  setup do
    @scr_proveedor = scr_proveedors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_proveedors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_proveedor" do
    assert_difference('ScrProveedor.count') do
      post :create, scr_proveedor: { proveedorDescripcion: @scr_proveedor.proveedorDescripcion, proveedorNombre: @scr_proveedor.proveedorNombre }
    end

    assert_redirected_to scr_proveedor_path(assigns(:scr_proveedor))
  end

  test "should show scr_proveedor" do
    get :show, id: @scr_proveedor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_proveedor
    assert_response :success
  end

  test "should update scr_proveedor" do
    patch :update, id: @scr_proveedor, scr_proveedor: { proveedorDescripcion: @scr_proveedor.proveedorDescripcion, proveedorNombre: @scr_proveedor.proveedorNombre }
    assert_redirected_to scr_proveedor_path(assigns(:scr_proveedor))
  end

  test "should destroy scr_proveedor" do
    assert_difference('ScrProveedor.count', -1) do
      delete :destroy, id: @scr_proveedor
    end

    assert_redirected_to scr_proveedors_path
  end
end
