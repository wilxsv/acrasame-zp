class ScrPeriodoRepresentantesController < ApplicationController
  before_action :set_scr_periodo_representante, only: [:show, :edit, :update, :destroy]

  # GET /scr_periodo_representantes
  # GET /scr_periodo_representantes.json
  def index
    @scr_periodo_representantes = ScrPeriodoRepresentante.all
  end

  # GET /scr_periodo_representantes/1
  # GET /scr_periodo_representantes/1.json
  def show
  end

  # GET /scr_periodo_representantes/new
  def new
    @scr_periodo_representante = ScrPeriodoRepresentante.new
  end

  # GET /scr_periodo_representantes/1/edit
  def edit
  end

  # POST /scr_periodo_representantes
  # POST /scr_periodo_representantes.json
  def create
    @scr_periodo_representante = ScrPeriodoRepresentante.new(scr_periodo_representante_params)

    respond_to do |format|
      if @scr_periodo_representante.save
        format.html { redirect_to @scr_periodo_representante, notice: 'Scr periodo representante was successfully created.' }
        format.json { render :show, status: :created, location: @scr_periodo_representante }
      else
        format.html { render :new }
        format.json { render json: @scr_periodo_representante.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_periodo_representantes/1
  # PATCH/PUT /scr_periodo_representantes/1.json
  def update
    respond_to do |format|
      if @scr_periodo_representante.update(scr_periodo_representante_params)
        format.html { redirect_to @scr_periodo_representante, notice: 'Scr periodo representante was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_periodo_representante }
      else
        format.html { render :edit }
        format.json { render json: @scr_periodo_representante.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_periodo_representantes/1
  # DELETE /scr_periodo_representantes/1.json
  def destroy
    @scr_periodo_representante.destroy
    respond_to do |format|
      format.html { redirect_to scr_periodo_representantes_url, notice: 'Scr periodo representante was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_periodo_representante
      @scr_periodo_representante = ScrPeriodoRepresentante.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_periodo_representante_params
      params.require(:scr_periodo_representante).permit(:organizacion_id, :representante_legal_id, :periodoInicio, :periodoFin)
    end
end
