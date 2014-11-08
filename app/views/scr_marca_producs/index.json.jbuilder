json.array!(@scr_marca_producs) do |scr_marca_produc|
  json.extract! scr_marca_produc, :id, :marcaProducNombre, :marcaProducDescrip
  json.url scr_marca_produc_url(scr_marca_produc, format: :json)
end
