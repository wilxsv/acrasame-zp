require 'test_helper'

class ScrEmpleadosControllerTest < ActionController::TestCase
  setup do
    @scr_empleado = scr_empleados(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_empleados)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_empleado" do
    assert_difference('ScrEmpleado.count') do
      post :create, scr_empleado: { cargo_id: @scr_empleado.cargo_id, empleadoApellido: @scr_empleado.empleadoApellido, empleadoCelular: @scr_empleado.empleadoCelular, empleadoDireccion: @scr_empleado.empleadoDireccion, empleadoDui: @scr_empleado.empleadoDui, empleadoEmail: @scr_empleado.empleadoEmail, empleadoFechaIngreso: @scr_empleado.empleadoFechaIngreso, empleadoIsss: @scr_empleado.empleadoIsss, empleadoNit: @scr_empleado.empleadoNit, empleadoNombre: @scr_empleado.empleadoNombre, empleadoRegistro: @scr_empleado.empleadoRegistro, empleadoTelefono: @scr_empleado.empleadoTelefono, localidad_id: @scr_empleado.localidad_id }
    end

    assert_redirected_to scr_empleado_path(assigns(:scr_empleado))
  end

  test "should show scr_empleado" do
    get :show, id: @scr_empleado
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_empleado
    assert_response :success
  end

  test "should update scr_empleado" do
    patch :update, id: @scr_empleado, scr_empleado: { cargo_id: @scr_empleado.cargo_id, empleadoApellido: @scr_empleado.empleadoApellido, empleadoCelular: @scr_empleado.empleadoCelular, empleadoDireccion: @scr_empleado.empleadoDireccion, empleadoDui: @scr_empleado.empleadoDui, empleadoEmail: @scr_empleado.empleadoEmail, empleadoFechaIngreso: @scr_empleado.empleadoFechaIngreso, empleadoIsss: @scr_empleado.empleadoIsss, empleadoNit: @scr_empleado.empleadoNit, empleadoNombre: @scr_empleado.empleadoNombre, empleadoRegistro: @scr_empleado.empleadoRegistro, empleadoTelefono: @scr_empleado.empleadoTelefono, localidad_id: @scr_empleado.localidad_id }
    assert_redirected_to scr_empleado_path(assigns(:scr_empleado))
  end

  test "should destroy scr_empleado" do
    assert_difference('ScrEmpleado.count', -1) do
      delete :destroy, id: @scr_empleado
    end

    assert_redirected_to scr_empleados_path
  end
end
