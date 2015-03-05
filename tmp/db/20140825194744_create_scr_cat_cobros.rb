class CreateScrCatCobros < ActiveRecord::Migration
  def change
    create_table :scr_cat_cobros do |t|
      t.string :cCobroNombre
      t.text :cCobroDescripcion

      t.timestamps
    end
  end
end
