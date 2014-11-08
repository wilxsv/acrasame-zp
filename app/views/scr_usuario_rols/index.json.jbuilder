json.array!(@scr_usuario_rols) do |scr_usuario_rol|
  json.extract! scr_usuario_rol, :id, :usuario_id, :rol_id
  json.url scr_usuario_rol_url(scr_usuario_rol, format: :json)
end
