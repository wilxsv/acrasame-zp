class SeguridadController < ApplicationController    
  private
    def require_login
      unless logged_in?
        flash[:error] = "Debe estar registrado para acceder a esta sección"
        redirect_to home_index_path # halts request cycle
      end
    end
end
