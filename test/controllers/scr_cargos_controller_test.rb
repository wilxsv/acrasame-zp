require 'test_helper'

class ScrCargosControllerTest < ActionController::TestCase
  setup do
    @scr_cargo = scr_cargos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_cargos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_cargo" do
    assert_difference('ScrCargo.count') do
      post :create, scr_cargo: { cargoDescripcion: @scr_cargo.cargoDescripcion, cargoNombre: @scr_cargo.cargoNombre, cargoSalario: @scr_cargo.cargoSalario, cargo_id: @scr_cargo.cargo_id }
    end

    assert_redirected_to scr_cargo_path(assigns(:scr_cargo))
  end

  test "should show scr_cargo" do
    get :show, id: @scr_cargo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_cargo
    assert_response :success
  end

  test "should update scr_cargo" do
    patch :update, id: @scr_cargo, scr_cargo: { cargoDescripcion: @scr_cargo.cargoDescripcion, cargoNombre: @scr_cargo.cargoNombre, cargoSalario: @scr_cargo.cargoSalario, cargo_id: @scr_cargo.cargo_id }
    assert_redirected_to scr_cargo_path(assigns(:scr_cargo))
  end

  test "should destroy scr_cargo" do
    assert_difference('ScrCargo.count', -1) do
      delete :destroy, id: @scr_cargo
    end

    assert_redirected_to scr_cargos_path
  end
end
