class ScrDetFacturasController < ApplicationController
  before_action :set_scr_det_factura, only: [:show, :edit, :update, :destroy]

  # GET /scr_det_facturas
  # GET /scr_det_facturas.json
  def index
    @scr_det_facturas = ScrDetFactura.all.order(id: :asc)
  end

  # GET /scr_det_facturas/1
  # GET /scr_det_facturas/1.json
  def show
  end

  def pagar
  require "prawn"
  Prawn::Document.generate("public/files/last.pdf") do
   text "Hello World!"
  end
    begin
      ScrDetFactura.find_by_sql("SELECT * FROM fcn_pago_factura( "+params['transacx']['id'].to_s+" );")
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Pago realizado.' }
        format.json { head :no_content }
      end
    rescue
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Pago no efectuado.' }
        format.json { head :no_content }
      end
    end
  end
  
  def cargo
    begin
     @c = ScrConsumo.new()
     @c.cantidad		= params[:transacx][:cantidad]
     @c.cobro_id	    = params[:transacx][:cobro_id]
     @c.factura_id	    = params[:transacx][:factura_id]
     @c.save
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Cargo adicional realizado.' }
        format.json { head :no_content }
      end
    rescue
      respond_to do |format|
        format.html { redirect_to scr_det_facturas_url, notice: 'Cargo adicional no efectuado.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /scr_det_facturas/new
  def new
    @scr_det_factura = ScrDetFactura.new
  end

  # GET /scr_det_facturas/1/edit
  def edit
  end

  # POST /scr_det_facturas
  # POST /scr_det_facturas.json
  def create
    @scr_det_factura = ScrDetFactura.new(scr_det_factura_params)

    respond_to do |format|
      if @scr_det_factura.save
        format.html { redirect_to @scr_det_factura, notice: 'Scr det factura was successfully created.' }
        format.json { render :show, status: :created, location: @scr_det_factura }
      else
        format.html { render :new }
        format.json { render json: @scr_det_factura.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_det_facturas/1
  # PATCH/PUT /scr_det_facturas/1.json
  def update
    respond_to do |format|
      if @scr_det_factura.update(scr_det_factura_params)
        format.html { redirect_to @scr_det_factura, notice: 'Scr det factura was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_det_factura }
      else
        format.html { render :edit }
        format.json { render json: @scr_det_factura.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_det_facturas/1
  # DELETE /scr_det_facturas/1.json
  def destroy
    @scr_det_factura.destroy
    respond_to do |format|
      format.html { redirect_to scr_det_facturas_url, notice: 'Scr det factura was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_det_factura
      @scr_det_factura = ScrDetFactura.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_det_factura_params
      params.require(:scr_det_factura).permit(:det_factur_numero, :det_factur_fecha, :socio_id, :cancelada, :fecha_cancelada, :total, :limite_pago)
    end
end
