class ScrCatOrganizacionsController < ApplicationController
  include AccesoHelpers
  skip_before_action :require_login, only: [:index, :create, :show, :edit, :update, :destroy ]
#  force_ssl

#  before_action :set_scr_cat_organizacion, only: [:show, :edit, :update, :destroy]

  # GET /scr_cat_organizacions
  # GET /scr_cat_organizacions.json
  def index
    session[:roles] = "root administrador"
    acceso
    @scr_cat_organizacions = ScrCatOrganizacion.all
  end

  # GET /scr_cat_organizacions/1
  # GET /scr_cat_organizacions/1.json
  def show
  end

  # GET /scr_cat_organizacions/new
  def new
    @scr_cat_organizacion = ScrCatOrganizacion.new
  end

  # GET /scr_cat_organizacions/1/edit
  def edit
  end

  # POST /scr_cat_organizacions
  # POST /scr_cat_organizacions.json
  def create
    @scr_cat_organizacion = ScrCatOrganizacion.new(scr_cat_organizacion_params)

    respond_to do |format|
      if @scr_cat_organizacion.save
        format.html { redirect_to @scr_cat_organizacion, notice: 'Scr cat organizacion was successfully created.' }
        format.json { render :show, status: :created, location: @scr_cat_organizacion }
      else
        format.html { render :new }
        format.json { render json: @scr_cat_organizacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cat_organizacions/1
  # PATCH/PUT /scr_cat_organizacions/1.json
  def update
    respond_to do |format|
      if @scr_cat_organizacion.update(scr_cat_organizacion_params)
        format.html { redirect_to @scr_cat_organizacion, notice: 'Scr cat organizacion was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_cat_organizacion }
      else
        format.html { render :edit }
        format.json { render json: @scr_cat_organizacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cat_organizacions/1
  # DELETE /scr_cat_organizacions/1.json
  def destroy
    @scr_cat_organizacion.destroy
    respond_to do |format|
      format.html { redirect_to scr_cat_organizacions_url, notice: 'Scr cat organizacion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cat_organizacion
      @scr_cat_organizacion = ScrCatOrganizacion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cat_organizacion_params
      params.require(:scr_cat_organizacion).permit(:cOrgNombre, :cOrgDescripcion)
    end
end
