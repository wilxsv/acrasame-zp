class ScrUsuarioRol < ActiveRecord::Base
  self.table_name = "scr_usuario_rol"
  
  belongs_to :scr_usuario
  belongs_to :scr_rol
end
