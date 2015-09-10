class ScrRepresentanteLegal < ActiveRecord::Base
  self.table_name = "scr_representante_legal"

  scope :firmaDocumento, -> {
        joins("INNER JOIN scr_periodo_representante ON scr_representante_legal.id = scr_periodo_representante.representante_legal_id
               INNER JOIN scr_cat_rep_legal ON scr_cat_rep_legal.id = scr_representante_legal.cat_rep_legal_id")
        .where(['scr_cat_rep_legal."catRLegalFirma"= TRUE AND 
				scr_periodo_representante."periodoInicio" <= now() AND
				scr_periodo_representante."periodoFin" >= now()'])
        .select('scr_representante_legal."rLegalNombre", scr_representante_legal."rLegalApellido", scr_cat_rep_legal."catRLegalNombre"')
  }
end
