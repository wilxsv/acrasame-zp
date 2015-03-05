class CreateScrLecturas < ActiveRecord::Migration
  def change
    create_table :scr_lecturas do |t|
      t.string :valorLectura
      t.date :fechaLectura
      t.datetime :registroLectura
      t.integer :socio_id
      t.integer :tecnico_id

      t.timestamps
    end
  end
end
