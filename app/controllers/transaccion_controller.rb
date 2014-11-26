class TransaccionController < ApplicationController
  include AccesoHelpers
  require 'date'

  # POST /transaccion
  def index
    session[:roles] = " root Contabilidad "
    acceso
    @scr_transaccion = ScrTransaccion.new
    @scr_transaccions = ScrTransaccion.all.order('"transaxSecuencia", "transaxFecha"')
    @tmp = Array.new
    
    if params.has_key?(:transacx) #&& params['transacx']['transaxMonto'].is_a?(Numeric)
      monto = params['transacx']['transaxMonto']
      cuenta = params['transacx']['cuenta']
      debe = params['transacx']['transaxDebeHaber']
      session[:fecha] = params['transacx']['transaxFecha']#Date.parse(params['transacx']['transaxFecha']).strftime("%Y-%d-%m")
      if monto.to_f > 0 and cuenta.to_f > 0 and debe.to_f >= 0
        if session[:dato] != nil and session[:dato] != ""#transaxFecha
          @tmp = session[:dato]
          @tmp.push('<nodo><cuenta>'+cuenta.to_s+'</cuenta><monto>'+monto.to_s+'</monto><debe>'+debe.to_s+'</debe></nodo>')
          session[:dato] = @tmp
        else
          @tmp.push('<nodo><cuenta>'+cuenta.to_s+'</cuenta><monto>'+monto.to_s+'</monto><debe>'+debe.to_s+'</debe></nodo>')
          session[:dato] = @tmp
        end
        genera_tr(cuenta, monto, debe)
      end
    end
  end
  
  def create
    begin
      if session[:dato] != nil and 
        empleado_con = 1
        data = "<transacx><fecha>"+session[:fecha]+"</fecha><empleado>"+empleado_con.to_s+"</empleado><comentario>"+params['transacx']['comentario']+"</comentario>".to_s
        data += session[:dato].join(" ")+"</transacx>"
        @tm = session[:dato].join(" ") #data.sub(/ \["/, '')  
        @tmp = ScrTransaccion.connection.select_all("SELECT fcn_genera_transaccion as d FROM fcn_genera_transaccion('"+data+"');")
        if '{"d"=>"t"}'.count('t')  >= 1
          session[:dato] = nil
          session[:fecha] = nil
          session[:html] = nil
          session[:error] = nil
          redirect_to action: 'index'
        else
          session[:dato]
          session[:error] = "Se encontraron inconsistencias en su transacción"
          redirect_to action: 'index'
        end
      else
        redirect_to action: 'index', alert: "Watch it, mister!"
      end
    rescue
      session[:error] = "Se encontraron inconsistencias en su transacción"
      redirect_to action: 'index', alert: "Watch it, Salimos de un error :D  !"
    end
  end
  
  def show
    @scr_transaccions = ScrTransaccion.all.order('"transaxSecuencia", "transaxFecha"')
  end
  
  private
  def genera_tr(cuenta, monto, debe)
    cuenta = ScrCuentua.find(cuenta)
    if session[:html] == nil
      session[:html] = ""
      session[:debe] = 0
      session[:haber] = 0
    end
    session[:html] += "<tr><td>"+cuenta.cuentaCodigo.to_s+"</td><td>"+cuenta.cuentaNombre
    if debe.to_i == 1
      session[:html] += "</td><td>"+monto.to_s+"</td><td></td></tr>"
      session[:debe] += monto.to_f
    else
      session[:html] += "</td><td></td><td>"+monto.to_s+"</td></tr>"
      session[:haber] += monto.to_f
    end
  end
end
