class CreateScrLocalidads < ActiveRecord::Migration
  def change
    create_table :scr_localidads do |t|
      t.string :localidad_nombre
      t.text :localidad_descripcion
      t.integer :localidad_id
      t.float :localidad_lat
      t.float :localidad_lon

      t.timestamps
    end
  end
end
