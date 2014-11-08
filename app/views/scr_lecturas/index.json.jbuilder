json.array!(@scr_lecturas) do |scr_lectura|
  json.extract! scr_lectura, :id, :valorLectura, :fechaLectura, :registroLectura, :socio_id, :tecnico_id
  json.url scr_lectura_url(scr_lectura, format: :json)
end
