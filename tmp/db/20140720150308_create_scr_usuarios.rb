class CreateScrUsuarios < ActiveRecord::Migration
  def change
    create_table :scr_usuarios do |t|
      t.string :username
      t.text :password
      t.text :correousuario
      t.text :detalleuuario
      t.datetime :ultimavisitausuario
      t.text :ipusuario
      t.text :salt
      t.string :nombreusuario
      t.string :apellidousuario
      t.integer :telefonousuario
      t.date :nacimientousuario
      t.float :latusuario
      t.float :lonusuario
      t.text :direccionusuario
      t.decimal :sexousuario
      t.datetime :registrousuario
      t.text :cuentausuario
      t.integer :estado_id
      t.integer :localidad_id
      t.text :imagenusuario

      t.timestamps
    end
  end
end
