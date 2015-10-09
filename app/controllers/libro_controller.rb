class LibroController < ApplicationController
  include AccesoHelpers
  include InformeHelper
  require 'date'
  
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
        if params['transacx']['transaxFecha'] == nil
          @label = 0
        else
          @label = 1
          @fecha = params['transacx']['transaxFecha']
        end
      end
    end  
  end
  
  def mayor
    session[:roles] = "root contador administrador"
    acceso
    @label = 1
    @ScrCuentua = ScrCuentua.where('CAST("cuentaCodigo" AS TEXT) ~ \'^(1|2|3)\' AND ("cuentaDebe" + "cuentaHaber" > ?) OR "cuentaCodigo" < ?', 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
  end
  
  def pdf
  	id = params['transacx']['id']
    fecha = params['transacx']['transaxFecha']
    @@FTRANX = ""
    @@CONCEPTO = ""
    table = "";
    @@FTRANX = ""
  	if id.to_i == 0  
  	  titulo = "Libro diario "+fecha
  	  query = ScrTransaccion.libroDiario(fecha)
  	  head = ["<b>Cuenta</b>", "<b>Nombre</b>", "<b>Debe</b>", "<b>Haber</b>", "<b>Saldo</b>"]
  	  table = [head]
  	  debe = 0
      haber = 0
      query.each do |data|
		if data.transaxDebeHaber
		    debe+=data.transaxMonto
          	tdebe = data.transaxMonto.round(2)
          	thaber = ""
        else
          	haber+=data.transaxMonto
          	thaber = data.transaxMonto.round(2)
          	tdebe = ""
		end
        table = table + [[ data.cuentaCodigo, data.cuentaNombre, tdebe, thaber, data.transaxMonto.round(2) ]]
        @@FTRANX = data.transaxFecha
        @@CONCEPTO = data.comentario
      end
      table = table + [[ {:content=>"Total",:colspan=>2, :align=>:left}, debe.round(2), haber.round(2), "" ]]
      table = table + [[ {:content=>"Concepto: ["+@@CONCEPTO.to_s+"]",:colspan=>5, :align=>:left} ]]
  	else
  	  titulo = "Libro Mayor "+fecha
  	  query = ScrCuentua.where('CAST("cuentaCodigo" AS TEXT) ~ \'^(1|2|3)\' AND ("cuentaDebe" + "cuentaHaber" > ?) OR "cuentaCodigo" < ?', 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
  	  head = ["<b>Cuenta</b>", "<b>Nombre</b>", "<b>Debe</b>", "<b>Haber</b>", "<b>Saldo</b>"]
  	  table = [head]
  	  debe = 0
      haber = 0
      query.each do |data|
		thaber = data.cuentaHaber.round(2)
		tdebe = data.cuentaDebe.round(2)
		if data.cuentaDebe <= 0
          	tdebe = ""
        end
        if data.cuentaHaber <= 0
          	thaber = ""
		end
		if data.cuentaDebe - data.cuentaHaber < 0 
          saldo = "("+(data.cuentaHaber - data.cuentaDebe).round(2).to_s+")"
        else
          saldo = (data.cuentaDebe - data.cuentaHaber).round(2)
        end
        if data.cuentaCodigo >= 1000
		  debe+=data.cuentaDebe
		  haber+=data.cuentaHaber
        end
        table = table + [[ data.cuentaCodigo, data.cuentaNombre, tdebe, thaber, saldo ]]
        @@FTRANX = ""
        @@CONCEPTO = "Libro mayor"
      end
      table = table + [[ {:content=>"Total",:colspan=>2, :align=>:left}, debe.round(2), haber.round(2), "" ]]
      table = table + [[ {:content=>"Concepto: ["+@@CONCEPTO.to_s+"]",:colspan=>5, :align=>:left} ]]
  	end
  	send_data(genera_partida(titulo, "", table, @@FTRANX, ""), :filename => titulo+".pdf", :type => "application/pdf")
  end
end
