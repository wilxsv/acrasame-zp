require 'test_helper'

class ScrUsuariosControllerTest < ActionController::TestCase
  setup do
    @scr_usuario = scr_usuarios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scr_usuarios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scr_usuario" do
    assert_difference('ScrUsuario.count') do
      post :create, scr_usuario: { apellidousuario: @scr_usuario.apellidousuario, correousuario: @scr_usuario.correousuario, cuentausuario: @scr_usuario.cuentausuario, detalleuuario: @scr_usuario.detalleuuario, direccionusuario: @scr_usuario.direccionusuario, estado_id: @scr_usuario.estado_id, imagenusuario: @scr_usuario.imagenusuario, ipusuario: @scr_usuario.ipusuario, latusuario: @scr_usuario.latusuario, localidad_id: @scr_usuario.localidad_id, lonusuario: @scr_usuario.lonusuario, nacimientousuario: @scr_usuario.nacimientousuario, nombreusuario: @scr_usuario.nombreusuario, password: @scr_usuario.password, registrousuario: @scr_usuario.registrousuario, salt: @scr_usuario.salt, sexousuario: @scr_usuario.sexousuario, telefonousuario: @scr_usuario.telefonousuario, ultimavisitausuario: @scr_usuario.ultimavisitausuario, username: @scr_usuario.username }
    end

    assert_redirected_to scr_usuario_path(assigns(:scr_usuario))
  end

  test "should show scr_usuario" do
    get :show, id: @scr_usuario
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scr_usuario
    assert_response :success
  end

  test "should update scr_usuario" do
    patch :update, id: @scr_usuario, scr_usuario: { apellidousuario: @scr_usuario.apellidousuario, correousuario: @scr_usuario.correousuario, cuentausuario: @scr_usuario.cuentausuario, detalleuuario: @scr_usuario.detalleuuario, direccionusuario: @scr_usuario.direccionusuario, estado_id: @scr_usuario.estado_id, imagenusuario: @scr_usuario.imagenusuario, ipusuario: @scr_usuario.ipusuario, latusuario: @scr_usuario.latusuario, localidad_id: @scr_usuario.localidad_id, lonusuario: @scr_usuario.lonusuario, nacimientousuario: @scr_usuario.nacimientousuario, nombreusuario: @scr_usuario.nombreusuario, password: @scr_usuario.password, registrousuario: @scr_usuario.registrousuario, salt: @scr_usuario.salt, sexousuario: @scr_usuario.sexousuario, telefonousuario: @scr_usuario.telefonousuario, ultimavisitausuario: @scr_usuario.ultimavisitausuario, username: @scr_usuario.username }
    assert_redirected_to scr_usuario_path(assigns(:scr_usuario))
  end

  test "should destroy scr_usuario" do
    assert_difference('ScrUsuario.count', -1) do
      delete :destroy, id: @scr_usuario
    end

    assert_redirected_to scr_usuarios_path
  end
end
