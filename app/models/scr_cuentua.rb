class ScrCuentua < ActiveRecord::Base
  self.table_name = "scr_cuenta"
  belongs_to :"scr_cuenta"
end
