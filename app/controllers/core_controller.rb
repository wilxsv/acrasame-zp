class CoreController < ApplicationController
  include AccesoHelpers

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
    session[:user_id] = nil
    session[:user_nombre] = nil
    session[:user_mail] =  nil
    session[:empleado_id] = nil
    session[:rol] = nil
    redirect_to action: 'index'
  end
  
  def configure
    session[:roles] = "contador administrador"
    acceso
    if params.has_key?(:transacx)
      if params['transacx']['cdebe'] != nil and params['transacx']['chaber'] != nil
        #Se define el procedimiento para cobros
        begin
          @tmp = ScrTransaccion.connection.select_all("CREATE OR REPLACE FUNCTION fcn_agrega_transacx(double precision, text)
  RETURNS integer AS
$BODY$
/**
 * Funcion que retorna el valor del nodo solicitado de un xml, si no existe retorna NULL
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.24
*/
DECLARE
  v_monto ALIAS FOR $1;
  v_comentario ALIAS FOR $2;
  resultado BOOLEAN;
  debe BIGINT;
  haber BIGINT;
  v_data TEXT;
  p_xml XML;
BEGIN
  debe := "+params['transacx']['cdebe']+";
  haber := "+params['transacx']['chaber']+";
  v_data := '<transacx>
              <nodo><cuenta>'|| debe || '</cuenta><monto>'|| v_monto || '</monto><debe>1</debe></nodo>
              <nodo><cuenta>'|| haber || '</cuenta><monto>'|| v_monto || '</monto><debe>0</debe></nodo>
             <fecha>'|| CURRENT_DATE ||'</fecha><empleado>1</empleado><comentario>'|| v_comentario || '</comentario></transacx>';
  SELECT fcn_genera_transaccion INTO resultado FROM fcn_genera_transaccion(v_data);
  RETURN 1;
  EXCEPTION
    WHEN invalid_xml_content THEN
      RAISE NOTICE 'Por aqui paso un xml mal formado, [no se realiza extraccion de nodo]';
      RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;")
          session[:error] = '<div class="alert alert-success"><button class="close" data-dismiss="alert" type="button">×</button><strong>Exito! </strong> Procedimiento ejecutado sin errores</div>'
        rescue
          session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Procedimiento ejecutado con errores</div>'
        end
      elsif params['transacx']['nombre'] != nil and params['transacx']['nombre'] != nil
        #Se actualiza el nombre de la organizacion
        session[:error] = "Nombre de organizacion fue actualizado con exito"
        org = ScrOrganizacion.find_by(id: '1')
        org.organizacionNombre = params['transacx']['nombre']
        org.save
      elsif params['transacx']['pdebe'] != nil and params['transacx']['phaber'] != nil
        #Se define el procedimiento para cobros
        begin
          @tmp = ScrTransaccion.connection.select_all("")
          session[:error] = '<div class="alert alert-success"><button class="close" data-dismiss="alert" type="button">×</button><strong>Exito! </strong> Procedimiento ejecutado sin errores</div>'
        rescue
          session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Procedimiento ejecutado con errores</div>'
        end
      else
        session[:error] = "no mando nada"
      end
    end
  end
  
  def pago
    session[:roles] = "contador"
    acceso
    if params.has_key?(:transacx)
      session[:error] = "Se encontraron inconsistencias en su transacción"
      
      if params['transacx']['pdebe'] != nil and params['transacx']['phaber'] != nil
        #Se define el procedimiento para cobros
        begin
          @tmp = ScrTransaccion.connection.select_all("CREATE OR REPLACE FUNCTION fcn_agrega_transacx_pago(double precision, text)
  RETURNS integer AS
$BODY$
/**
 * Funcion que retorna el valor del nodo solicitado de un xml, si no existe retorna NULL
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.24
*/
DECLARE
  v_monto ALIAS FOR $1;
  v_comentario ALIAS FOR $2;
  resultado BOOLEAN;
  debe BIGINT;
  haber BIGINT;
  v_data TEXT;
  p_xml XML;
BEGIN
  debe := "+params['transacx']['pdebe']+";
  haber := "+params['transacx']['phaber']+";
  v_data := '<transacx>
              <nodo><cuenta>'|| debe || '</cuenta><monto>'|| v_monto || '</monto><debe>1</debe></nodo>
              <nodo><cuenta>'|| haber || '</cuenta><monto>'|| v_monto || '</monto><debe>0</debe></nodo>
             <fecha>'|| CURRENT_DATE ||'</fecha><empleado>1</empleado><comentario>'|| v_comentario || '</comentario></transacx>';
  SELECT fcn_genera_transaccion INTO resultado FROM fcn_genera_transaccion(v_data);
  RETURN 1;
  EXCEPTION
    WHEN invalid_xml_content THEN
      RAISE NOTICE 'Por aqui paso un xml mal formado, [no se realiza extraccion de nodo]';
      RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;")
          session[:error] = '<div class="alert alert-success"><button class="close" data-dismiss="alert" type="button">×</button><strong>Exito! </strong> Procedimiento ejecutado sin errores</div>'
          redirect_to action: 'configure'
        rescue
          session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Procedimiento ejecutado con errores</div>'
          redirect_to action: 'configure'
        end
      else
        session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> No envio datos</div>'
        redirect_to action: 'configure'
      end
    end
  end
  
  def correlativo
    session[:roles] = "administrador"
    acceso
    if params.has_key?(:transacx)
      if params['transacx']['secuencia'] != nil
        #Se define el procedimiento para cobros
        begin
          @tmp = ScrTransaccion.connection.select_all("ALTER SEQUENCE scr_det_factura_id_seq RESTART WITH "+params['transacx']['secuencia']+";")
          session[:error] = '<div class="alert alert-success"><button class="close" data-dismiss="alert" type="button">×</button><strong>Exito! </strong> Secuencia registrada</div>'
          redirect_to action: 'configure'
        rescue
          session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> Secuencia no registrada</div>'
          redirect_to action: 'configure'
        end
      else
        session[:error] = '<div class="alert alert-error"><button class="close" data-dismiss="alert" type="button">×</button><strong>Error! </strong> No envio datos</div>'
        redirect_to action: 'configure'
      end
    end
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
          c = ScrUsuarioRol.where(usuario_id: u.id).take
          c = ScrRol.find(c.rol_id)
          session[:rol] = c.nombrerol
          session[:empleado_id] = nil
          @c = ScrEmpleado.where("usuario_id = ?", session[:user_id])
          @c.each do |g|
            session[:empleado_id] = g.id
          end
          return true
        else 
          return false
        end
      end
    end
  end
end
