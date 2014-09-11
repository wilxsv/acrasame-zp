json.array!(@scr_cat_cobros) do |scr_cat_cobro|
  json.extract! scr_cat_cobro, :id, :cCobroNombre, :cCobroDescripcion
  json.url scr_cat_cobro_url(scr_cat_cobro, format: :json)
end
