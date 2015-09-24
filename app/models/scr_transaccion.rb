class ScrTransaccion < ActiveRecord::Base
  self.table_name = "scr_transaccion"
  belongs_to :"scr_cuenta"
  
  scope :partida, ->(idx) { 
  		joins("INNER JOIN scr_cuenta ON scr_cuenta.id = scr_transaccion.cuenta_id")
  		.where(['"transaxSecuencia"=?', idx])
  		.order('CAST("cuentaCodigo" AS TEXT)')
  		.select(:transaxSecuencia, :transaxMonto, :transaxDebeHaber, :transaxFecha, :'scr_cuenta."cuentaNombre"', :'scr_cuenta."cuentaCodigo"', :comentario) 
  }
  
  scope :libroDiario, ->(fecha) { 
  		joins("INNER JOIN scr_cuenta ON scr_cuenta.id = scr_transaccion.cuenta_id")
  		.where(['"transaxFecha"=?', fecha])
  		.order('CAST("cuentaCodigo" AS TEXT)')
  		.select(:transaxSecuencia, :transaxMonto, :transaxDebeHaber, :transaxFecha, :'scr_cuenta."cuentaNombre"', :'scr_cuenta."cuentaCodigo"', :comentario) 
  }
end
