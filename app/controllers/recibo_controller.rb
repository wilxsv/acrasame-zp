
class ReciboController < ApplicationController
  include AccesoHelpers
  
  @@contador = ""
  @@cuenta = ""
  @@socio = 0
  @@lectura_i = ""
  @@lectura_f = ""
  @@fecha = ""
  @@nombre = ""
  @@direccion = ""
  @@msg = ""
  
  X_1 = 0
  Y_1 = 0
  X_2 = 0
  Y_2 = 0
  def index
    session[:roles] = "contador administrador"
    acceso
  end
  
  def lectura
    session[:roles] = "contador"
    acceso
    send_data(generate_pdf(2,3), :filename => "output.pdf", :type => "application/pdf") 
  end  

  def imprimir
    session[:roles] = "contador"
    acceso
    if params.has_key?(:transacx)
      mes = params['transacx']['mes']
      id  = params['transacx']['id'].to_i
      actual  = params['transacx']['actual'].to_i
      if mes != nil
        session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Opcion no habilitada</div>'
        redirect_to action: 'index'
      elsif id >= 1 
        session[:error] = '<div class="alert alert-success"><strong>Error! </strong> Opcion no habilitada</div>'
        send_data(comprobante(id), :filename => "single invoice.pdf", :type => "application/pdf")
      elsif actual != nil
        session[:error] = '<div class="alert alert-success"><strong>Error! </strong> Archivo generado</div>'
        send_data(comprobante(0), :filename => "single invoice.pdf", :type => "application/pdf")
      end
    else
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
      redirect_to action: 'index'
    end
  end
  
  def genera
    session[:roles] = "contador"
    acceso
    begin
      @info = nil
      @tmp = nil
      @tmp = ScrTransaccion.find_by_sql("SELECT fcn_det_factura AS d FROM fcn_det_factura();")
      session[:error] = '<div class="alert alert-success"><strong>Exito! </strong> Los recibos se generaron correctamente!</div>'
      redirect_to action: 'index'
    rescue ActiveRecord::RecordNotFound
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Recibos ya fueron generados</div>'
      redirect_to action: 'index'
    rescue ActiveRecord::ActiveRecordError
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Recibos ya fueron generados</div>'
      redirect_to action: 'index'
    rescue # StandardError
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Recibos ya fueron generados</div>'
      redirect_to action: 'index'
    rescue Exception
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Recibos ya fueron generados</div>'
      redirect_to action: 'index'
    end
  end
  
  def comprobante(ident)
    require "prawn/measurement_extensions"
    Prawn::Document.new(:page_size => [612.00, 708.00], :margin => [0,0,0,0], :page_layout => :portrait) do #
      i = 1
      letra = 10
      y_axis = -90.mm
      if ident > 0
		query = '"id" = ' + ident.to_s
      else
		query = '"limite_pago" >= now()'
      end
      ScrDetFactura.where(query).each do |fac|
        id = fac.id
        ###################################Set factura
        begin
          tmp = ScrDetFactura.find(id)
          @@cuenta = tmp.socio_id
          user = ScrUsuario.find(tmp.socio_id)
          @@contador = user.contador
          @@nombre = user.nombreusuario+" "+user.apellidousuario
          @@nombre = @@nombre.upcase
          loc = ScrLocalidad.find(user.localidad_id)
          @@direccion = loc.localidad_nombre
        rescue
          session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
        end
        ###################################Set lectura
        begin
          tmp = ScrLectura.where("(date_part('month', now())-date_part('month',\"fechaLectura\")) = 1 AND socio_id = "+@@cuenta.to_s)
          tmp.each do |dato|
            @@lectura_i = dato.valorLectura
          end
          tmp = ScrLectura.where("(date_part('month', now())-date_part('month',\"fechaLectura\")) = 0 AND socio_id = "+@@cuenta.to_s)
          tmp.each do |dato|
            @@lectura_f = dato.valorLectura
            @@fecha = "01 02 2015"#dato.fechaLectura
          end
            @@lectura_f = 15
            @@fecha = "01 10 2015"
        rescue
          session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
          @@lectura_i = ""
          @@lectura_f = ""
          @@fecha = "####-##-##"
        end
        ###################################
        if i % 2 == 0 then
			s_y = 141.mm
		else
			s_y = 0.mm	
			start_new_page	
		end
		##	Imprime	#########################################
			text_box @@nombre, :size => letra, :at=>[9.mm,328.mm-s_y+y_axis]#nombre
			text_box @@direccion, :size => letra, :at=>[9.mm,323.mm-s_y+y_axis]#direccion
			text_box id.to_s, :size => letra, :at=>[77.mm,325.mm-s_y+y_axis]#documento
			text_box @@cuenta.to_s, :size => letra, :at=>[77.mm,316.mm-s_y+y_axis]#contador
			text_box @@contador, :size => letra, :at=>[50.mm,316.mm-s_y+y_axis]#cuenta
			text_box @@lectura_f.to_s, :size => letra, :at=>[9.mm,306.mm-s_y+y_axis]#consumo_f
			text_box @@lectura_i.to_s, :size => letra, :at=>[30.mm,306.mm-s_y+y_axis]#consumo_i
			k = @@lectura_f.to_f - @@lectura_i.to_f
			text_box k.to_s, :size => letra, :at=>[45.mm,306.mm-s_y+y_axis]
			text_box @@fecha.to_s, :size => letra, :at=>[75.mm,306.mm-s_y+y_axis]
			s_x = 96.mm
			text_box @@nombre, :size => letra, :at=>[s_x+9.mm,328.mm-s_y+y_axis]
			text_box @@direccion, :size => letra, :at=>[s_x+9.mm,323.mm-s_y+y_axis]
			text_box id.to_s, :size => letra, :at=>[s_x+77.mm,325.mm-s_y+y_axis]
			text_box @@contador, :size => letra, :at=>[s_x+50.mm,316.mm-s_y+y_axis]
			text_box @@cuenta.to_s, :size => letra, :at=>[s_x+77.mm,316.mm-s_y+y_axis]
			text_box @@lectura_f.to_s, :size => letra, :at=>[s_x+9.mm,306.mm-s_y+y_axis]#consumo_f
			text_box @@lectura_i.to_s, :size => letra, :at=>[s_x+30.mm,306.mm-s_y+y_axis]#consumo_i
			text_box k.to_s, :size => letra, :at=>[s_x+45.mm,30.mm-s_y+y_axis]
			text_box @@fecha.to_s, :size => letra, :at=>[s_x+75.mm,306.mm-s_y+y_axis]
			line = 1
			tmp = ScrConsumo.where("factura_id = "+id.to_s)
			tmp.each do |dato|
				valor = ScrCobro.find(dato.cobro_id)
				total = dato.cantidad * valor.cobroValor
				total = total.round(2)
				if line == 1
					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[9.mm,296.mm-s_y+y_axis]
					text_box valor.cobroNombre.to_s, :size => letra, :at=>[23.mm,296.mm-s_y+y_axis]
					text_box total.to_s, :size => letra, :at=>[80.mm,296.mm+y_axis]
				elsif line == 2
