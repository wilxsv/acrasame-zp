json.array!(@scr_cat_organizacions) do |scr_cat_organizacion|
  json.extract! scr_cat_organizacion, :id, :cOrgNombre, :cOrgDescripcion
  json.url scr_cat_organizacion_url(scr_cat_organizacion, format: :json)
end
