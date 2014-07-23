json.array!(@scr_transaccions) do |scr_transaccion|
  json.extract! scr_transaccion, :id, :transaxSecuencia, :cuenta_id, :transaxMonto, :transaxDebeHaber, :empleado_id, :transaxRegistro, :transaxFecha, :pcontable_id
  json.url scr_transaccion_url(scr_transaccion, format: :json)
end
