class CreateScrBancos < ActiveRecord::Migration
  def change
    create_table :scr_bancos do |t|
      t.string :banco_nombre

      t.timestamps
    end
  end
end
