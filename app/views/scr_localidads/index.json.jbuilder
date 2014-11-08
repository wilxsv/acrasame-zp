json.array!(@scr_localidads) do |scr_localidad|
  json.extract! scr_localidad, :id, :localidad_nombre, :localidad_descripcion, :localidad_id, :localidad_lat, :localidad_lon
  json.url scr_localidad_url(scr_localidad, format: :json)
end
