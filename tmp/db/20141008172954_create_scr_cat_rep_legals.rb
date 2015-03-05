class CreateScrCatRepLegals < ActiveRecord::Migration
  def change
    create_table :scr_cat_rep_legals do |t|
      t.string :catRLegalNombre
      t.text :catRLegalDescripcion
      t.datetime :catRLegalRegistro
      t.boolean :catRLegalFirma

      t.timestamps
    end
  end
end
