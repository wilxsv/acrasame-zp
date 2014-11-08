class HomeController < ApplicationController
  def index
  end

  def login
    if params.has_key?(:transacx)
      user = params['transacx']['user']
      clave = params['transacx']['clave']
     redirect_to action: 'logout' 
    end
  end
  
  def logout
    session[:user_id] = nil
    session[:user_nombre] = nil
    session[:user_mail] =  nil
    session[:rol] = nil
    redirect_to action: 'index'
  end
  
  def profile
  end
  
  private
  def acceder(user, clave)
    begin
      @scr_transaccions = ScrTransaccion.where('"transaxFecha" = ?', fecha).order('"transaxSecuencia", "transaxRegistro"')
      
    rescue
      redirect_to action: 'index'
    end
  end
  
  require './lib/usuario.rb' 
end
