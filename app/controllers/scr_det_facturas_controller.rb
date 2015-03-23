class ScrDetFacturasController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_det_factura, only: [:show, :edit, :update, :destroy]

  # GET /scr_det_facturas
  # GET /scr_det_facturas.json
  def index
    session[:roles] = "contador"
    acceso
    @scr_det_facturas = ScrDetFactura.all.order(id: :asc)
  end

  # GET /scr_det_facturas/1
  # GET /scr_det_facturas/1.json
  def show
  end
  
  def imprimir
    send_data(generate_pdf(), :filename => "Informe_de_lecturas_de_consumo.pdf", :type => "application/pdf") 
  end
  def facturacion
    send_data(generate_pfac(), :filename => "Informe_pre_facturacion.pdf", :type => "application/pdf") 
  end
  
  def generate_pdf()
      require "prawn/measurement_extensions"
      require "prawn/table"

      Prawn::Document.new(:page_size => "LEGAL", :margin => [2.cm,2.cm,1.cm,1.cm], :page_layout => :landscape) do 
        #Body
        time = Time.new
        headers = [" <b>#</b> ", "<b>Localidad</b>", "<b>Socia / Socio</b>", "<b>Cuenta</b>", "<b>Medidor</b>", "<b>Lectura anterior</b>", "<b>Lectura actual</b>"]
        bounding_box([10, 450], :width => 900) do #, :height => 680  # stroke_bounds
          table = [headers]
          i = 1 #        AND date_part('month', scr_lectura.\"fechaLectura\")  = ? --- FULL OUTER JOIN scr_lectura ON scr_usuario.id = scr_lectura.socio_id
          socio = ScrUsuario.joins('FULL OUTER JOIN scr_localidad ON scr_usuario.localidad_id = scr_localidad.id').where("
		  						  estado_id = ?", 1).select("
			  					  nombreusuario, apellidousuario, scr_usuario.id AS id, contador, localidad_nombre").order("
				  				  localidad_nombre, nombreusuario, apellidousuario")
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

  def generate_pfac()
      require "prawn/measurement_extensions"
      require "prawn/table"
# cuenta, medidor, socio, lectua i, f, consumo, cobro, multa, pendiente, otros, a pagar
      Prawn::Document.new(:page_size => "LEGAL", :margin => [10,10,10,10], :page_layout => :landscape) do 
        #Body
        time = Time.new
        headers = [" <b>#</b> ", "<b>Localidad</b>", "<b>Socia / Socio</b>", "<b>Cuenta</b>", "<b>Medidor</b>", "<b>Lectura anterior</b>", "<b>Lectura actual</b>"]
        bounding_box([20, 510], :width => 980) do #, :height => 680  # stroke_bounds
          table = [headers]
          i = 1 #        AND date_part('month', scr_lectura.\"fechaLectura\")  = ? --- FULL OUTER JOIN scr_lectura ON scr_usuario.id = scr_lectura.socio_id
          socio = ScrUsuario.joins('FULL OUTER JOIN scr_localidad ON scr_usuario.localidad_id = scr_localidad.id').where("
		  						  estado_id = ?", 1).select("
			  					  nombreusuario, apellidousuario, scr_usuario.id AS id, contador, localidad_nombre").order("
				  				  localidad_nombre, nombreusuario, apellidousuario")
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
          table(table, :header => true, :width  => 980, :cell_style => { :inline_format => true }) do
          end
        end
        repeat :all do
          #Header
          bounding_box [bounds.left, bounds.top], :width  => bounds.width do
            image Rails.root.to_s+'/public/images/logo.png', :at => [0,0], :scale => 0.4 # :style => [:bold, :italic] }])
            text " ::  Asociación Rural, Agua Salud y Medio Ambiente El Zapote - Platanares ::", :align => :center, :size => 20
            text " Informe de pre facturación.", :align => :center, :size => 20
            text " #{Prawn::Text::NBSP*19} Generado el: "+time.strftime("%Y-%m-%d %H:%M:%S").to_s, :align => :left
            text " #{Prawn::Text::NBSP*19} Técnico: ", :align => :left
            stroke_horizontal_rule
          end
          #Footer
          #bounding_box [bounds.left, bounds.bottom + 25], :width  => bounds.width do
          #  stroke_horizontal_rule
          #  move_down(5)
          #  number_pages "Pagina <page> de un total de <total>",# { :align => :right }
          #  {:start_count_at => 5, :page_filter => lambda{ |pg| pg != 1 }, :at => [bounds.right - 50, 0], :size => 14}
          #end
        end
      end.render
  end

  def pagar
    begin
      ScrDetFactura.find_by_sql("SELECT * FROM fcn_pago_factura( "+params['transacx']['id'].to_s+" );")
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Pago realizado.' }
        format.json { head :no_content }
      end
    rescue
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Pago no efectuado.' }
        format.json { head :no_content }
      end
    end
  end
  
  def cargo
    begin
     @c = ScrConsumo.new()
     @c.cantidad		= params[:transacx][:cantidad]
     @c.cobro_id	    = params[:transacx][:cobro_id]
     @c.factura_id	    = params[:transacx][:factura_id]
     @c.save
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Cargo adicional realizado.' }
        format.json { head :no_content }
      end
    rescue
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Cargo adicional no efectuado.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /scr_det_facturas/new
  def new
    @scr_det_factura = ScrDetFactura.new
  end

  # GET /scr_det_facturas/1/edit
  def edit
  end

  # POST /scr_det_facturas
  # POST /scr_det_facturas.json
  def create
    @scr_det_factura = ScrDetFactura.new(scr_det_factura_params)

    respond_to do |format|
      if @scr_det_factura.save
        format.html { redirect_to @scr_det_factura, notice: 'Scr det factura was successfully created.' }
        format.json { render :show, status: :created, location: @scr_det_factura }
      else
        format.html { render :new }
        format.json { render json: @scr_det_factura.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_det_facturas/1
  # PATCH/PUT /scr_det_facturas/1.json
  def update
    respond_to do |format|
      if @scr_det_factura.update(scr_det_factura_params)
        format.html { redirect_to @scr_det_factura, notice: 'Scr det factura was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_det_factura }
      else
        format.html { render :edit }
        format.json { render json: @scr_det_factura.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_det_facturas/1
  # DELETE /scr_det_facturas/1.json
  def destroy
    @scr_det_factura.destroy
    respond_to do |format|
      format.html { redirect_to scr_det_facturas_url, notice: 'Scr det factura was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_det_factura
      @scr_det_factura = ScrDetFactura.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_det_factura_params
      params.require(:scr_det_factura).permit(:det_factur_numero, :det_factur_fecha, :socio_id, :cancelada, :fecha_cancelada, :total, :limite_pago)
    end
end
