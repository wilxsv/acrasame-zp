class ScrCatCobrosController < ApplicationController
  before_action :set_scr_cat_cobro, only: [:show, :edit, :update, :destroy]

  # GET /scr_cat_cobros
  # GET /scr_cat_cobros.json
  def index
    @scr_cat_cobros = ScrCatCobro.all
  end

  # GET /scr_cat_cobros/1
  # GET /scr_cat_cobros/1.json
  def show
  end

  # GET /scr_cat_cobros/new
  def new
    @scr_cat_cobro = ScrCatCobro.new
  end

  # GET /scr_cat_cobros/1/edit
  def edit
  end

  # POST /scr_cat_cobros
  # POST /scr_cat_cobros.json
  def create
    @scr_cat_cobro = ScrCatCobro.new(scr_cat_cobro_params)

    respond_to do |format|
      if @scr_cat_cobro.save
        format.html { redirect_to @scr_cat_cobro, notice: 'Scr cat cobro was successfully created.' }
        format.json { render :show, status: :created, location: @scr_cat_cobro }
      else
        format.html { render :new }
        format.json { render json: @scr_cat_cobro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cat_cobros/1
  # PATCH/PUT /scr_cat_cobros/1.json
  def update
    respond_to do |format|
      if @scr_cat_cobro.update(scr_cat_cobro_params)
        format.html { redirect_to @scr_cat_cobro, notice: 'Scr cat cobro was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_cat_cobro }
      else
        format.html { render :edit }
        format.json { render json: @scr_cat_cobro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cat_cobros/1
  # DELETE /scr_cat_cobros/1.json
  def destroy
    @scr_cat_cobro.destroy
    respond_to do |format|
      format.html { redirect_to scr_cat_cobros_url, notice: 'Scr cat cobro was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cat_cobro
      @scr_cat_cobro = ScrCatCobro.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cat_cobro_params
      params.require(:scr_cat_cobro).permit(:cCobroNombre, :cCobroDescripcion)
    end
end
