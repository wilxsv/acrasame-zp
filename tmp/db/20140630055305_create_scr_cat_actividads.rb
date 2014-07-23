class CreateScrCatActividads < ActiveRecord::Migration
  def change
    create_table :scr_cat_actividads do |t|
      t.string :cActividadNombre
      t.text :catActividadDescripcion

      t.timestamps
    end
  end
end
