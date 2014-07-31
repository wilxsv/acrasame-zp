  def acceso
    #s.index 'World
    if session[:roles] != nil and session[:roles].match(session[:rol]) 
      session[:roles] = ""
      #entro
    else
      session[:error] = "Intentas entrar en un lugar que no existe"
      redirect_to core_index_url and return
    end
  end
