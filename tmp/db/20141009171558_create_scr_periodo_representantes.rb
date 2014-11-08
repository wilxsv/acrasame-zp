class CreateScrPeriodoRepresentantes < ActiveRecord::Migration
  def change
    create_table :scr_periodo_representantes do |t|
      t.integer :organizacion_id
      t.integer :representante_legal_id
      t.date :periodoInicio
      t.date :periodoFin

      t.timestamps
    end
  end
end
