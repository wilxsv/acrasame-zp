class InformeController < ApplicationController
  def index
  end
  
  def balance
   fecha = ScrDetContable.where('"dConActivo" = ? ', 'TRUE')
   @ScrCuentua = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ?', 0, 0).order('"cuentaCodigo"')
  end
  
  def general
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
