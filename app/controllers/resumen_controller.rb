class ResumenController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root contador administrador directiva"
    acceso
    #general
    @periodo = ScrDetContable.where('"dConActivo" = TRUE')
    @ScrTodo = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? OR "cuentaCodigo" < ?',0, 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
    #financiero
    #@cobros = ScrDetFactura.where("cancelada = TRUE AND fecha_cancelada > now() - interval '1 year'").select("to_char(fecha_cancelada, 'Month') AS \"Mes\", SUM(total) as total").group('1')
    @cobros = ScrDetFactura.where("cancelada = TRUE AND fecha_cancelada > now() - interval '1 year'").select("to_char(fecha_cancelada, 'MM') AS \"Mes\", SUM(total) as total").group('1')
    @total = ScrDetFactura.where("limite_pago > now() - interval '1 year'").select("to_char(limite_pago, 'MM') AS \"Mes\", SUM(total) as total").group('1')
    @total_mor = ScrDetFactura.where("fecha_cancelada > limite_pago AND cancelada = TRUE AND fecha_cancelada > now() - interval '1 year'").select("to_char(fecha_cancelada, 'MM') AS \"Mes\", SUM(total) as total").group('1')
    @total_no_pagada = ScrDetFactura.where("cancelada = FALSE AND limite_pago > now() - interval '1 year'").select("to_char(limite_pago, 'MM') AS \"Mes\", SUM(total) as total").group('1')
    @total_cob = ScrConsumo.where("registro > now() - interval '1 year'").select("to_char(registro, 'MM') AS \"Mes\", cobro_id AS id, SUM(cantidad) as total").group('1, 2').order('2')
    @rubro = ScrCobro.order('"cobroNombre"')
    #socias
    @socias = ScrUsuario.all()
    @consumo = ScrUsuario.joins('INNER JOIN scr_det_factura ON scr_det_factura.socio_id = scr_usuario.id').group('scr_usuario.id').select('nombreusuario, apellidousuario, telefonousuario, localidad_id, latusuario, lonusuario, SUM(scr_det_factura.total) AS total')
    #operativos
    @bombeo = ScrBombeo.where("fecha > now() - interval '3 months'").select("to_char(fecha, 'YYYY/MM/DD') AS \"semana\", SUM(voltaje*amperaje) AS potencia, SUM(bombeo_fin) AS fin,SUM(bombeo_inicio) AS inicio, SUM(produccion) AS produccion").group('1').order('1')
    @cloracion = ScrCloracion.where("fecha > now() - interval '3 months'").select("to_char(fecha, 'YYYY/MM/DD') AS \"semana\", SUM(gramos) AS total").group('1').order('1')
    
    #mapas
  end
end

class String
  def initial
    self[0,1]
  end
end
