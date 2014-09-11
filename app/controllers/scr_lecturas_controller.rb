class ScrLecturasController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_lectura, only: [:show, :edit, :update, :destroy]

  # GET /scr_lecturas
  # GET /scr_lecturas.json
  def index
    session[:roles] = " root Tecnico "
    acceso
    @scr_lecturas = ScrLectura.all.order(fechaLectura: :desc)
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
        format.html { redirect_to @scr_lectura, notice: 'Scr lectura was successfully created.' }
        format.json { render :show, status: :created, location: @scr_lectura }
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
