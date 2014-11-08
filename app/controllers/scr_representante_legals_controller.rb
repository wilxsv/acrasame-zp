class ScrRepresentanteLegalsController < ApplicationController
  before_action :set_scr_representante_legal, only: [:show, :edit, :update, :destroy]

  # GET /scr_representante_legals
  # GET /scr_representante_legals.json
  def index
    @scr_representante_legals = ScrRepresentanteLegal.all
  end

  # GET /scr_representante_legals/1
  # GET /scr_representante_legals/1.json
  def show
  end

  # GET /scr_representante_legals/new
  def new
    @scr_representante_legal = ScrRepresentanteLegal.new
  end

  # GET /scr_representante_legals/1/edit
  def edit
  end

  # POST /scr_representante_legals
  # POST /scr_representante_legals.json
  def create
    @scr_representante_legal = ScrRepresentanteLegal.new(scr_representante_legal_params)

    respond_to do |format|
      if @scr_representante_legal.save
        format.html { redirect_to @scr_representante_legal, notice: 'Scr representante legal was successfully created.' }
        format.json { render :show, status: :created, location: @scr_representante_legal }
      else
        format.html { render :new }
        format.json { render json: @scr_representante_legal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_representante_legals/1
  # PATCH/PUT /scr_representante_legals/1.json
  def update
    respond_to do |format|
      if @scr_representante_legal.update(scr_representante_legal_params)
        format.html { redirect_to @scr_representante_legal, notice: 'Scr representante legal was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_representante_legal }
      else
        format.html { render :edit }
        format.json { render json: @scr_representante_legal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_representante_legals/1
  # DELETE /scr_representante_legals/1.json
  def destroy
    @scr_representante_legal.destroy
    respond_to do |format|
      format.html { redirect_to scr_representante_legals_url, notice: 'Scr representante legal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_representante_legal
      @scr_representante_legal = ScrRepresentanteLegal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_representante_legal_params
      params.require(:scr_representante_legal).permit(:rLegalNombre, :rLegalApellido, :rLegalTelefono, :rLegalCelular, :rLegalDireccion, :rLegalRegistro, :cat_rep_legal_id, :rLegalemail)
    end
end
