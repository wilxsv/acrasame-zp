class BloqueController < ApplicationController
  include AccesoHelpers
  
  def index
    session[:roles] = "root"
    acceso
  end
end
