class ReciboController < ApplicationController
  @@contador = ""
  @@cuenta = ""
  @@socio = 0
  @@lectura_i = ""
  @@lectura_f = ""
  @@fecha = ""
  @@msg = ""
  
  X_1 = 0
  Y_1 = 0
  X_2 = 0
  Y_2 = 0
  def index
  end
  
  def lectura
    send_data(generate_pdf(2,3), :filename => "output.pdf", :type => "application/pdf") 
  end
  
  

def    unico()
    require "prawn"
    Prawn::Document.generate("public/files/last.pdf") do
    font_size 16
    text "We are still on the initial page for this example. Now I'll ask"+"Prawn to gently start a new page. Please follow me to the next page."
    start_new_page
    text "See. We've left the previous page behind."
    text_box "This is a text box, you can control where it will flow by"+"specifying the :height and :width options",
		:at=>[100,250],
		:height=>100,
		:width=>100
	end
 end 
  def imprimir
    if params.has_key?(:transacx)
      mes = params['transacx']['mes']
      id  = params['transacx']['id'].to_i
      if mes != nil
        session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Opcion no habilitada</div>'
        redirect_to action: 'index'
      elsif id >= 1 
        session[:error] = '<div class="alert alert-success"><strong>Error! </strong> Opcion no habilitada</div>'
        send_data(genera_unico(id), :filename => "single invoice.pdf", :type => "application/pdf")
      else
        session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
        redirect_to action: 'index'
      end
    else
      session[:error] = '<div class="alert alert-error"><strong>Error! </strong> Datos no enviados</div>'
      redirect_to action: 'index'
    end
  end
  
  def genera
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
  
  def comprobante
    require "prawn"
    Prawn::Document.generate("public/files/last.pdf") do
    font_size 16
    text "We are still on the initial page for this example. Now I'll ask"+"Prawn to gently start a new page. Please follow me to the next page."
    start_new_page
    text "See. We've left the previous page behind."
    text_box "This is a text box, you can control where it will flow by"+"specifying the :height and :width options",
		:at=>[100,250],
		:height=>100,
		:width=>100
	encrypt_document
    end
  end
  
  private 
  def generate_pdf(id, cuadrante)
    Prawn::Document.new do
        text "Hello ["+id.to_s+"] Stackoverflow ["+cuadrante.to_s+"]"
    end.render 
  end
  def genera_unico(id)
    require "prawn/measurement_extensions"
    set_factura(id)
    set_lectura()    
    # :background => "#{Rails.root.to_s}/public/images/bg_pdf.png",
    Prawn::Document.new(:page_size => "A4", :margin => [0,0,0,0], :page_layout => :portrait) do
      text_box @@contador, :size => 30, :at=>[13.mm,254.mm]
      text_box @@cuenta.to_s, :at=>[74.mm,248.mm]
      text_box @@cuenta.to_s, :at=>[74.mm,238.mm]
      text_box @@lectura_f.to_s, :at=>[13.mm,230.mm]
      text_box @@lectura_i.to_s, :at=>[32.mm,230.mm]
      k = @@lectura_f.to_f - @@lectura_i.to_f
      text_box k.to_s, :at=>[51.mm,230.mm]
      text_box @@fecha.to_s, :at=>[81.mm,230.mm]
      #SELECT SUM(c.cantidad * k."cobroValor") INTO mor FROM scr_consumo AS c, scr_cobro AS k 
      #WHERE c.factura_id = r.id  AND c.cobro_id = k.id GROUP BY factura_id;
      line = 1
      tmp = ScrConsumo.where("factura_id = "+id.to_s)
      tmp.each do |dato|
        valor = ScrCobro.find(dato.cobro_id)
        total = dato.cantidad * valor.cobroValor
        total = total.round(2)
        if line == 1
          text_box valor.cobroCodigo.to_s, :at=>[13.mm,218.mm]
          text_box valor.cobroNombre.to_s, :at=>[27.mm,218.mm]
          text_box total.to_s, :at=>[82.mm,218.mm]
        elsif line == 2
          text_box valor.cobroCodigo.to_s, :at=>[13.mm,208.mm]
          text_box valor.cobroNombre.to_s, :at=>[27.mm,208.mm]
          text_box total.to_s, :at=>[82.mm,208.mm]
        end
        line = line + 1
      end
      valor = ScrDetFactura.find(id)
      total = valor.total
      text_box total.to_s, :at=>[82.mm,191.mm]
      total = total + 1
      text_box total.to_s, :at=>[44.mm,191.mm]
      fecha = valor.limite_pago
      text_box fecha.to_s, :at=>[80.mm,183.mm]
      #text "Hello ["+@@cuenta.to_s+"] Stackoverflow ["+@@contador+"]"+"Cuenta: ["+@@lectura_i.to_s+"] - ["+@@lectura_f.to_s+" ["+@@fecha.to_s+"]"
    end.render
  end
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
