class ScrEstadosController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_estado, only: [:show, :edit, :update, :destroy]

  # GET /scr_estados
  # GET /scr_estados.json
  def index
    session[:roles] = "root"
    acceso
    @scr_estados = ScrEstado.all
  end

  # GET /scr_estados/1
  # GET /scr_estados/1.json
  def show
  end

  # GET /scr_estados/new
  def new
    @scr_estado = ScrEstado.new
  end

  # GET /scr_estados/1/edit
  def edit
  end

  # POST /scr_estados
  # POST /scr_estados.json
  def create
    @scr_estado = ScrEstado.new(scr_estado_params)

    respond_to do |format|
      if @scr_estado.save
        format.html { redirect_to @scr_estado, notice: 'Estado creado.' }
        format.json { render :show, status: :created, location: @scr_estado }
      else
        format.html { render :new }
        format.json { render json: @scr_estado.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_estados/1
  # PATCH/PUT /scr_estados/1.json
  def update
    respond_to do |format|
      if @scr_estado.update(scr_estado_params)
        format.html { redirect_to @scr_estado, notice: 'Estado actualizado.' }
        format.json { render :show, status: :ok, location: @scr_estado }
      else
        format.html { render :edit }
        format.json { render json: @scr_estado.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_estados/1
  # DELETE /scr_estados/1.json
  def destroy
    @scr_estado.destroy
    respond_to do |format|
      format.html { redirect_to scr_estados_url, notice: 'Estado eliminado.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_estado
      @scr_estado = ScrEstado.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_estado_params
      params.require(:scr_estado).permit(:nombreEstado)
    end
end
