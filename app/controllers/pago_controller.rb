class PagoController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root"
    acceso
  end
end
