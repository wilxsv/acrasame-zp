class CreateScrProveedors < ActiveRecord::Migration
  def change
    create_table :scr_proveedors do |t|
      t.string :proveedorNombre
      t.text :proveedorDescripcion

      t.timestamps
    end
  end
end
