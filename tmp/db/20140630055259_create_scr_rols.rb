class CreateScrRols < ActiveRecord::Migration
  def change
    create_table :scr_rols do |t|
      t.string :nombrerol
      t.text :detallerol

      t.timestamps
    end
  end
end
