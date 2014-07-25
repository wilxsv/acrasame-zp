class ScrCargo < ActiveRecord::Base
  self.table_name = "scr_cargo"
  belongs_to :"scr_cargo"
end
