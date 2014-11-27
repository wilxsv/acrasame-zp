class ScrCatActividadsController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_cat_actividad, only: [:show, :edit, :update, :destroy]

  # GET /scr_cat_actividads
  # GET /scr_cat_actividads.json
  def index
    session[:roles] = "root"
    acceso
    @scr_cat_actividads = ScrCatActividad.all
  end

  # GET /scr_cat_actividads/1
  # GET /scr_cat_actividads/1.json
  def show
  end

  # GET /scr_cat_actividads/new
  def new
    @scr_cat_actividad = ScrCatActividad.new
  end

  # GET /scr_cat_actividads/1/edit
  def edit
  end

  # POST /scr_cat_actividads
  # POST /scr_cat_actividads.json
  def create
    @scr_cat_actividad = ScrCatActividad.new(scr_cat_actividad_params)

    respond_to do |format|
      if @scr_cat_actividad.save
        format.html { redirect_to @scr_cat_actividad, notice: 'Categoria creada.' }
        format.json { render :show, status: :created, location: @scr_cat_actividad }
      else
        format.html { render :new }
        format.json { render json: @scr_cat_actividad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cat_actividads/1
  # PATCH/PUT /scr_cat_actividads/1.json
  def update
    respond_to do |format|
      if @scr_cat_actividad.update(scr_cat_actividad_params)
        format.html { redirect_to @scr_cat_actividad, notice: 'Categoria actualizada.' }
        format.json { render :show, status: :ok, location: @scr_cat_actividad }
      else
        format.html { render :edit }
        format.json { render json: @scr_cat_actividad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cat_actividads/1
  # DELETE /scr_cat_actividads/1.json
  def destroy
    @scr_cat_actividad.destroy
    respond_to do |format|
      format.html { redirect_to scr_cat_actividads_url, notice: 'Categoria eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cat_actividad
      @scr_cat_actividad = ScrCatActividad.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cat_actividad_params
      params.require(:scr_cat_actividad).permit(:cActividadNombre, :catActividadDescripcion)
    end
end
