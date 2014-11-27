class InformeController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root contador administrador socio"
    acceso
  end
  
  def balance
    session[:roles] = "root contador administrador"
    acceso
   fecha = ScrDetContable.where('"dConActivo" = ? ', 'TRUE')
   @ScrCuentua = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ?', 0, 0).order('"cuentaCodigo"')
  end
  
  def general
    session[:roles] = "root contador administrador"
    acceso
   @ScrGrupo = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?', 0, 0, 4).order('"cuentaCodigo"')
   @ScrRubro = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?', 0, 0, 100).order('"cuentaCodigo"')
   @ScrCuenta = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaCodigo" < ?',0, 0, 1000).order('"cuentaCodigo"')
   @ScrTodo = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? OR "cuentaCodigo" < ?',0, 0, 4).order('CAST("cuentaCodigo" AS TEXT)')
  end
end

class String
  def initial
    self[0,1]
  end
end
