class ScrUsuarioRolsController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_usuario_rol, only: [:show, :edit, :update, :destroy]
 # before_action :acceso, only: [:show, :new, :create, :index, :edit, :update, :destroy]
  
  include AccesoHelpers

  # GET /scr_usuario_rols
  # GET /scr_usuario_rols.json
  def index
    session[:roles] = " root "
    @scr_usuario_rols = ScrUsuarioRol.all
  end

  # GET /scr_usuario_rols/1
  # GET /scr_usuario_rols/1.json
  def show
    session[:roles] = " root "
  end

  # GET /scr_usuario_rols/new
  def new
    session[:roles] = " root "
    @scr_usuario_rol = ScrUsuarioRol.new
  end

  # GET /scr_usuario_rols/1/edit
  def edit
    session[:roles] = " root "
  end

  # POST /scr_usuario_rols
  # POST /scr_usuario_rols.json
  def create
    session[:roles] = " root "
    acceso
    @scr_usuario_rol = ScrUsuarioRol.new(scr_usuario_rol_params)

    respond_to do |format|
      if @scr_usuario_rol.save
        format.html { redirect_to @scr_usuario_rol, notice: 'Scr usuario rol was successfully created.' }
        format.json { render :show, status: :created, location: @scr_usuario_rol }
      else
        format.html { render :new }
        format.json { render json: @scr_usuario_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_usuario_rols/1
  # PATCH/PUT /scr_usuario_rols/1.json
  def update
    session[:roles] = " root "
    acceso
    respond_to do |format|
      if @scr_usuario_rol.update(scr_usuario_rol_params)
        format.html { redirect_to @scr_usuario_rol, notice: 'Scr usuario rol was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_usuario_rol }
      else
        format.html { render :edit }
        format.json { render json: @scr_usuario_rol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_usuario_rols/1
  # DELETE /scr_usuario_rols/1.json
  def destroy
    session[:roles] = " root "
    acceso
    @scr_usuario_rol.destroy
    respond_to do |format|
      format.html { redirect_to scr_usuario_rols_url, notice: 'Scr usuario rol was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_usuario_rol
      @scr_usuario_rol = ScrUsuarioRol.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_usuario_rol_params
      params.require(:scr_usuario_rol).permit(:usuario_id, :rol_id)
    end
end
