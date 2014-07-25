json.array!(@scr_proveedors) do |scr_proveedor|
  json.extract! scr_proveedor, :id, :proveedorNombre, :proveedorDescripcion
  json.url scr_proveedor_url(scr_proveedor, format: :json)
end
