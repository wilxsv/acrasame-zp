require 'test_helper'

class ScrBancosControllerTest < ActionController::TestCase
  setup do
    @scr_banco = scr_bancos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_bancos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_banco" do
    assert_difference('ScrBanco.count') do
      post :create, scr_banco: { banco_nombre: @scr_banco.banco_nombre }
    end

    assert_redirected_to scr_banco_path(assigns(:scr_banco))
  end

  test "should show scr_banco" do
    get :show, id: @scr_banco
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_banco
    assert_response :success
  end

  test "should update scr_banco" do
    patch :update, id: @scr_banco, scr_banco: { banco_nombre: @scr_banco.banco_nombre }
    assert_redirected_to scr_banco_path(assigns(:scr_banco))
  end

  test "should destroy scr_banco" do
    assert_difference('ScrBanco.count', -1) do
      delete :destroy, id: @scr_banco
    end

    assert_redirected_to scr_bancos_path
  end
end
