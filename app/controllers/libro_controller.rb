class LibroController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root contador administrador"
    acceso
    @scr_transaccions = ScrTransaccion.last(0)
      @lo = 0
    if params.has_key?(:transacx) 
      @lo = 1
      fecha = params['transacx']['transaxFecha']
      if true #fecha <= Time.now.strftime("%Y-%d-%m")
        @lo = params['transacx']['transaxFecha']
        @scr_transaccions = ScrTransaccion.where('"transaxFecha" = ?', fecha).order('"transaxSecuencia", "transaxRegistro"')
      else
        @lo = 3
        @scr_transaccions = ScrTransaccion.last(10)
      end
    end  
  end
  
  def mayor
    session[:roles] = "root contador administrador"
    acceso
    @ScrCuentua = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? ', 0, 0).order('"cuentaCodigo"')
  end
end
