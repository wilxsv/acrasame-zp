json.array!(@scr_bombeos) do |scr_bombeo|
  json.extract! scr_bombeo, :id, :fecha, :bombeo_inicio, :bombeo_fin, :voltaje, :amperaje, :presion, :lectura, :produccion, :empleado_id
  json.url scr_bombeo_url(scr_bombeo, format: :json)
end
