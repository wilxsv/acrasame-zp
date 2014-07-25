class ScrUsuariosController < ApplicationController
  before_action :set_scr_usuario, only: [:show, :edit, :update, :destroy]
#"password".crypt("$6$somesalt")
  # GET /scr_usuarios
  # GET /scr_usuarios.json
  def index
    @scr_usuarios = ScrUsuario.all
  end

  # GET /scr_usuarios/1
  # GET /scr_usuarios/1.json
  def show
  end

  # GET /scr_usuarios/new
  def new
    @scr_usuario = ScrUsuario.new
  end

  # GET /scr_usuarios/1/edit
  def edit
  end

  # POST /scr_usuarios
  # POST /scr_usuarios.json
  def create
    @scr_usuario = ScrUsuario.new(scr_usuario_params)

    respond_to do |format|
      if @scr_usuario.save
        format.html { redirect_to @scr_usuario, notice: 'Scr usuario was successfully created.' }
        format.json { render :show, status: :created, location: @scr_usuario }
      else
        format.html { render :new }
        format.json { render json: @scr_usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_usuarios/1
  # PATCH/PUT /scr_usuarios/1.json
  def update
    respond_to do |format|
      if @scr_usuario.update(scr_usuario_params)
        format.html { redirect_to @scr_usuario, notice: 'Scr usuario was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_usuario }
      else
        format.html { render :edit }
        format.json { render json: @scr_usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_usuarios/1
  # DELETE /scr_usuarios/1.json
  def destroy
    @scr_usuario.destroy
    respond_to do |format|
      format.html { redirect_to scr_usuarios_url, notice: 'Scr usuario was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_usuario
      @scr_usuario = ScrUsuario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_usuario_params
      params.require(:scr_usuario).permit(:username, :password, :correousuario, :detalleuuario, :ultimavisitausuario, :ipusuario, :salt, :nombreusuario, :apellidousuario, :telefonousuario, :nacimientousuario, :latusuario, :lonusuario, :direccionusuario, :sexousuario, :registrousuario, :cuentausuario, :estado_id, :localidad_id, :imagenusuario)
    end
end
