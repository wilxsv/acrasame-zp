class ScrProveedorsController < ApplicationController
  before_action :set_scr_proveedor, only: [:show, :edit, :update, :destroy]

  # GET /scr_proveedors
  # GET /scr_proveedors.json
  def index
    @scr_proveedors = ScrProveedor.all
  end

  # GET /scr_proveedors/1
  # GET /scr_proveedors/1.json
  def show
  end

  # GET /scr_proveedors/new
  def new
    @scr_proveedor = ScrProveedor.new
  end

  # GET /scr_proveedors/1/edit
  def edit
  end

  # POST /scr_proveedors
  # POST /scr_proveedors.json
  def create
    @scr_proveedor = ScrProveedor.new(scr_proveedor_params)

    respond_to do |format|
      if @scr_proveedor.save
        format.html { redirect_to @scr_proveedor, notice: 'Scr proveedor was successfully created.' }
        format.json { render :show, status: :created, location: @scr_proveedor }
      else
        format.html { render :new }
        format.json { render json: @scr_proveedor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_proveedors/1
  # PATCH/PUT /scr_proveedors/1.json
  def update
    respond_to do |format|
      if @scr_proveedor.update(scr_proveedor_params)
        format.html { redirect_to @scr_proveedor, notice: 'Scr proveedor was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_proveedor }
      else
        format.html { render :edit }
        format.json { render json: @scr_proveedor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_proveedors/1
  # DELETE /scr_proveedors/1.json
  def destroy
    @scr_proveedor.destroy
    respond_to do |format|
      format.html { redirect_to scr_proveedors_url, notice: 'Scr proveedor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_proveedor
      @scr_proveedor = ScrProveedor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_proveedor_params
      params.require(:scr_proveedor).permit(:proveedorNombre, :proveedorDescripcion)
    end
end
