require 'test_helper'

class ScrCatRepLegalsControllerTest < ActionController::TestCase
  setup do
    @scr_cat_rep_legal = scr_cat_rep_legals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cat_rep_legals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cat_rep_legal" do
    assert_difference('ScrCatRepLegal.count') do
      post :create, scr_cat_rep_legal: { catRLegalDescripcion: @scr_cat_rep_legal.catRLegalDescripcion, catRLegalFirma: @scr_cat_rep_legal.catRLegalFirma, catRLegalNombre: @scr_cat_rep_legal.catRLegalNombre, catRLegalRegistro: @scr_cat_rep_legal.catRLegalRegistro }
    end

    assert_redirected_to scr_cat_rep_legal_path(assigns(:scr_cat_rep_legal))
  end

  test "should show scr_cat_rep_legal" do
    get :show, id: @scr_cat_rep_legal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cat_rep_legal
    assert_response :success
  end

  test "should update scr_cat_rep_legal" do
    patch :update, id: @scr_cat_rep_legal, scr_cat_rep_legal: { catRLegalDescripcion: @scr_cat_rep_legal.catRLegalDescripcion, catRLegalFirma: @scr_cat_rep_legal.catRLegalFirma, catRLegalNombre: @scr_cat_rep_legal.catRLegalNombre, catRLegalRegistro: @scr_cat_rep_legal.catRLegalRegistro }
    assert_redirected_to scr_cat_rep_legal_path(assigns(:scr_cat_rep_legal))
  end

  test "should destroy scr_cat_rep_legal" do
    assert_difference('ScrCatRepLegal.count', -1) do
      delete :destroy, id: @scr_cat_rep_legal
    end

    assert_redirected_to scr_cat_rep_legals_path
  end
end