#						text_box valor.cobroCodigo.to_s, :size => letra, :at=>[0.mm,395.mm-s_y+y_axis]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[13.mm,395.mm-s_y+y_axis]
#					text_box total.to_s, :size => letra, :at=>[80.mm,395.mm-s_y+y_axis]
				elsif line == 3
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[0.mm,480.mm-s_y+y_axis]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[13.mm,480.mm-s_y]
#					text_box total.to_s, :size => letra, :at=>[80.mm,480.mm-s_y]
				elsif line == 4
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[0.mm,570.mm-s_y]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[13.mm,570.mm-s_y]
#					text_box total.to_s, :size => letra, :at=>[80.mm,570.mm-s_y]
				elsif line == 5
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[0.mm,660.mm-s_y]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[13.mm,660.mm-s_y]
#					text_box total.to_s, :size => letra, :at=>[80.mm,660.mm-s_y]
				end
				line = line + 1
			end
			line = 1
			tmp.each do |dato|
				valor = ScrCobro.find(dato.cobro_id)
				total = dato.cantidad * valor.cobroValor
				total = total.round(2)
				if line == 1
					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[s_x+9.mm,296.mm-s_y+y_axis]
					text_box valor.cobroNombre.to_s, :size => letra, :at=>[s_x+23.mm,296.mm-s_y+y_axis]
					text_box total.to_s, :size => letra, :at=>[s_x+80.mm,296.mm-s_y+y_axis]
					text_box total.to_s, :size => letra, :at=>[s_x+80.mm,296.mm-s_y+y_axis]
				elsif line == 2
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[s_x+0.mm,395.mm-s_y+y_axis]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[s_x+13.mm,395.mm-s_y+y_axis]
#					text_box total.to_s, :size => letra, :at=>[s_x+80.mm,395.mm-s_y+y_axis]
				elsif line == 3
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[s_x+0.mm,480.mm-s_y]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[s_x+13.mm,480.mm-s_y]
#					text_box total.to_s, :size => letra, :at=>[s_x+80.mm,480.mm-s_y]
				elsif line == 4
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[s_x+0.mm,570.mm-s_y]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[s_x+13.mm,570.mm-s_y]
#					text_box total.to_s, :size => letra, :at=>[s_x+80.mm,570.mm-s_y]
				elsif line == 5
