class CreateScrCloracions < ActiveRecord::Migration
  def change
    create_table :scr_cloracions do |t|
      t.date :fecha
      t.time :hora
      t.float :gramos
      t.integer :localidad_id
      t.integer :empleado_id
      t.text :observacion

      t.timestamps
    end
  end
end
