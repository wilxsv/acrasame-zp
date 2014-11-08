class ScrLectura < ActiveRecord::Base
  self.table_name = "scr_lectura"
  has_and_belongs_to_many :scr_usuario
end
