json.array!(@scr_cat_actividads) do |scr_cat_actividad|
  json.extract! scr_cat_actividad, :id, :cActividadNombre, :catActividadDescripcion
  json.url scr_cat_actividad_url(scr_cat_actividad, format: :json)
end
