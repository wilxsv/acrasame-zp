class ScrCloracionsController < ApplicationController
  before_action :set_scr_cloracion, only: [:show, :edit, :update, :destroy]

  # GET /scr_cloracions
  # GET /scr_cloracions.json
  def index
    @scr_cloracions = ScrCloracion.all
  end

  # GET /scr_cloracions/1
  # GET /scr_cloracions/1.json
  def show
  end

  # GET /scr_cloracions/new
  def new
    @scr_cloracion = ScrCloracion.new
  end

  # GET /scr_cloracions/1/edit
  def edit
  end

  # POST /scr_cloracions
  # POST /scr_cloracions.json
  def create
    @scr_cloracion = ScrCloracion.new(scr_cloracion_params)

    respond_to do |format|
      if @scr_cloracion.save
        format.html { redirect_to @scr_cloracion, notice: 'Scr cloracion was successfully created.' }
        format.json { render :show, status: :created, location: @scr_cloracion }
      else
        format.html { render :new }
        format.json { render json: @scr_cloracion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cloracions/1
  # PATCH/PUT /scr_cloracions/1.json
  def update
    respond_to do |format|
      if @scr_cloracion.update(scr_cloracion_params)
        format.html { redirect_to @scr_cloracion, notice: 'Scr cloracion was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_cloracion }
      else
        format.html { render :edit }
        format.json { render json: @scr_cloracion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cloracions/1
  # DELETE /scr_cloracions/1.json
  def destroy
    @scr_cloracion.destroy
    respond_to do |format|
      format.html { redirect_to scr_cloracions_url, notice: 'Scr cloracion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cloracion
      @scr_cloracion = ScrCloracion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cloracion_params
      params.require(:scr_cloracion).permit(:fecha, :hora, :gramos, :localidad_id, :empleado_id, :observacion)
    end
end
