include ActionView::Helpers::NumberHelper
require 'date'
@@HQUERY
@@HFTRANX
@@HCONCEPTO

module InformeHelper

  def genera_partida(titulo, subTitulo, tabla, fecha, concepto)
  	user = session[:user_nombre]
  	
      require "prawn/measurement_extensions"
      require "prawn/table"

      Prawn::Document.new(:page_size => "LETTER", :margin => [1.cm,1.cm,1.cm,1.cm], :page_layout => :portrait) do 
        time = Time.new
        bounding_box([0, 645], :width => 580) do #, :height => 680  # stroke_bounds
        table(tabla, :header => true, :width  => 570, :cell_style => { :inline_format => true, :size => 10 }) do
        end
          
        firmas = ScrRepresentanteLegal.firmaDocumento
        firmas.each do |data|
          text "\r\n", :align => :center, :size => 25
          text "___________________________________________________________________________", :align => :center, :size => 5
          text data.rLegalNombre+" "+data.rLegalNombre, :align => :center, :size => 10
          text data.catRLegalNombre, :align => :center, :size => 7
        end
        #stroke_color 'FFFF00'
      end
        
      repeat :all do          #Header
        bounding_box [bounds.left, bounds.top], :width  => bounds.width do
          font "Helvetica"
          image Rails.root.to_s+'/public/images/logo.png', :at => [0,0], :scale => 0.4 # :style => [:bold, :italic] }])
          text " ::  Asociación Rural, Agua Salud y Medio Ambiente El Zapote - Platanares ::", :align => :center, :size => 18
          text " #{Prawn::Text::NBSP*19} "+titulo, :align => :left, :size => 13
          if !(subTitulo.blank?)
            text " #{Prawn::Text::NBSP*19}" +"["+subTitulo+"]", :align => :left, :size => 13
          end
          stroke_horizontal_rule
        end
        #Footer
        bounding_box [bounds.left, bounds.bottom + 25], :width  => bounds.width do
          font "Helvetica"
          stroke_horizontal_rule
          move_down(3)
          text " Generado el: "+time.strftime("%Y-%m-%d %H:%M:%S").to_s, :align => :left, :size => 7
          text " Impreso por: "+user, :align => :left, :size => 7
          number_pages "\r\nPagina <page> de <total>", { :align => :right, :size => 7 }#:start_count_at => 5, :page_filter => lambda{ |pg| pg != 1 }, :at => [bounds.right - 50, 0], :size => 14}
        end
      end
    end.render
  end

end

class String
  def initial
    self[0,1]
  end
end
