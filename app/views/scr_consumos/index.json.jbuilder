json.array!(@scr_consumos) do |scr_consumo|
  json.extract! scr_consumo, :id, :registro, :cantidad, :cobro_id, :factura_id
  json.url scr_consumo_url(scr_consumo, format: :json)
end
