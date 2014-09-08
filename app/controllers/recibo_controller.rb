class ReciboController < ApplicationController
  def index
    begin
      @info = nil
      @tmp = nil
      ScrDetFactura.find_by_sql("SELECT * FROM fcn_det_factura()")
      @info = "Los recibos se generaron correctamente!"
    rescue
      @tmp = "Los recibos ya fueron generados"
    end
  end
  
  def lectura
  end
  
  def imprimir
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        send_data pdf.render, filename: 'report.pdf', type: 'application/pdf'
      end
    end
  end
end
