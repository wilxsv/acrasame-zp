json.array!(@scr_det_contables) do |scr_det_contable|
  json.extract! scr_det_contable, :id, :dConIniPeriodo, :dConFinPeriodo, :dConActivo, :dConSimboloMoneda, :dConPagoXMes, :organizacion_id, :empleado_id
  json.url scr_det_contable_url(scr_det_contable, format: :json)
end
