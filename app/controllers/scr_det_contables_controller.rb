class ScrDetContablesController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_det_contable, only: [:show, :edit, :update, :destroy]

  # GET /scr_det_contables
  # GET /scr_det_contables.json
  def index
    session[:roles] = "root contador administrador"
    acceso
    @scr_det_contables = ScrDetContable.all
  end

  # GET /scr_det_contables/1
  # GET /scr_det_contables/1.json
  def show
  end

  # GET /scr_det_contables/new
  def new
    @scr_det_contable = ScrDetContable.new
  end

  # GET /scr_det_contables/1/edit
  def edit
  end

  # POST /scr_det_contables
  # POST /scr_det_contables.json
  def create
    @scr_det_contable = ScrDetContable.new(scr_det_contable_params)

    respond_to do |format|
      if @scr_det_contable.save
        format.html { redirect_to @scr_det_contable, notice: 'Scr det contable was successfully created.' }
        format.json { render :show, status: :created, location: @scr_det_contable }
      else
        format.html { render :new }
        format.json { render json: @scr_det_contable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_det_contables/1
  # PATCH/PUT /scr_det_contables/1.json
  def update
    respond_to do |format|
      if @scr_det_contable.update(scr_det_contable_params)
        format.html { redirect_to @scr_det_contable, notice: 'Scr det contable was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_det_contable }
      else
        format.html { render :edit }
        format.json { render json: @scr_det_contable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_det_contables/1
  # DELETE /scr_det_contables/1.json
  def destroy
    @scr_det_contable.destroy
    respond_to do |format|
      format.html { redirect_to scr_det_contables_url, notice: 'Scr det contable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_det_contable
      @scr_det_contable = ScrDetContable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_det_contable_params
      params.require(:scr_det_contable).permit(:dConIniPeriodo, :dConFinPeriodo, :dConActivo, :dConSimboloMoneda, :dConPagoXMes, :organizacion_id, :empleado_id)
    end
end
