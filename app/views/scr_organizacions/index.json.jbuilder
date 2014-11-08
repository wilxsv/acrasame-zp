json.array!(@scr_organizacions) do |scr_organizacion|
  json.extract! scr_organizacion, :id, :organizacionNombre, :organizacionDescripcion, :localidad_id
  json.url scr_organizacion_url(scr_organizacion, format: :json)
end
