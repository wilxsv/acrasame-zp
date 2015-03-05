class CreateScrDetFacturas < ActiveRecord::Migration
  def change
    create_table :scr_det_facturas do |t|
      t.integer :det_factur_numero
      t.datetime :det_factur_fecha
      t.integer :socio_id
      t.boolean :cancelada
      t.datetime :fecha_cancelada
      t.float :total
      t.date :limite_pago

      t.timestamps
    end
  end
end