#					text_box valor.cobroCodigo.to_s, :size => letra, :at=>[s_x+0.mm,660.mm-s_y]
#					text_box valor.cobroNombre.to_s, :size => letra, :at=>[s_x+13.mm,660.mm-s_y]
#					text_box total.to_s, :size => letra, :at=>[s_x+80.mm,660.mm-s_y]
				end
				line = line + 1
			end
			valor = ScrDetFactura.find(id)
			total = valor.total
			text_box "$ "+total.to_s, :size => letra, :at=>[80.mm,267.mm-s_y+y_axis]
			text_box "$ "+total.to_s, :size => letra, :at=>[s_x+80.mm,267.mm-s_y+y_axis]
			total = total + 1
			text_box "$ "+total.to_s, :size => letra, :at=>[40.mm,267.mm-s_y+y_axis]
			text_box "$ "+total.to_s, :size => letra, :at=>[s_x+40.mm,267.mm-s_y+y_axis]
			fecha = valor.limite_pago
			text_box fecha.to_s, :size => letra, :at=>[75.mm,258.mm-s_y+y_axis]
			text_box fecha.to_s, :size => letra, :at=>[s_x+75.mm,258.mm-s_y+y_axis]
		##	Imprime	#########################################
		i = i + 1
      end
    end.render
  end
  
#  private 
  def set_factura(id)
    begin
      tmp = ScrDetFactura.find(id)
      @@cuenta = tmp.socio_id
      user = ScrUsuario.find(tmp.socio_id)
      @@contador = user.contador
    rescue
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
    end
  end
  
  def set_lectura()
    begin
      tmp = ScrLectura.where("(date_part('month', now())-date_part('month',\"fechaLectura\")) = 1 AND socio_id = "+@@cuenta.to_s)
      tmp.each do |dato|
        @@lectura_i = dato.valorLectura
      end
      tmp = ScrLectura.where("(date_part('month', now())-date_part('month',\"fechaLectura\")) = 0 AND socio_id = "+@@cuenta.to_s)
      tmp.each do |dato|
        @@lectura_f = dato.valorLectura
        @@fecha = dato.fechaLectura
      end
    rescue
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
      @@lectura_i = ""
      @@lectura_f = ""
      @@fecha = "####-##-##"
    end
  end
end
