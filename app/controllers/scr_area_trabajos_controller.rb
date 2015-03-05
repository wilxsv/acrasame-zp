class ScrAreaTrabajosController < ApplicationController
  include AccesoHelpers
  
  before_action :set_scr_area_trabajo, only: [:show, :edit, :update, :destroy]

  # GET /scr_area_trabajos
  # GET /scr_area_trabajos.json
  def index
    session[:roles] = "root"
    acceso
    @scr_area_trabajos = ScrAreaTrabajo.all
  end

  # GET /scr_area_trabajos/1
  # GET /scr_area_trabajos/1.json
  def show
  end

  # GET /scr_area_trabajos/new
  def new
    @scr_area_trabajo = ScrAreaTrabajo.new
  end

  # GET /scr_area_trabajos/1/edit
  def edit
  end

  # POST /scr_area_trabajos
  # POST /scr_area_trabajos.json
  def create
    @scr_area_trabajo = ScrAreaTrabajo.new(scr_area_trabajo_params)

    respond_to do |format|
      if @scr_area_trabajo.save
        format.html { redirect_to @scr_area_trabajo, notice: 'Scr area trabajo was successfully created.' }
        format.json { render :show, status: :created, location: @scr_area_trabajo }
      else
        format.html { render :new }
        format.json { render json: @scr_area_trabajo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_area_trabajos/1
  # PATCH/PUT /scr_area_trabajos/1.json
  def update
    respond_to do |format|
      if @scr_area_trabajo.update(scr_area_trabajo_params)
        format.html { redirect_to @scr_area_trabajo, notice: 'Scr area trabajo was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_area_trabajo }
      else
        format.html { render :edit }
        format.json { render json: @scr_area_trabajo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_area_trabajos/1
  # DELETE /scr_area_trabajos/1.json
  def destroy
    @scr_area_trabajo.destroy
    respond_to do |format|
      format.html { redirect_to scr_area_trabajos_url, notice: 'Scr area trabajo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_area_trabajo
      @scr_area_trabajo = ScrAreaTrabajo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_area_trabajo_params
      params.require(:scr_area_trabajo).permit(:aTrabajoNombre, :aTrabajoDescripcion, :area_trabajo_id, :organizacion_id, :cargo_id)
    end
end
