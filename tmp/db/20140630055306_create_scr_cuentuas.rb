class CreateScrCuentuas < ActiveRecord::Migration
  def change
    create_table :scr_cuentuas do |t|
      t.string :cuentaNombre
      t.datetime :cuentaRegistro
      t.float :cuentaDebe
      t.float :cuentaHaber
      t.integer :cat_cuenta_id
      t.boolean :cuentaActivo
      t.integer :cuentaCodigo
      t.text :cuentaDescripcion
      t.boolean :cuentaNegativa

      t.timestamps
    end
  end
end
