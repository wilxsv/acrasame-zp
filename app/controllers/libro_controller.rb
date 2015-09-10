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
      @lo = params['transacx']['transaxFecha']
      if params['transacx']['transaxFecha'] != ""
        @scr_transaccions = ScrTransaccion.where('"transaxFecha" = ?', fecha).order('"transaxSecuencia", "transaxRegistro"')
      end
    end  
  end
  
  def mayor
    session[:roles] = "root contador administrador"
    acceso
    @ScrCuentua = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? ', 0, 0).order('"cuentaCodigo"')
  end
end
