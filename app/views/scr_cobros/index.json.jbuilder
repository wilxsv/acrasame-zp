json.array!(@scr_cobros) do |scr_cobro|
  json.extract! scr_cobro, :id, :cobroNombre, :cobroCodigo, :cobroDescripcion, :cobroInicio, :cobroFin, :cobroValor, :cobroPermanente, :cat_cobro_id
  json.url scr_cobro_url(scr_cobro, format: :json)
end
