class CreateScrEstados < ActiveRecord::Migration
  def change
    create_table :scr_estados do |t|
      t.string :nombreEstado

      t.timestamps
    end
  end
end
