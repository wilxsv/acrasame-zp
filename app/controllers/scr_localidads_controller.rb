class ScrLocalidadsController < ApplicationController
  before_action :set_scr_localidad, only: [:show, :edit, :update, :destroy]

  # GET /scr_localidads
  # GET /scr_localidads.json
  def index
    @scr_localidads = ScrLocalidad.all
  end

  # GET /scr_localidads/1
  # GET /scr_localidads/1.json
  def show
  end

  # GET /scr_localidads/new
  def new
    @scr_localidad = ScrLocalidad.new
  end

  # GET /scr_localidads/1/edit
  def edit
  end

  # POST /scr_localidads
  # POST /scr_localidads.json
  def create
    @scr_localidad = ScrLocalidad.new(scr_localidad_params)

    respond_to do |format|
      if @scr_localidad.save
        format.html { redirect_to @scr_localidad, notice: 'Localidad fue creada.' }
        format.json { render :show, status: :created, location: @scr_localidad }
      else
        format.html { render :new }
        format.json { render json: @scr_localidad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_localidads/1
  # PATCH/PUT /scr_localidads/1.json
  def update
    respond_to do |format|
      if @scr_localidad.update(scr_localidad_params)
        format.html { redirect_to @scr_localidad, notice: 'Localidad fue actualizada.' }
        format.json { render :show, status: :ok, location: @scr_localidad }
      else
        format.html { render :edit }
        format.json { render json: @scr_localidad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_localidads/1
  # DELETE /scr_localidads/1.json
  def destroy
    @scr_localidad.destroy
    respond_to do |format|
      format.html { redirect_to scr_localidads_url, notice: 'Localidad fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_localidad
      @scr_localidad = ScrLocalidad.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_localidad_params
      params.require(:scr_localidad).permit(:localidad_nombre, :localidad_descripcion, :localidad_id, :localidad_lat, :localidad_lon)
    end
end
