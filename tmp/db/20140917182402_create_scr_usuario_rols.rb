class CreateScrUsuarioRols < ActiveRecord::Migration
  def change
    create_table :scr_usuario_rols do |t|
      t.integer :usuario_id
      t.integer :rol_id

      t.timestamps
    end
  end
end
