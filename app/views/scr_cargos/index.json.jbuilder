json.array!(@scr_cargos) do |scr_cargo|
  json.extract! scr_cargo, :id, :cargoNombre, :cargoDescripcion, :cargoSalario, :cargo_id
  json.url scr_cargo_url(scr_cargo, format: :json)
end
