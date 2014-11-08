class ScrCatRepLegalsController < ApplicationController
  before_action :set_scr_cat_rep_legal, only: [:show, :edit, :update, :destroy]

  # GET /scr_cat_rep_legals
  # GET /scr_cat_rep_legals.json
  def index
    @scr_cat_rep_legals = ScrCatRepLegal.all
  end

  # GET /scr_cat_rep_legals/1
  # GET /scr_cat_rep_legals/1.json
  def show
  end

  # GET /scr_cat_rep_legals/new
  def new
    @scr_cat_rep_legal = ScrCatRepLegal.new
  end

  # GET /scr_cat_rep_legals/1/edit
  def edit
  end

  # POST /scr_cat_rep_legals
  # POST /scr_cat_rep_legals.json
  def create
    @scr_cat_rep_legal = ScrCatRepLegal.new(scr_cat_rep_legal_params)

    respond_to do |format|
      if @scr_cat_rep_legal.save
        format.html { redirect_to @scr_cat_rep_legal, notice: 'Scr cat rep legal was successfully created.' }
        format.json { render :show, status: :created, location: @scr_cat_rep_legal }
      else
        format.html { render :new }
        format.json { render json: @scr_cat_rep_legal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_cat_rep_legals/1
  # PATCH/PUT /scr_cat_rep_legals/1.json
  def update
    respond_to do |format|
      if @scr_cat_rep_legal.update(scr_cat_rep_legal_params)
        format.html { redirect_to @scr_cat_rep_legal, notice: 'Scr cat rep legal was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_cat_rep_legal }
      else
        format.html { render :edit }
        format.json { render json: @scr_cat_rep_legal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_cat_rep_legals/1
  # DELETE /scr_cat_rep_legals/1.json
  def destroy
    @scr_cat_rep_legal.destroy
    respond_to do |format|
      format.html { redirect_to scr_cat_rep_legals_url, notice: 'Scr cat rep legal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_cat_rep_legal
      @scr_cat_rep_legal = ScrCatRepLegal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_cat_rep_legal_params
      params.require(:scr_cat_rep_legal).permit(:catRLegalNombre, :catRLegalDescripcion, :catRLegalRegistro, :catRLegalFirma)
    end
end
