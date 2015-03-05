require 'test_helper'

class ScrLecturasControllerTest < ActionController::TestCase
  setup do
    @scr_lectura = scr_lecturas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_lecturas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_lectura" do
    assert_difference('ScrLectura.count') do
      post :create, scr_lectura: { fechaLectura: @scr_lectura.fechaLectura, registroLectura: @scr_lectura.registroLectura, socio_id: @scr_lectura.socio_id, tecnico_id: @scr_lectura.tecnico_id, valorLectura: @scr_lectura.valorLectura }
    end

    assert_redirected_to scr_lectura_path(assigns(:scr_lectura))
  end

  test "should show scr_lectura" do
    get :show, id: @scr_lectura
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_lectura
    assert_response :success
  end

  test "should update scr_lectura" do
    patch :update, id: @scr_lectura, scr_lectura: { fechaLectura: @scr_lectura.fechaLectura, registroLectura: @scr_lectura.registroLectura, socio_id: @scr_lectura.socio_id, tecnico_id: @scr_lectura.tecnico_id, valorLectura: @scr_lectura.valorLectura }
    assert_redirected_to scr_lectura_path(assigns(:scr_lectura))
  end

  test "should destroy scr_lectura" do
    assert_difference('ScrLectura.count', -1) do
      delete :destroy, id: @scr_lectura
    end

    assert_redirected_to scr_lecturas_path
  end
end
