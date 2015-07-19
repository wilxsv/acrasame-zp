class ScrCuentua < ActiveRecord::Base
  self.table_name = "scr_cuenta"
  belongs_to :"scr_cuenta"
  
  scope :parcial, ->(debe, haber, fecha) { 
  		joins("INNER JOIN scr_transaccion ON scr_cuenta.id = scr_transaccion.cuenta_id")
  		.where(['"transaxFecha"<=?', fecha])
  		.select(:'scr_cuenta."cuentaNombre"', :'scr_cuenta."cuentaCodigo"', 
				:'SUM(CASE WHEN scr_transaccion."transaxDebeHaber"=TRUE THEN scr_transaccion."transaxMonto"
         WHEN scr_transaccion."transaxDebeHaber"=FALSE THEN 0
       END) AS "cuentaDebe"',
				:'SUM(CASE WHEN scr_transaccion."transaxDebeHaber"=FALSE THEN scr_transaccion."transaxMonto"
         WHEN scr_transaccion."transaxDebeHaber"=TRUE THEN 0
       END) AS "cuentaHaber"')
		.group(:'scr_cuenta."cuentaCodigo"', :'scr_cuenta."cuentaNombre"')
  }
end
#SELECT transaxSecuencia, transaxMonto, transaxDebeHaber, transaxFecha, scr_cuenta."cuentaNombre", scr_cuenta."cuentaCodigo" FROM "scr_cuenta" INNER JOIN scr_cuenta ON scr_cuenta.id = scr_transaccion.cuenta_id WHERE ("transaxSecuencia"='2015-07-08')  ORDER BY "cuentaCodigo"
