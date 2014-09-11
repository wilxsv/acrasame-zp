class ScrConsumo < ActiveRecord::Base
  self.table_name = "scr_consumo"
  belongs_to :"scr_cobro"
  belongs_to :"scr_det_factura"
end
