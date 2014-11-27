class ScrCuentuasController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_cuentua, only: [:show, :edit, :update, :destroy]

  # GET /scr_cuentuas
  # GET /scr_cuentuas.json
  def index
    session[:roles] = "root contador administrador"
    acceso
    @scr_cuentuas = ScrCuentua.all.order('CAST("cuentaCodigo" AS TEXT)')
  end

  # GET /scr_cuentuas/1
  # GET /scr_cuentuas/1.json
  def show
  end

  # GET /scr_cuentuas/new
  def new
    @scr_cuentua = ScrCuentua.new
  end

  # GET /scr_cuentuas/1/edit
  def edit
  end

  # POST /scr_cuentuas
  # POST /scr_cuentuas.json
  def create
    @scr_cuentua = ScrCuentua.new(scr_cuentua_params)

    respond_to do |format|
      if @scr_cuentua.save
        format.html { redirect_to @scr_cuentua, notice: 'Cuenta creada.' }
        format.json { render :show, status: :created, location: @scr_cuentua }
      else
        format.html { render :new }
        format.json { render json: @scr_cuentua.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cuentuas/1
  # PATCH/PUT /scr_cuentuas/1.json
  def update
    respond_to do |format|
      if @scr_cuentua.update(scr_cuentua_params)
        format.html { redirect_to @scr_cuentua, notice: 'Cuenta actualizada.' }
        format.json { render :show, status: :ok, location: @scr_cuentua }
      else
        format.html { render :edit }
        format.json { render json: @scr_cuentua.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cuentuas/1
  # DELETE /scr_cuentuas/1.json
  def destroy
    @scr_cuentua.destroy
    respond_to do |format|
      format.html { redirect_to scr_cuentuas_url, notice: 'Cuenta Eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cuentua
      @scr_cuentua = ScrCuentua.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cuentua_params
      params.require(:scr_cuentua).permit(:cuentaNombre, :cuentaRegistro, :cuentaDebe, :cuentaHaber, :cat_cuenta_id, :cuentaActivo, :cuentaCodigo, :cuentaDescripcion, :cuentaNegativa)
    end
end
