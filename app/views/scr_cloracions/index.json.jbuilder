json.array!(@scr_cloracions) do |scr_cloracion|
  json.extract! scr_cloracion, :id, :fecha, :hora, :gramos, :localidad_id, :empleado_id, :observacion
  json.url scr_cloracion_url(scr_cloracion, format: :json)
end
