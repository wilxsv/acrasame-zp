json.array!(@scr_estados) do |scr_estado|
  json.extract! scr_estado, :id, :nombreEstado
  json.url scr_estado_url(scr_estado, format: :json)
end
