class CreateScrDetContables < ActiveRecord::Migration
  def change
    create_table :scr_det_contables do |t|
      t.date :dConIniPeriodo
      t.date :dConFinPeriodo
      t.boolean :dConActivo
      t.string :dConSimboloMoneda
      t.integer :dConPagoXMes
      t.integer :organizacion_id
      t.integer :empleado_id

      t.timestamps
    end
  end
end
