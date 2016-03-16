class InformeController < ApplicationController
  include AccesoHelpers
  include InformeHelper
  require 'date'
  
  def index
    session[:roles] = "root contador administrador socio"
    acceso
  end
  
  def balance
   session[:roles] = "root contador administrador"
   acceso
   #fecha = ScrDetContable.where('"dConActivo" = ? ', 'TRUE')
   @ScrCuentua = ScrCuentua.where('("cuentaDebe" + "cuentaHaber" > ?)', 0).order('CAST("cuentaCodigo" AS TEXT)')
   if params.has_key?(:transacx)
     if params['transacx']['transaxFecha'] != nil
       vfecha = params['transacx']['transaxFecha']
       @ScrCuentua = ScrCuentua.parcial(0, 0, vfecha).order('CAST("cuentaCodigo" AS TEXT)')
     end
   end
  end
  
  def general
    session[:roles] = "root contador administrador"
    acceso
   @ScrGrupo = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?', 0, 0, 4).order('"cuentaCodigo"')
   @ScrRubro = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?', 0, 0, 100).order('"cuentaCodigo"')
   @ScrCuenta = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?',0, 0, 1000).order('"cuentaCodigo"')
   @ScrTodo = ScrCuentua.where('CAST("cuentaCodigo" AS TEXT) ~ \'^(1|2|3)\' AND ("cuentaDebe" + "cuentaHaber" > ?) OR "cuentaCodigo" < ?', 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
   @ScrTodas = ScrCuentua.where('("cuentaDebe" + "cuentaHaber" > ?) OR "cuentaCodigo" < ?', 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
  end
  
  def resultados
    session[:roles] = "root contador administrador"
    acceso
   @ing_ventas = ScrCuentua.estadoResultado(1)
   @cos_ventas = ScrCuentua.estadoResultado(2)
   @gas_ventas = ScrCuentua.estadoResultado(3)
   @gas_administracion = ScrCuentua.estadoResultado(4)
   @gas_financieros = ScrCuentua.estadoResultado(5)
   @ing_otros = ScrCuentua.estadoResultado(6)
   @gas_impuestos = ScrCuentua.estadoResultado(7)
   end

  def prefacturacion
    send_data(generate_pdf(), :filename => "Informe de pre-facturación.pdf", :type => "application/pdf")     
  end
  
  def generate_pdf
    require "prawn/measurement_extensions"
    require "prawn/table"

    Prawn::Document.new(:page_size => "LEGAL", :margin => [2.cm,2.cm,1.cm,1.cm], :page_layout => :landscape) do 
      #Body
      time = Time.new
      headers = [" <b>#</b> ", "<b>Localidad</b>", "<b>Socia / Socio</b>", "<b>Cuenta</b>", "<b>Medidor</b>", "<b>Pendiente de pago</b>", "<b>Ultimo Saldo</b>"]
      bounding_box([10, 450], :width => 900) do #, :height => 680  # stroke_bounds
        table = [headers]
        i = 1 #        AND date_part('month', scr_lectura.\"fechaLectura\")  = ? --- FULL OUTER JOIN scr_lectura ON scr_usuario.id = scr_lectura.socio_id
        socio = ScrUsuario.joins('FULL OUTER JOIN scr_localidad ON scr_usuario.localidad_id = scr_localidad.id
						  JOIN scr_det_factura ON scr_det_factura.socio_id = scr_usuario.id').where("
  						  estado_id = ?", 1).select("
	  					  nombreusuario, apellidousuario, scr_usuario.id AS id, contador, localidad_nombre").order("
		  				  localidad_nombre, nombreusuario, apellidousuario").group("
	  					  scr_usuario.id, nombreusuario, apellidousuario, contador, localidad_nombre")
        socio.each do |data|
          mes = time.strftime("%m").to_i
          if mes = 1 then
            mes = 12
          else
            mes = mes - 1 
          end
          read = ScrLectura.where("date_part('month', scr_lectura.\"fechaLectura\")  = ? AND id = ?", mes, data.id).order("\"fechaLectura\"")
          anterior = ""
          read.each do |conta|
            anterior = conta.valorLectura
          end
          nombre = data.nombreusuario+" "+data.apellidousuario
          nombre = nombre.split.map(&:capitalize).join(' ')
          localidad = data.localidad_nombre.split.map(&:capitalize).join(' ')
          table = table + [[ i, localidad, nombre, data.id, data.contador, anterior, "" ]]
          i+=1
        end
        table(table, :header => true, :width  => 900, :cell_style => { :inline_format => true }) do
        end
      end
      repeat :all do
        #Header
        bounding_box [bounds.left, bounds.top], :width  => bounds.width do
          font "Helvetica"
          image Rails.root.to_s+'/public/images/logo.png', :at => [0,0], :scale => 0.4 # :style => [:bold, :italic] }])
          text " ::  Asociación Rural, Agua Salud y Medio Ambiente El Zapote - Platanares ::", :align => :center, :size => 20
          text " Registro de lecturas de consumo de agua.", :align => :center, :size => 20
          text " #{Prawn::Text::NBSP*19} Generado el: "+time.strftime("%Y-%m-%d %H:%M:%S").to_s, :align => :left
          text " #{Prawn::Text::NBSP*19} Técnico: ", :align => :left
          stroke_horizontal_rule
        end
        #Footer
        bounding_box [bounds.left, bounds.bottom + 25], :width  => bounds.width do
          font "Helvetica"
          stroke_horizontal_rule
          move_down(5)
          number_pages "Pagina <page> de un total de <total>", { :align => :right }#:start_count_at => 5, :page_filter => lambda{ |pg| pg != 1 }, :at => [bounds.right - 50, 0], :size => 14}
        end
      end
    end.render
  end
  
  def pdf
  	id = params['transacx']['id']
    fecha = params['transacx']['transaxFecha']
    @@FTRANX = ""
    @@CONCEPTO = ""
    table = "";
    @@FTRANX = ""
  	if id.to_i == 0
  	  saldo = 0
  	  cuenta = ""
  	  id = 0
  	  saldo_a = 0
      saldo_p= 0
      saldo_c = 0
  	  titulo = "Balange General "+fecha
      query = ScrCuentua.where('CAST("cuentaCodigo" AS TEXT) ~ \'^(1|2|3)\' AND ("cuentaDebe" + "cuentaHaber" > ?) OR "cuentaCodigo" < ?', 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
  	  head = ["<b>Cuenta</b>", "<b>Nombre</b>", "<b>Saldo</b>"]
  	  table = [head]
  	  debe = 0
      haber = 0
      nombre = ""
      tsaldo = 0
      query.each do |data|
        monto = 0
        #Totalizadores de saldo en rubro
        if id != data.cuentaCodigo && data.cuentaCodigo < 4
         if id != 0
          nombre = "TOTAL DE "+data.cuentaNombre
          code = ""
          if saldo >= 0
			monto = saldo.round(2)
 		  else
		   monto = "("+saldo.abs+")"
		  end
		 end
		 id = data.cuentaCodigo
		 saldo = 0
		 nombre = data.cuentaNombre
		else
		 data.cuentaCodigo > 999 ? saldo += data.cuentaDebe.round(2) - data.cuentaHaber.round(2) : saldo += 0
		end
		number = data.cuentaCodigo.to_s
        number = number.initial
        case number.to_i
         when 1
          (data.cuentaCodigo > 999 ? saldo_a += data.cuentaDebe - data.cuentaHaber : saldo_a += 0)
         when 2
          (data.cuentaCodigo > 999 ? saldo_p += data.cuentaHaber - data.cuentaDebe : saldo_p += 0)
         when 3
          (data.cuentaCodigo > 999 ? saldo_c += data.cuentaHaber - data.cuentaDebe : saldo_c += 0)
         else
        end
         if number.to_i > 3
         elsif data.cuentaCodigo < 4
           code = data.cuentaCodigo
           nombre = "<b>"+data.cuentaNombre+"</b>"
         elsif data.cuentaCodigo < 100
           code = data.cuentaCodigo
           nombre = "<b>"+data.cuentaNombre+"</b>"
           if data.cuentaDebe - data.cuentaHaber >= 0
             saldo = data.cuentaDebe - data.cuentaHaber
           else
             saldo = (data.cuentaHaber - data.cuentaDebe).round(2)
           end
         else
           code = data.cuentaCodigo
           nombre = data.cuentaNombre
           if data.cuentaDebe - data.cuentaHaber >= 0
             saldo = data.cuentaDebe - data.cuentaHaber
           else
             saldo = (data.cuentaHaber - data.cuentaDebe).round(2)
           end
         end
     
        table = table + [[ data.cuentaCodigo, nombre, saldo ]]
        @@FTRANX = ""
        @@CONCEPTO = ""
      end
      #table = table + [[ {:content=>"Total",:colspan=>2, :align=>:left}, debe.round(2), haber.round(2), "" ]]
      table = table + [[ {:content=>"Concepto: ["+@@CONCEPTO.to_s+"]",:colspan=>3, :align=>:left} ]]
  	else
  	  titulo = "Estado de resultados "+fecha
  	  head = ["<b>Cuenta</b>", "<b>Nombre</b>", "<b>Saldo</b>"]
  	  table = [head]
  	  table = table + [[ {:content=>"<strong>Ingreso por Ventas (+)</strong>",:colspan=>3, :align=>:left},  ]]
  	  saldo_a = 0
  	  ing_ventas = ScrCuentua.estadoResultado(1)
  	  cos_ventas = ScrCuentua.estadoResultado(2)
  	  gas_ventas = ScrCuentua.estadoResultado(3)
  	  gas_administracion = ScrCuentua.estadoResultado(4)
  	  gas_financieros = ScrCuentua.estadoResultado(5)
  	  ing_otros = ScrCuentua.estadoResultado(6)
  	  gas_impuestos = ScrCuentua.estadoResultado(7)
      ing_ventas.each do |d|
       saldo_a += d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Costo de la mercadería vendida o de los servicios prestados (-)</strong>",:colspan=>3, :align=>:left},  ]]
      cos_ventas.each do |c|
       saldo_a -= d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Utilidad bruta</strong>",:colspan=>2, :align=>:right}, "<b>"+saldo_a.to_s+"</b>" ]]
      table = table + [[ {:content=>"<strong>Gastos de venta (-)</strong>",:colspan=>3, :align=>:left},  ]]
      gas_ventas.each do |c|
       saldo_a -= d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Gastos de administración (-)</strong>",:colspan=>3, :align=>:left},  ]]
      gas_administracion.each do |c|
       saldo_a -= d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Utilidad operativa</strong>",:colspan=>2, :align=>:right}, "<b>"+saldo_a.to_s+"</b>" ]]
      table = table + [[ {:content=>"<strong>Gastos financieros (-)</strong>",:colspan=>3, :align=>:left},  ]]
      gas_financieros.each do |c|
       saldo_a -= d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Utilidad antes de impuestos</strong>",:colspan=>2, :align=>:right}, "<b>"+saldo_a.to_s+"</b>" ]]
      table = table + [[ {:content=>"<strong>Ingreso por productos financieros / Otros ingresos (+)</strong>",:colspan=>3, :align=>:left},  ]]
      ing_otros.each do |d|
       saldo_a += d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Impuesto a las ganancias (+)</strong>",:colspan=>3, :align=>:left},  ]]
      gas_impuestos.each do |d|
       saldo_a -= d.total
       table = table + [[ d.cuentaCodigo, d.cuentaNombre, d.total.round(2) ]]
      end
      table = table + [[ {:content=>"<strong>Ganancia neta / Utilidad final del ejercicio</strong>",:colspan=>2, :align=>:right}, "<b>"+saldo_a.to_s+"</b>" ]]
  	end
  	send_data(genera_partida(titulo, "", table, "", ""), :filename => titulo+".pdf", :type => "application/pdf")
  end
end

class String
  def initial
    self[0,1]
  end
end
