class InformeController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root contador administrador socio"
    acceso
  end
  
  def balance
    session[:roles] = "root contador administrador"
    acceso
   fecha = ScrDetContable.where('"dConActivo" = ? ', 'TRUE')
   @ScrCuentua = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ?', 0, 0).order('"cuentaCodigo"')
  end
  
  def general
    session[:roles] = "root contador administrador"
    acceso
   @ScrGrupo = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?', 0, 0, 4).order('"cuentaCodigo"')
   @ScrRubro = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?', 0, 0, 100).order('"cuentaCodigo"')
   @ScrCuenta = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?',0, 0, 1000).order('"cuentaCodigo"')
   @ScrTodo = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? OR "cuentaCodigo" < ?',0, 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
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
end

class String
  def initial
    self[0,1]
  end
end
