json.array!(@scr_empleados) do |scr_empleado|
  json.extract! scr_empleado, :id, :empleadoNombre, :empleadoApellido, :empleadoTelefono, :empleadoCelular, :empleadoDireccion, :empleadoDui, :empleadoIsss, :empleadoRegistro, :empleadoFechaIngreso, :cargo_id, :empleadoNit, :localidad_id, :empleadoEmail
  json.url scr_empleado_url(scr_empleado, format: :json)
end
