class EstadoController < ApplicationController
  def index
    @activos = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaActivo" = ?', 0, 0, 'TRUE').order('"cuentaCodigo"')
    @pasivos = ScrCuentua.where('"cuentaDebe" > ? OR "cuentaHaber" > ? AND "cuentaActivo" = ?', 0, 0, 'FALSE').order('"cuentaCodigo"')
  end
end
