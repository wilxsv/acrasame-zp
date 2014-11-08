class CreateScrCobros < ActiveRecord::Migration
  def change
    create_table :scr_cobros do |t|
      t.string :cobroNombre
      t.string :cobroCodigo
      t.text :cobroDescripcion
      t.date :cobroInicio
      t.date :cobroFin
      t.float :cobroValor
      t.boolean :cobroPermanente
      t.integer :cat_cobro_id

      t.timestamps
    end
  end
end
