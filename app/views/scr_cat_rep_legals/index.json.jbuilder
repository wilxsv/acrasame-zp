json.array!(@scr_cat_rep_legals) do |scr_cat_rep_legal|
  json.extract! scr_cat_rep_legal, :id, :catRLegalNombre, :catRLegalDescripcion, :catRLegalRegistro, :catRLegalFirma
  json.url scr_cat_rep_legal_url(scr_cat_rep_legal, format: :json)
end
