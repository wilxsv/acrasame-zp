json.array!(@scr_area_trabajos) do |scr_area_trabajo|
  json.extract! scr_area_trabajo, :id, :aTrabajoNombre, :aTrabajoDescripcion, :area_trabajo_id, :organizacion_id, :cargo_id
  json.url scr_area_trabajo_url(scr_area_trabajo, format: :json)
end
