class ScrBombeosController < ApplicationController
  before_action :set_scr_bombeo, only: [:show, :edit, :update, :destroy]

  # GET /scr_bombeos
  # GET /scr_bombeos.json
  def index
    @scr_bombeos = ScrBombeo.all
  end

  # GET /scr_bombeos/1
  # GET /scr_bombeos/1.json
  def show
  end

  # GET /scr_bombeos/new
  def new
    @scr_bombeo = ScrBombeo.new
  end

  # GET /scr_bombeos/1/edit
  def edit
  end

  # POST /scr_bombeos
  # POST /scr_bombeos.json
  def create
    @scr_bombeo = ScrBombeo.new(scr_bombeo_params)

    respond_to do |format|
      if @scr_bombeo.save
        format.html { redirect_to @scr_bombeo, notice: 'Scr bombeo was successfully created.' }
        format.json { render :show, status: :created, location: @scr_bombeo }
      else
        format.html { render :new }
        format.json { render json: @scr_bombeo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_bombeos/1
  # PATCH/PUT /scr_bombeos/1.json
  def update
    respond_to do |format|
      if @scr_bombeo.update(scr_bombeo_params)
        format.html { redirect_to @scr_bombeo, notice: 'Scr bombeo was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_bombeo }
      else
        format.html { render :edit }
        format.json { render json: @scr_bombeo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_bombeos/1
  # DELETE /scr_bombeos/1.json
  def destroy
    @scr_bombeo.destroy
    respond_to do |format|
      format.html { redirect_to scr_bombeos_url, notice: 'Scr bombeo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_bombeo
      @scr_bombeo = ScrBombeo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_bombeo_params
      params.require(:scr_bombeo).permit(:fecha, :bombeo_inicio, :bombeo_fin, :voltaje, :amperaje, :presion, :lectura, :produccion, :empleado_id)
    end
end
