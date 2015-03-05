class ScrTransaccionsController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_transaccion, only: [:show, :edit, :update, :destroy]

  # GET /scr_transaccions
  # GET /scr_transaccions.json
  def index
    session[:roles] = "root"
    acceso
    @scr_transaccions = ScrTransaccion.all
  end

  # GET /scr_transaccions/1
  # GET /scr_transaccions/1.json
  def show
  end

  # GET /scr_transaccions/new
  def new
    @scr_transaccion = ScrTransaccion.new
  end

  # GET /scr_transaccions/1/edit
  def edit
  end

  # POST /scr_transaccions
  # POST /scr_transaccions.json
  def create
    @scr_transaccion = ScrTransaccion.new(scr_transaccion_params)

    respond_to do |format|
      if @scr_transaccion.save
        format.html { redirect_to @scr_transaccion, notice: 'Scr transaccion was successfully created.' }
        format.json { render :show, status: :created, location: @scr_transaccion }
      else
        format.html { render :new }
        format.json { render json: @scr_transaccion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_transaccions/1
  # PATCH/PUT /scr_transaccions/1.json
  def update
    respond_to do |format|
      if @scr_transaccion.update(scr_transaccion_params)
        format.html { redirect_to @scr_transaccion, notice: 'Scr transaccion was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_transaccion }
      else
        format.html { render :edit }
        format.json { render json: @scr_transaccion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_transaccions/1
  # DELETE /scr_transaccions/1.json
  def destroy
    @scr_transaccion.destroy
    respond_to do |format|
      format.html { redirect_to scr_transaccions_url, notice: 'Scr transaccion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_transaccion
      @scr_transaccion = ScrTransaccion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_transaccion_params
      params.require(:scr_transaccion).permit(:transaxSecuencia, :cuenta_id, :transaxMonto, :transaxDebeHaber, :empleado_id, :transaxRegistro, :transaxFecha, :pcontable_id)
    end
end
