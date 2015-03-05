class CreateScrAreaTrabajos < ActiveRecord::Migration
  def change
    create_table :scr_area_trabajos do |t|
      t.string :aTrabajoNombre
      t.text :aTrabajoDescripcion
      t.integer :area_trabajo_id
      t.integer :organizacion_id
      t.integer :cargo_id

      t.timestamps
    end
  end
end
