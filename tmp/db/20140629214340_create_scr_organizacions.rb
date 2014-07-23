class CreateScrOrganizacions < ActiveRecord::Migration
  def change
    create_table :scr_organizacions do |t|
      t.string :organizacionNombre
      t.text :organizacionDescripcion
      t.integer :localidad_id

      t.timestamps
    end
  end
end
