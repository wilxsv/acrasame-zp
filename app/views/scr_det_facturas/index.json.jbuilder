json.array!(@scr_det_facturas) do |scr_det_factura|
  json.extract! scr_det_factura, :id, :det_factur_numero, :det_factur_fecha, :socio_id, :cancelada, :fecha_cancelada, :total, :limite_pago
  json.url scr_det_factura_url(scr_det_factura, format: :json)
end
