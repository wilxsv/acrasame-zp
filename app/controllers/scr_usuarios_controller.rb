class ScrUsuariosController < ApplicationController
  include AccesoHelpers
  before_action :set_scr_usuario, only: [:show, :edit, :update, :destroy]
  require 'digest'

  # GET /scr_usuarios
  # GET /scr_usuarios.json
  def index
    session[:roles] = "root"
    acceso
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

  # POST /scr_usuarios/
  def orden
    if params.has_key?(:scr_usuario)
		if params[:scr_usuario][:idorden].to_i > 0
			user = ScrUsuario.find_by(id: params[:scr_usuario][:idorden])
			user.update(orden: params[:scr_usuario][:orden])
			redirect_to action: 'index'
		end    
    end
  end

  # POST /scr_usuarios
  # POST /scr_usuarios.json
  def create
    time = Time.new

    #params[:registrousuario] = time.year time.month time.day time.hour time.min time.sec time.usec time.strftime("%Y-%m-%d %H:%M:%S")
    #params[:registrousuario] = time.strftime("%Y-%m-%d %H:%M:%S")
#    params[:salt] = Random.new_seed.to_s
    #params[:password] = params[:password].crypt("$6$" + params[:salt])
    #params[:password] = Digest::SHA512.hexdigest()

    @scr_usuario = ScrUsuario.new()
    @scr_usuario.username		= params[:scr_usuario][:username]
    @scr_usuario.salt			= Random.new_seed.to_s
    @scr_usuario.password		= Digest::SHA512.hexdigest(@scr_usuario.salt+params[:scr_usuario][:password])
    @scr_usuario.correousuario	= params[:scr_usuario][:correousuario]
    @scr_usuario.detalleuuario	= params[:scr_usuario][:detalleuuario]
    @scr_usuario.ipusuario		= request.remote_ip
    @scr_usuario.nombreusuario	= params[:scr_usuario][:nombreusuario]
    @scr_usuario.apellidousuario= params[:scr_usuario][:apellidousuario]
    @scr_usuario.telefonousuario= params[:scr_usuario][:telefonousuario]
    @scr_usuario.nacimientousuario = params[:scr_usuario][:nacimientousuario]
    @scr_usuario.latusuario		= params[:scr_usuario][:latusuario]
    @scr_usuario.lonusuario		= params[:scr_usuario][:lonusuario]
    @scr_usuario.sexousuario	= 3
    @scr_usuario.estado_id = params[:scr_usuario][:estado_id]
    @scr_usuario.localidad_id	= params[:scr_usuario][:localidad_id]
#    uploaded_io = params[:scr_usuario][:imagenusuario]
#    File.open(Rails.root.join('public', 'DzIBijcxalAbR85K6PSOxMNrsqfVl7B1', uploaded_io.original_filename), 'wb') do |file|
#      file.write(uploaded_io.read)
#    end
#    @scr_usuario.imagenusuario = uploaded_io.original_filename

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
  
  def rol
    @rol = ScrUsuarioRol.new()
    @rol.usuario_id	= params[:scr_usuario][:usuario_id]
    @rol.rol_id		= params[:scr_usuario][:estado_id]
    @rol.save
    redirect_to  scr_usuarios_url
  end
  
  #Agregando usuarios  
  def agregausuarios
    @path = Rails.root.to_s+'/public/last.yml'
    @config=YAML.load_file(@path)
    @db = ""
    item = 0
    @config.each do |company,details|
		#puts company
		#puts "-------"
		
		##############################################################
    time = Time.new

    @scr_usuario = ScrUsuario.new()
    @scr_usuario.username		= "Socio "+item.to_s
    @scr_usuario.salt			= Random.new_seed.to_s
    @scr_usuario.password		= Digest::SHA512.hexdigest("Socio "+item.to_s)
    @scr_usuario.correousuario	= "Socio"+item.to_s+"@mail.net"
    @scr_usuario.detalleuuario	= "Ingresado de bd de sistema heredado -- ["+details["dir"]+"] -- "+"2015-01-10 22:30:42.64937-06"
    #@scr_usuario.ultimavisitausuario = "2015-01-10 22:30:42.64937-06"
    @scr_usuario.ipusuario		= request.remote_ip
    @scr_usuario.id	= details["id"]
    @scr_usuario.nombreusuario	= details["nom"]
    @scr_usuario.apellidousuario= details["ape"]
    @scr_usuario.telefonousuario= item
    @scr_usuario.nacimientousuario = "2015-01-10"
    @scr_usuario.latusuario		= details["lat"]
    @scr_usuario.lonusuario		= details["lon"]
    @scr_usuario.contador		= details["conta"]
    @scr_usuario.sexousuario	= 3
    @scr_usuario.estado_id	= 1
    if details["conta"] = 0
		@scr_usuario.estado_id = 2
    end
    #@scr_usuario.registrousuario= "2015-01-10 22:30:42.64937-06"
    @scr_usuario.estado_id = 2
    @scr_usuario.localidad_id	= details["loc"]
    
    if @scr_usuario.save
        @db += "<p>item: " + item.to_s + "</p>"
      else
        @db += "<p>NO: " + item.to_s + "</p>"
      end
      item = item + 1
		##############################################################
	end
    @config=YAML.load_file(@path)
    @db = ""
    item = 0
    @config.each do |company,details|
     @scr_lectura = ScrLectura.new()
     @scr_lectura.valorLectura = details["a"]
     @scr_lectura.fechaLectura = "2014-10-2"
     @scr_lectura.socio_id = details["id"]
     @scr_lectura.tecnico_id = 1
     if @scr_lectura.save
     end
     @scr_lectura = ScrLectura.new()
     @scr_lectura.valorLectura = details["b"]
     @scr_lectura.fechaLectura = "2014-11-2"
     @scr_lectura.socio_id = details["id"]
     @scr_lectura.tecnico_id = 1
     if @scr_lectura.save
     end
     @scr_lectura = ScrLectura.new()
     @scr_lectura.valorLectura = details["c"]
     @scr_lectura.fechaLectura = "2014-12-2"
     @scr_lectura.socio_id = details["id"]
     @scr_lectura.tecnico_id = 1
     if @scr_lectura.save
     end
     
     @scr_lectura = ScrLectura.new()
     @scr_lectura.valorLectura = details["d"]
     @scr_lectura.fechaLectura = "2015-1-2"
     @scr_lectura.socio_id = details["id"]
     @scr_lectura.tecnico_id = 1
     if @scr_lectura.save
     end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_usuario
      @scr_usuario = ScrUsuario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_usuario_params
      params[:salt] = Random.new_seed.to_s
      params.require(:scr_usuario).permit(:username, :password, :correousuario, :detalleuuario, :ultimavisitausuario, :ipusuario, :salt, :nombreusuario, :apellidousuario, :telefonousuario, :nacimientousuario, :latusuario, :lonusuario, :direccionusuario, :contador, :sexousuario, :registrousuario, :cuentausuario, :estado_id, :localidad_id, :imagenusuario)
    end
end
