class ScrConsumosController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_consumo, only: [:show, :edit, :update, :destroy]

  # GET /scr_consumos
  # GET /scr_consumos.json
  def index
    session[:roles] = "root contador administrador"
    acceso
    @scr_consumos = ScrConsumo.all
  end

  # GET /scr_consumos/1
  # GET /scr_consumos/1.json
  def show
  end

  # GET /scr_consumos/new
  def new
    @scr_consumo = ScrConsumo.new
  end

  # GET /scr_consumos/1/edit
  def edit
  end

  # POST /scr_consumos
  # POST /scr_consumos.json
  def create
    @scr_consumo = ScrConsumo.new(scr_consumo_params)

    respond_to do |format|
      if @scr_consumo.save
        format.html { redirect_to @scr_consumo, notice: 'Scr consumo was successfully created.' }
        format.json { render :show, status: :created, location: @scr_consumo }
      else
        format.html { render :new }
        format.json { render json: @scr_consumo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_consumos/1
  # PATCH/PUT /scr_consumos/1.json
  def update
    respond_to do |format|
      if @scr_consumo.update(scr_consumo_params)
        format.html { redirect_to @scr_consumo, notice: 'Scr consumo was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_consumo }
      else
        format.html { render :edit }
        format.json { render json: @scr_consumo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_consumos/1
  # DELETE /scr_consumos/1.json
  def destroy
    @scr_consumo.destroy
    respond_to do |format|
      format.html { redirect_to scr_consumos_url, notice: 'Scr consumo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_consumo
      @scr_consumo = ScrConsumo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_consumo_params
      params.require(:scr_consumo).permit(:registro, :cantidad, :cobro_id, :factura_id)
    end
end
