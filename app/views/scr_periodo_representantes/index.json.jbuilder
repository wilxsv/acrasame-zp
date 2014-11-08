json.array!(@scr_periodo_representantes) do |scr_periodo_representante|
  json.extract! scr_periodo_representante, :id, :organizacion_id, :representante_legal_id, :periodoInicio, :periodoFin
  json.url scr_periodo_representante_url(scr_periodo_representante, format: :json)
end
