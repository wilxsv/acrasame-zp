class ScrMarcaProducsController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_marca_produc, only: [:show, :edit, :update, :destroy]

  # GET /scr_marca_producs
  # GET /scr_marca_producs.json
  def index
    session[:roles] = "root"
    acceso
    @scr_marca_producs = ScrMarcaProduc.all
  end

  # GET /scr_marca_producs/1
  # GET /scr_marca_producs/1.json
  def show
  end

  # GET /scr_marca_producs/new
  def new
    @scr_marca_produc = ScrMarcaProduc.new
  end

  # GET /scr_marca_producs/1/edit
  def edit
  end

  # POST /scr_marca_producs
  # POST /scr_marca_producs.json
  def create
    @scr_marca_produc = ScrMarcaProduc.new(scr_marca_produc_params)

    respond_to do |format|
      if @scr_marca_produc.save
        format.html { redirect_to @scr_marca_produc, notice: 'Marca de producto creada.' }
        format.json { render :show, status: :created, location: @scr_marca_produc }
      else
        format.html { render :new }
        format.json { render json: @scr_marca_produc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_marca_producs/1
  # PATCH/PUT /scr_marca_producs/1.json
  def update
    respond_to do |format|
      if @scr_marca_produc.update(scr_marca_produc_params)
        format.html { redirect_to @scr_marca_produc, notice: 'Marca de producto actualizada.' }
        format.json { render :show, status: :ok, location: @scr_marca_produc }
      else
        format.html { render :edit }
        format.json { render json: @scr_marca_produc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_marca_producs/1
  # DELETE /scr_marca_producs/1.json
  def destroy
    @scr_marca_produc.destroy
    respond_to do |format|
      format.html { redirect_to scr_marca_producs_url, notice: 'Marca de producto eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_marca_produc
      @scr_marca_produc = ScrMarcaProduc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_marca_produc_params
      params.require(:scr_marca_produc).permit(:marcaProducNombre, :marcaProducDescrip)
    end
end
