class ScrLecturasController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_lectura, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => :create

  # GET /scr_lecturas
  # GET /scr_lecturas.json
  def index
    session[:roles] = "tecnico"
    acceso
    @scr_lecturas = ScrLectura.all.order(fechaLectura: :desc)
    #@users = ScrUsuario.joins('JOIN scr_usuario_rol ON scr_usuario.id = scr_usuario_rol.usuario_id LEFT JOIN scr_lectura ON scr_usuario.id = scr_lectura.socio_id').where("date_part('month',scr_lectura.\"fechaLectura\") = '"+session[:mes].to_s+"")
    @users = ScrUsuario.joins('JOIN scr_usuario_rol ON scr_usuario.id = scr_usuario_rol.usuario_id').where("scr_usuario_rol.rol_id = 1")
    @scr_lectura = ScrLectura.new
    #Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')
    #select * from scr_usuario as u join scr_usuario_rol as rr on u.id = rr.usuario_id join scr_rol as r on rr.rol_id = r.id 
    #select * from a left join b on a.id = b.a_id where b.id isnull
  end
  
  def registro
    send_data(generate_pdf(), :filename => "registro de lectura.pdf", :type => "application/pdf")     
  end

  # GET /scr_lecturas/1
  # GET /scr_lecturas/1.json
  def show
    session[:roles] = " root tecnico "
    acceso
  end

  # GET /scr_lecturas/new
  def new
    session[:roles] = " root tecnico "
    acceso
    @scr_lectura = ScrLectura.new
    @scr_empleados = ScrEmpleado.all.order('"empleadoNombre", "empleadoApellido"')
    @scr_usuarios = ScrUsuario.all.order('"nombreusuario", "apellidousuario"')
  end

  # GET /scr_lecturas/1/edit
  def edit
    session[:roles] = " root tecnico "
    acceso
  end

  # POST /scr_lecturas
  # POST /scr_lecturas.json
  def create
    session[:roles] = " root tecnico "
    acceso
    @scr_lectura = ScrLectura.new(scr_lectura_params)
    
    if @scr_lectura.save
		redirect_to scr_lecturas_path
    else
		redirect_to scr_lecturas_new
    end
    
    #respond_to do |format|
    #  if @scr_lectura.save
    #    format.html { redirect_to scr_lecturas_path, notice: 'Scr lectura was successfully created.' }
    #    format.json { render :index, status: :created, location: @scr_lectura }
    #  else
    #    format.html { render :new }
    #    format.json { render json: @scr_lectura.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PATCH/PUT /scr_lecturas/1
  # PATCH/PUT /scr_lecturas/1.json
  def update
    session[:roles] = " root tecnico "
    acceso
    respond_to do |format|
      if @scr_lectura.update(scr_lectura_params)
        format.html { redirect_to @scr_lectura, notice: 'Scr lectura was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_lectura }
      else
        format.html { render :edit }
        format.json { render json: @scr_lectura.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_lecturas/1
  # DELETE /scr_lecturas/1.json
  def destroy
    session[:roles] = " root tecnico "
    acceso
    @scr_lectura.destroy
    respond_to do |format|
      format.html { redirect_to scr_lecturas_url, notice: 'Scr lectura was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def set
    if params.has_key?(:transacx)
     mes = params['transacx']['mes']
     tecnico = params['transacx']['tecnico']
     begin
       Date.parse(mes)
       session[:mes] = mes
       session[:tecnico] = tecnico
     rescue ArgumentError
       session[:mes] = nil
       session[:tecnico] = nil
     end
    end
    redirect_to scr_lecturas_url
  end

    def generate_pdf
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
    
    def get_lectura(id)
      returning lectura_contador
      lectura_contador = id
    end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_lectura
      @scr_lectura = ScrLectura.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_lectura_params
      params.require(:scr_lectura).permit(:valorLectura, :fechaLectura, :registroLectura, :socio_id, :tecnico_id)
    end
end
