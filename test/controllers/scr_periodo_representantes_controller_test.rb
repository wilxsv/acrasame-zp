require 'test_helper'

class ScrPeriodoRepresentantesControllerTest < ActionController::TestCase
  setup do
    @scr_periodo_representante = scr_periodo_representantes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_periodo_representantes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_periodo_representante" do
    assert_difference('ScrPeriodoRepresentante.count') do
      post :create, scr_periodo_representante: { organizacion_id: @scr_periodo_representante.organizacion_id, periodoFin: @scr_periodo_representante.periodoFin, periodoInicio: @scr_periodo_representante.periodoInicio, representante_legal_id: @scr_periodo_representante.representante_legal_id }
    end

    assert_redirected_to scr_periodo_representante_path(assigns(:scr_periodo_representante))
  end

  test "should show scr_periodo_representante" do
    get :show, id: @scr_periodo_representante
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_periodo_representante
    assert_response :success
  end

  test "should update scr_periodo_representante" do
    patch :update, id: @scr_periodo_representante, scr_periodo_representante: { organizacion_id: @scr_periodo_representante.organizacion_id, periodoFin: @scr_periodo_representante.periodoFin, periodoInicio: @scr_periodo_representante.periodoInicio, representante_legal_id: @scr_periodo_representante.representante_legal_id }
    assert_redirected_to scr_periodo_representante_path(assigns(:scr_periodo_representante))
  end

  test "should destroy scr_periodo_representante" do
    assert_difference('ScrPeriodoRepresentante.count', -1) do
      delete :destroy, id: @scr_periodo_representante
    end

    assert_redirected_to scr_periodo_representantes_path
  end
end
