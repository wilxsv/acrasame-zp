require 'test_helper'

class ScrRepresentanteLegalsControllerTest < ActionController::TestCase
  setup do
    @scr_representante_legal = scr_representante_legals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_representante_legals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_representante_legal" do
    assert_difference('ScrRepresentanteLegal.count') do
      post :create, scr_representante_legal: { cat_rep_legal_id: @scr_representante_legal.cat_rep_legal_id, rLegalApellido: @scr_representante_legal.rLegalApellido, rLegalCelular: @scr_representante_legal.rLegalCelular, rLegalDireccion: @scr_representante_legal.rLegalDireccion, rLegalNombre: @scr_representante_legal.rLegalNombre, rLegalRegistro: @scr_representante_legal.rLegalRegistro, rLegalTelefono: @scr_representante_legal.rLegalTelefono, rLegalemail: @scr_representante_legal.rLegalemail }
    end

    assert_redirected_to scr_representante_legal_path(assigns(:scr_representante_legal))
  end

  test "should show scr_representante_legal" do
    get :show, id: @scr_representante_legal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_representante_legal
    assert_response :success
  end

  test "should update scr_representante_legal" do
    patch :update, id: @scr_representante_legal, scr_representante_legal: { cat_rep_legal_id: @scr_representante_legal.cat_rep_legal_id, rLegalApellido: @scr_representante_legal.rLegalApellido, rLegalCelular: @scr_representante_legal.rLegalCelular, rLegalDireccion: @scr_representante_legal.rLegalDireccion, rLegalNombre: @scr_representante_legal.rLegalNombre, rLegalRegistro: @scr_representante_legal.rLegalRegistro, rLegalTelefono: @scr_representante_legal.rLegalTelefono, rLegalemail: @scr_representante_legal.rLegalemail }
    assert_redirected_to scr_representante_legal_path(assigns(:scr_representante_legal))
  end

  test "should destroy scr_representante_legal" do
    assert_difference('ScrRepresentanteLegal.count', -1) do
      delete :destroy, id: @scr_representante_legal
    end

    assert_redirected_to scr_representante_legals_path
  end
end
