json.array!(@scr_representante_legals) do |scr_representante_legal|
  json.extract! scr_representante_legal, :id, :rLegalNombre, :rLegalApellido, :rLegalTelefono, :rLegalCelular, :rLegalDireccion, :rLegalRegistro, :cat_rep_legal_id, :rLegalemail
  json.url scr_representante_legal_url(scr_representante_legal, format: :json)
end
