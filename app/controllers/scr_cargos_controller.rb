class ScrCargosController < ApplicationController
  before_action :set_scr_cargo, only: [:show, :edit, :update, :destroy]

  # GET /scr_cargos
  # GET /scr_cargos.json
  def index
    @scr_cargos = ScrCargo.all
  end

  # GET /scr_cargos/1
  # GET /scr_cargos/1.json
  def show
  end

  # GET /scr_cargos/new
  def new
    @scr_cargo = ScrCargo.new
  end

  # GET /scr_cargos/1/edit
  def edit
  end

  # POST /scr_cargos
  # POST /scr_cargos.json
  def create
    @scr_cargo = ScrCargo.new(scr_cargo_params)

    respond_to do |format|
      if @scr_cargo.save
        format.html { redirect_to @scr_cargo, notice: 'Cargo creado.' }
        format.json { render :show, status: :created, location: @scr_cargo }
      else
        format.html { render :new }
        format.json { render json: @scr_cargo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cargos/1
  # PATCH/PUT /scr_cargos/1.json
  def update
    respond_to do |format|
      if @scr_cargo.update(scr_cargo_params)
        format.html { redirect_to @scr_cargo, notice: 'Cargo actualizado.' }
        format.json { render :show, status: :ok, location: @scr_cargo }
      else
        format.html { render :edit }
        format.json { render json: @scr_cargo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cargos/1
  # DELETE /scr_cargos/1.json
  def destroy
    @scr_cargo.destroy
    respond_to do |format|
      format.html { redirect_to scr_cargos_url, notice: 'Cargo eliminado.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cargo
      @scr_cargo = ScrCargo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cargo_params
      params.require(:scr_cargo).permit(:cargoNombre, :cargoDescripcion, :cargoSalario, :cargo_id)
    end
end
