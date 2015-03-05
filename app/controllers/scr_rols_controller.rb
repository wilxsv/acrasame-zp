class ScrRolsController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_rol, only: [:show, :edit, :update, :destroy]

  # GET /scr_rols
  # GET /scr_rols.json
  def index
    session[:roles] = "root"
    acceso
    @scr_rols = ScrRol.all
  end

  # GET /scr_rols/1
  # GET /scr_rols/1.json
  def show
  end

  # GET /scr_rols/new
  def new
    @scr_rol = ScrRol.new
  end

  # GET /scr_rols/1/edit
  def edit
  end

  # POST /scr_rols
  # POST /scr_rols.json
  def create
    @scr_rol = ScrRol.new(scr_rol_params)

    respond_to do |format|
      if @scr_rol.save
        format.html { redirect_to @scr_rol, notice: 'Rol creado.' }
        format.json { render :show, status: :created, location: @scr_rol }
      else
        format.html { render :new }
        format.json { render json: @scr_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_rols/1
  # PATCH/PUT /scr_rols/1.json
  def update
    respond_to do |format|
      if @scr_rol.update(scr_rol_params)
        format.html { redirect_to @scr_rol, notice: 'Rol Actualizado.' }
        format.json { render :show, status: :ok, location: @scr_rol }
      else
        format.html { render :edit }
        format.json { render json: @scr_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_rols/1
  # DELETE /scr_rols/1.json
  def destroy
    @scr_rol.destroy
    respond_to do |format|
      format.html { redirect_to scr_rols_url, notice: 'Rol eliminado.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_rol
      @scr_rol = ScrRol.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_rol_params
      params.require(:scr_rol).permit(:nombrerol, :detallerol)
    end
end
