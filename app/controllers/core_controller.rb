class CoreController < ApplicationController
  def index
  end

  def login
  end

  def autenticate
    #user = ScrUsuario.where('correousuario > ? OR "password" > ? ', 0, 0)
    @ScrUsuario = ScrUsuario.where('correousuario = ?', params['transacx']['user'])
    
    @ScrUsuario.each do |user|
      if user.id > 0
        if user(params['transacx']['user'], params['transacx']['passwd']) == true
          session[:user_nick] = params['transacx']['user']
          redirect_to action: 'index', alert: "Watch it, mister! datos buenos"
        else
          redirect_to action: 'login', alert: "Watch it, mister! password malo"
        end
#        redirect_to action: 'login', alert: "Watch it, mister! usuario y password malo"
      end
#      redirect_to action: 'login', alert: "Watch it, mister! no hay usuarios con ese nombre"
    end
    #redirect_to action: 'login', alert: "Watch it, mister! no ingreso datos bueno"
  end
  
  def logout
    session[:user_nick] = false
    session[:user_nombre] = false
    session[:user_mail] =  false
    session[:rol] = false
  end
  
  private
  def user(user, passwd)
    @ScrUsuario = ScrUsuario.where('correousuario = ?', user)
    @ScrUsuario.each do |x|
      v_to = ScrUsuario.where(' correousuario = ? AND password = ? ', user, Digest::SHA512.hexdigest(x.salt+passwd))
      v_to.each do |u|
        if u.id > 0
          session[:user_id] = u.id
          session[:user_nombre] = u.nombreusuario+"  "+u.apellidousuario
          session[:user_mail] = u.correousuario
          c = ScrEstado.find(u.estado_id)
          session[:rol] = c.nombreEstado
          return true
        else 
          return false
        end
      end
    end
  end
end
