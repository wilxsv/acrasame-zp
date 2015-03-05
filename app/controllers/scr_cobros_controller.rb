class ScrCobrosController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_cobro, only: [:show, :edit, :update, :destroy]

  # GET /scr_cobros
  # GET /scr_cobros.json
  def index
    session[:roles] = "root contador administrador"
    acceso
    @scr_cobros = ScrCobro.all
  end

  # GET /scr_cobros/1
  # GET /scr_cobros/1.json
  def show
  end

  # GET /scr_cobros/new
  def new
    @scr_cobro = ScrCobro.new
  end

  # GET /scr_cobros/1/edit
  def edit
  end

  # POST /scr_cobros
  # POST /scr_cobros.json
  def create
    @scr_cobro = ScrCobro.new(scr_cobro_params)

    respond_to do |format|
      if @scr_cobro.save
        format.html { redirect_to @scr_cobro, notice: 'Scr cobro was successfully created.' }
        format.json { render :show, status: :created, location: @scr_cobro }
      else
        format.html { render :new }
        format.json { render json: @scr_cobro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cobros/1
  # PATCH/PUT /scr_cobros/1.json
  def update
    respond_to do |format|
      if @scr_cobro.update(scr_cobro_params)
        format.html { redirect_to @scr_cobro, notice: 'Scr cobro was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_cobro }
      else
        format.html { render :edit }
        format.json { render json: @scr_cobro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cobros/1
  # DELETE /scr_cobros/1.json
  def destroy
    @scr_cobro.destroy
    respond_to do |format|
      format.html { redirect_to scr_cobros_url, notice: 'Scr cobro was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cobro
      @scr_cobro = ScrCobro.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cobro_params
      params.require(:scr_cobro).permit(:cobroNombre, :cobroCodigo, :cobroDescripcion, :cobroInicio, :cobroFin, :cobroValor, :cobroPermanente, :cat_cobro_id)
    end
end
