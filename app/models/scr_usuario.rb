class ScrUsuario < ActiveRecord::Base
  self.table_name = "scr_usuario"
  has_and_belongs_to_many :scr_lectura
end
