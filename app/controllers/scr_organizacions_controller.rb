class ScrOrganizacionsController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_organizacion, only: [:show, :edit, :update, :destroy]

  # GET /scr_organizacions
  # GET /scr_organizacions.json
  def index
    session[:roles] = "root"
    acceso
    @scr_organizacions = ScrOrganizacion.all
  end

  # GET /scr_organizacions/1
  # GET /scr_organizacions/1.json
  def show
  end

  # GET /scr_organizacions/new
  def new
    @scr_organizacion = ScrOrganizacion.new
  end

  # GET /scr_organizacions/1/edit
  def edit
  end

  # POST /scr_organizacions
  # POST /scr_organizacions.json
  def create
    @scr_organizacion = ScrOrganizacion.new(scr_organizacion_params)

    respond_to do |format|
      if @scr_organizacion.save
        format.html { redirect_to @scr_organizacion, notice: 'Organizacion fue creada.' }
        format.json { render :show, status: :created, location: @scr_organizacion }
      else
        format.html { render :new }
        format.json { render json: @scr_organizacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_organizacions/1
  # PATCH/PUT /scr_organizacions/1.json
  def update
    respond_to do |format|
      if @scr_organizacion.update(scr_organizacion_params)
        format.html { redirect_to @scr_organizacion, notice: 'Organizacion fue actualizada.' }
        format.json { render :show, status: :ok, location: @scr_organizacion }
      else
        format.html { render :edit }
        format.json { render json: @scr_organizacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_organizacions/1
  # DELETE /scr_organizacions/1.json
  def destroy
    @scr_organizacion.destroy
    respond_to do |format|
      format.html { redirect_to scr_organizacions_url, notice: "Organización fue eliminada." }
            format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_organizacion
      @scr_organizacion = ScrOrganizacion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_organizacion_params
      params.require(:scr_organizacion).permit(:organizacionNombre, :organizacionDescripcion, :localidad_id)
    end
end
