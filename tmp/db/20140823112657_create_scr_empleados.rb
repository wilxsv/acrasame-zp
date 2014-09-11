class CreateScrEmpleados < ActiveRecord::Migration
  def change
    create_table :scr_empleados do |t|
      t.string :empleadoNombre
      t.string :empleadoApellido
      t.integer :empleadoTelefono
      t.integer :empleadoCelular
      t.text :empleadoDireccion
      t.integer :empleadoDui
      t.integer :empleadoIsss
      t.datetime :empleadoRegistro
      t.date :empleadoFechaIngreso
      t.integer :cargo_id
      t.integer :empleadoNit
      t.integer :localidad_id
      t.string :empleadoEmail

      t.timestamps
    end
  end
end
