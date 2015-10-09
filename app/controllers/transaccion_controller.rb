class TransaccionController < ApplicationController
  include AccesoHelpers
  include InformeHelper
  include ActionView::Helpers::NumberHelper
  require 'date'
  @@QUERY
  @@FTRANX
  @@CONCEPTO

  # POST /transaccion
  def index
    session[:roles] = "contador"
    acceso
    @scr_transaccion = ScrTransaccion.new
    @scr_transaccions = ScrTransaccion.all.order('"transaxSecuencia", "transaxFecha"')
    @tmp = Array.new
    
    if params.has_key?(:transacx) #&& params['transacx']['transaxMonto'].is_a?(Numeric)
      monto = params['transacx']['transaxMonto']
      monto = monto.to_f
      monto = monto.round(2)
      cuenta = params['transacx']['cuenta']
      debe = params['transacx']['transaxDebeHaber']
      session[:fecha] = params['transacx']['transaxFecha']#Date.parse(params['transacx']['transaxFecha']).strftime("%Y-%d-%m")
      if monto.to_f > 0 and cuenta.to_f > 0 and debe.to_f >= 0
        #monto = number_to_currency(monto.to_f, precision: 2)
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
      if session[:dato] != nil
        empleado_con = session[:empleado_id]
        data = "<transacx><fecha>"+session[:fecha]+"</fecha><empleado>"+empleado_con.to_s+"</empleado><comentario>"+params['transacx']['comentario']+"</comentario>".to_s
        data += session[:dato].join(" ")+"</transacx>"
        @tm = session[:dato].join(" ") #data.sub(/ \["/, '')  
        @tmp = ScrTransaccion.connection.select_all("SELECT fcn_genera_transaccion as d FROM fcn_genera_transaccion('"+data+"');")
        if '{"d"=>"t"}'.count('t')  >= 1
          session[:dato] = nil
          session[:fecha] = nil
          session[:html] = nil
          session[:error] = '<div class="alert alert-success"><button class="close" data-dismiss="alert" type="button">×</button><strong>Exito! </strong> Transaccion aplicada</div>'
          redirect_to action: 'index'
        else
          session[:dato]
          session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Se encontraron inconsistencias en su transacción .</div>'
          redirect_to action: 'index'
        end
      else
          session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Se encontraron inconsistencias en su transacción ..</div>'
        redirect_to action: 'index', alert: "Watch it, mister!"
      end
    rescue
      session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Se encontraron inconsistencias en su transacción ...</div>'
      redirect_to action: 'index', alert: "Watch it, Salimos de un error :D  !"
    end
  end
  
  def show
    @scr_transaccions = ScrTransaccion.all.order('"transaxSecuencia", "transaxFecha"')
  end
  
  def pdf
  	id = params['transacx']['id']
  	query = params['transacx']['query']
  	if id.to_i > 0 && query == "null"
  	  query = ScrTransaccion.partida(id)
  	  head = ["<b>Cuenta</b>", "<b>Descripcion</b>", "<b>Parcial</b>", "<b>Debe</b>", "<b>Haber</b>"]
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
        table = table + [[ data.cuentaCodigo, data.cuentaNombre, data.transaxMonto.round(2), tdebe, thaber ]]
        @@FTRANX = data.transaxFecha
        @@CONCEPTO = data.comentario
      end
      table = table + [[ {:content=>"Total",:colspan=>3, :align=>:left}, debe.round(2), haber.round(2) ]]
      table = table + [[ {:content=>"Concepto: ["+@@CONCEPTO.to_s+"]",:colspan=>5, :align=>:left} ]]
  	  send_data(genera_partida("Partida contable"+id.to_s, "Fecha de ingreso: ["+@@FTRANX+"]", table, @@FTRANX, ""), :filename => "Partida contable.pdf", :type => "application/pdf")
  	elsif id.to_i > 0 && query == "diario"
  	elsif id.to_i > 0 && query == "mayor"
  	elsif id.to_i > 0 && query == "balance"
  	  redirect_to action: 'index'
  	end 
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
      session[:html] += '</td><td><p align="right">'+monto.to_s+'</p></td><td></td></tr>'
      session[:debe] += monto.to_f
      cantidad = session[:debe]
      cantidad = cantidad.round(2)
      session[:debe] = cantidad
    else
      session[:html] += '</td><td></td><td><p align="right">'+monto.to_s+'</p></td></tr>'
      session[:haber] += monto.to_f
      cantidad = session[:haber]
      cantidad = cantidad.round(2)
      session[:haber] = cantidad
    end
  end
end
