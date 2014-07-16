class ScrTransaccion < ActiveRecord::Base
  self.table_name = "scr_transaccion"
  belongs_to :"scr_cuenta"
end
