class CreateScrCargos < ActiveRecord::Migration
  def change
    create_table :scr_cargos do |t|
      t.string :cargoNombre
      t.text :cargoDescripcion
      t.float :cargoSalario
      t.integer :cargo_id

      t.timestamps
    end
  end
end
