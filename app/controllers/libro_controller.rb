class LibroController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root contador administrador"
    acceso
    @ScrCuentua = ScrTransaccion.last(0)
      @lo = 0
    if params.has_key?(:transacx) 
      @lo = 1
      fecha = params['transacx']['transaxFecha']
      @lo = params['transacx']['transaxFecha']
      if params['transacx']['transaxFecha'] != ""
        #@ScrCuentua = ScrTransaccion.where('"transaxFecha" = ?', fecha).order('"transaxSecuencia", "transaxRegistro"')
        @ScrCuentua = ScrTransaccion.libroDiario(fecha)
      end
    end  
  end
  
  def mayor
    session[:roles] = "root contador administrador"
    acceso
    @ScrCuentua = ScrCuentua.where('CAST("cuentaCodigo" AS TEXT) ~ \'^(1|2|3)\' AND ("cuentaDebe" + "cuentaHaber" > ?) OR "cuentaCodigo" < ?', 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
  end
end
