class CreateScrBombeos < ActiveRecord::Migration
  def change
    create_table :scr_bombeos do |t|
      t.date :fecha
      t.datetime :bombeo_inicio
      t.datetime :bombeo_fin
      t.float :voltaje
      t.float :amperaje
      t.float :presion
      t.float :lectura
      t.float :produccion
      t.integer :empleado_id

      t.timestamps
    end
  end
end
