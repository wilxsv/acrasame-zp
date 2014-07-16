class CreateScrCatOrganizacions < ActiveRecord::Migration
  def change
    create_table :scr_cat_organizacions do |t|
      t.string :cOrgNombre
      t.text :cOrgDescripcion

      t.timestamps
    end
  end
end
