json.array!(@scr_usuarios) do |scr_usuario|
  json.extract! scr_usuario, :id, :username, :password, :correousuario, :detalleuuario, :ultimavisitausuario, :ipusuario, :salt, :nombreusuario, :apellidousuario, :telefonousuario, :nacimientousuario, :latusuario, :lonusuario, :direccionusuario, :sexousuario, :registrousuario, :cuentausuario, :estado_id, :localidad_id, :imagenusuario
  json.url scr_usuario_url(scr_usuario, format: :json)
end
