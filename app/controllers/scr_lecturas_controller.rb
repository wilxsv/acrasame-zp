class ScrLecturasController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_lectura, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => :create

  # GET /scr_lecturas
  # GET /scr_lecturas.json
  def index
    session[:roles] = " root Tecnico "
    acceso
    @scr_lecturas = ScrLectura.all.order(fechaLectura: :desc)
    #@users = ScrUsuario.joins('JOIN scr_usuario_rol ON scr_usuario.id = scr_usuario_rol.usuario_id LEFT JOIN scr_lectura ON scr_usuario.id = scr_lectura.socio_id').where("date_part('month',scr_lectura.\"fechaLectura\") = '"+session[:mes].to_s+"")
    @users = ScrUsuario.joins('JOIN scr_usuario_rol ON scr_usuario.id = scr_usuario_rol.usuario_id').where("scr_usuario_rol.rol_id = 1")
    @scr_lectura = ScrLectura.new
    #Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')
    #select * from scr_usuario as u join scr_usuario_rol as rr on u.id = rr.usuario_id join scr_rol as r on rr.rol_id = r.id 
    #select * from a left join b on a.id = b.a_id where b.id isnull
  end

  # GET /scr_lecturas/1
  # GET /scr_lecturas/1.json
  def show
    session[:roles] = " root Tecnico "
    acceso
  end

  # GET /scr_lecturas/new
  def new
    session[:roles] = " root Tecnico "
    acceso
    @scr_lectura = ScrLectura.new
    @scr_empleados = ScrEmpleado.all.order('"empleadoNombre", "empleadoApellido"')
    @scr_usuarios = ScrUsuario.all.order('"nombreusuario", "apellidousuario"')
  end

  # GET /scr_lecturas/1/edit
  def edit
    session[:roles] = " root Tecnico "
    acceso
  end

  # POST /scr_lecturas
  # POST /scr_lecturas.json
  def create
    session[:roles] = " root Tecnico "
    acceso
    @scr_lectura = ScrLectura.new(scr_lectura_params)

    respond_to do |format|
      if @scr_lectura.save
        format.html { redirect_to scr_lecturas_url, notice: 'Scr lectura was successfully created.' }
        format.json { render :index, status: :created, location: @scr_lectura }
      else
        format.html { render :new }
        format.json { render json: @scr_lectura.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_lecturas/1
  # PATCH/PUT /scr_lecturas/1.json
  def update
    session[:roles] = " root Tecnico "
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
    session[:roles] = " root Tecnico "
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
