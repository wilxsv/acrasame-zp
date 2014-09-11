class ScrEmpleadosController < ApplicationController
  before_action :set_scr_empleado, only: [:show, :edit, :update, :destroy]

  # GET /scr_empleados
  # GET /scr_empleados.json
  def index
    @scr_empleados = ScrEmpleado.all
  end

  # GET /scr_empleados/1
  # GET /scr_empleados/1.json
  def show
  end

  # GET /scr_empleados/new
  def new
    @scr_empleado = ScrEmpleado.new
  end

  # GET /scr_empleados/1/edit
  def edit
  end

  # POST /scr_empleados
  # POST /scr_empleados.json
  def create
    @scr_empleado = ScrEmpleado.new(scr_empleado_params)

    respond_to do |format|
      if @scr_empleado.save
        format.html { redirect_to @scr_empleado, notice: 'Scr empleado was successfully created.' }
        format.json { render :show, status: :created, location: @scr_empleado }
      else
        format.html { render :new }
        format.json { render json: @scr_empleado.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scr_empleados/1
  # PATCH/PUT /scr_empleados/1.json
  def update
    respond_to do |format|
      if @scr_empleado.update(scr_empleado_params)
        format.html { redirect_to @scr_empleado, notice: 'Scr empleado was successfully updated.' }
        format.json { render :show, status: :ok, location: @scr_empleado }
      else
        format.html { render :edit }
        format.json { render json: @scr_empleado.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scr_empleados/1
  # DELETE /scr_empleados/1.json
  def destroy
    @scr_empleado.destroy
    respond_to do |format|
      format.html { redirect_to scr_empleados_url, notice: 'Scr empleado was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scr_empleado
      @scr_empleado = ScrEmpleado.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scr_empleado_params
      params.require(:scr_empleado).permit(:empleadoNombre, :empleadoApellido, :empleadoTelefono, :empleadoCelular, :empleadoDireccion, :empleadoDui, :empleadoIsss, :empleadoRegistro, :empleadoFechaIngreso, :cargo_id, :empleadoNit, :localidad_id, :empleadoEmail)
    end
end
