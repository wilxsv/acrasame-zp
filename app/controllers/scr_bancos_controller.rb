class ScrBancosController < ApplicationController
  before_action :set_scr_banco, only: [:show, :edit, :update, :destroy]

  # GET /scr_bancos
  # GET /scr_bancos.json
  def index
    @scr_bancos = ScrBanco.all
  end

  # GET /scr_bancos/1
  # GET /scr_bancos/1.json
  def show
  end

  # GET /scr_bancos/new
  def new
    @scr_banco = ScrBanco.new
  end

  # GET /scr_bancos/1/edit
  def edit
  end

  # POST /scr_bancos
  # POST /scr_bancos.json
  def create
    @scr_banco = ScrBanco.new(scr_banco_params)

    respond_to do |format|
      if @scr_banco.save
        format.html { redirect_to @scr_banco, notice: 'Banco creado.' }
        format.json { render :show, status: :created, location: @scr_banco }
      else
        format.html { render :new }
        format.json { render json: @scr_banco.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_bancos/1
  # PATCH/PUT /scr_bancos/1.json
  def update
    respond_to do |format|
      if @scr_banco.update(scr_banco_params)
        format.html { redirect_to @scr_banco, notice: 'Banco actualizado.' }
        format.json { render :show, status: :ok, location: @scr_banco }
      else
        format.html { render :edit }
        format.json { render json: @scr_banco.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_bancos/1
  # DELETE /scr_bancos/1.json
  def destroy
    @scr_banco.destroy
    respond_to do |format|
      format.html { redirect_to scr_bancos_url, notice: 'Banco eliminado.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_banco
      @scr_banco = ScrBanco.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_banco_params
      params.require(:scr_banco).permit(:banco_nombre)
    end
end
