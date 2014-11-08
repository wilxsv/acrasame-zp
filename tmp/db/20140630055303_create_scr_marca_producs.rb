class CreateScrMarcaProducs < ActiveRecord::Migration
  def change
    create_table :scr_marca_producs do |t|
      t.string :marcaProducNombre
      t.text :marcaProducDescrip

      t.timestamps
    end
  end
end
