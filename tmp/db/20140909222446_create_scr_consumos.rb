class CreateScrConsumos < ActiveRecord::Migration
  def change
    create_table :scr_consumos do |t|
      t.datetime :registro
      t.integer :cantidad
      t.integer :cobro_id
      t.integer :factura_id

      t.timestamps
    end
  end
end
