json.array!(@scr_bancos) do |scr_banco|
  json.extract! scr_banco, :id, :banco_nombre
  json.url scr_banco_url(scr_banco, format: :json)
end
