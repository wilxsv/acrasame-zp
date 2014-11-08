json.array!(@scr_cuentuas) do |scr_cuentua|
  json.extract! scr_cuentua, :id, :cuentaNombre, :cuentaRegistro, :cuentaDebe, :cuentaHaber, :cat_cuenta_id, :cuentaActivo, :cuentaCodigo, :cuentaDescripcion, :cuentaNegativa
  json.url scr_cuentua_url(scr_cuentua, format: :json)
end
