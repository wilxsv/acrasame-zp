class CreateScrRepresentanteLegals < ActiveRecord::Migration
  def change
    create_table :scr_representante_legals do |t|
      t.string :rLegalNombre
      t.string :rLegalApellido
      t.integer :rLegalTelefono
      t.integer :rLegalCelular
      t.text :rLegalDireccion
      t.datetime :rLegalRegistro
      t.integer :cat_rep_legal_id
      t.string :rLegalemail

      t.timestamps
    end
  end
end
