json.array!(@scr_rols) do |scr_rol|
  json.extract! scr_rol, :id, :nombrerol, :detallerol
  json.url scr_rol_url(scr_rol, format: :json)
end
