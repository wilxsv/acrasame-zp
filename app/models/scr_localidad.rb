class ScrLocalidad < ActiveRecord::Base
  self.table_name = "scr_localidad"
  belongs_to :"scr_localidad"	
end
