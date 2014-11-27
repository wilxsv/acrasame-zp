module AccesoHelpers
  
  #Esta funcion permite de forma simple evaluar una cadena de roles de los cuales revuelve si se posee acceso o no
  def acceso
    msg = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Advertencia! </strong>Intentas entrar en un lugar que no esta habilitado</div>'
    if session[:roles].nil?
      session[:error] = msg
      redirect_to core_index_url and return
    elsif session[:rol] != nil and session[:roles].match(session[:rol])
      session[:roles] = nil
    else
      session[:error] = msg
      redirect_to core_index_url and return
    end
  end
end
