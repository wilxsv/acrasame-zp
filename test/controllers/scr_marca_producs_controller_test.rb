require 'test_helper'

class ScrMarcaProducsControllerTest < ActionController::TestCase
  setup do
    @scr_marca_produc = scr_marca_producs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_marca_producs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_marca_produc" do
    assert_difference('ScrMarcaProduc.count') do
      post :create, scr_marca_produc: { marcaProducDescrip: @scr_marca_produc.marcaProducDescrip, marcaProducNombre: @scr_marca_produc.marcaProducNombre }
    end

    assert_redirected_to scr_marca_produc_path(assigns(:scr_marca_produc))
  end

  test "should show scr_marca_produc" do
    get :show, id: @scr_marca_produc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_marca_produc
    assert_response :success
  end

  test "should update scr_marca_produc" do
    patch :update, id: @scr_marca_produc, scr_marca_produc: { marcaProducDescrip: @scr_marca_produc.marcaProducDescrip, marcaProducNombre: @scr_marca_produc.marcaProducNombre }
    assert_redirected_to scr_marca_produc_path(assigns(:scr_marca_produc))
  end

  test "should destroy scr_marca_produc" do
    assert_difference('ScrMarcaProduc.count', -1) do
      delete :destroy, id: @scr_marca_produc
    end

    assert_redirected_to scr_marca_producs_path
  end
end
