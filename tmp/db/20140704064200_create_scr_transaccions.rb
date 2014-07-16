class CreateScrTransaccions < ActiveRecord::Migration
  def change
    create_table :scr_transaccions do |t|
      t.integer :transaxSecuencia
      t.integer :cuenta_id
      t.float :transaxMonto
      t.boolean :transaxDebeHaber
      t.integer :empleado_id
      t.datetime :transaxRegistro
      t.date :transaxFecha
      t.integer :pcontable_id

      t.timestamps
    end
  end
end
