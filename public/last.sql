--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.15
-- Dumped by pg_dump version 9.1.15
-- Started on 2015-03-03 15:02:24 CST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 249 (class 3079 OID 11644)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 249
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 597 (class 1247 OID 17268)
-- Dependencies: 598 5
-- Name: dominio_email; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN dominio_email AS character varying(150)
	CONSTRAINT dominio_email_check CHECK (((VALUE)::text ~ '^[A-Za-z0-9](([_.-]?[a-zA-Z0-9]+)*)@([A-Za-z0-9]+)(([.-]?[a-zA-Z0-9]+)*).([A-Za-z]{2,})$'::text));


--
-- TOC entry 599 (class 1247 OID 17270)
-- Dependencies: 600 5
-- Name: dominio_ip; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN dominio_ip AS character varying(15)
	CONSTRAINT dominio_ip_check CHECK (((family((VALUE)::inet) = 4) OR (family((VALUE)::inet) = 6)));


--
-- TOC entry 601 (class 1247 OID 17272)
-- Dependencies: 602 5
-- Name: dominio_xml; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN dominio_xml AS text
	CONSTRAINT dominio_xml_check CHECK ((VALUE)::xml IS DOCUMENT);


--
-- TOC entry 261 (class 1255 OID 17274)
-- Dependencies: 816 5
-- Name: fcn_actualiza_cuenta(boolean, bigint, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_actualiza_cuenta(boolean, bigint, double precision) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que actualiza cuentas
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2014.10.31
*/
DECLARE
  v_debe ALIAS FOR $1;
  v_cuenta ALIAS FOR $2;
  v_monto ALIAS FOR $3;
BEGIN
 IF (v_debe) THEN
   UPDATE scr_cuenta SET "cuentaDebe" = "cuentaDebe" + v_monto WHERE id = v_cuenta;
 ELSE
   UPDATE scr_cuenta SET "cuentaHaber" = "cuentaHaber" + v_monto WHERE id = v_cuenta;
 END IF;
RETURN 1;
END;
$_$;


--
-- TOC entry 262 (class 1255 OID 17275)
-- Dependencies: 816 5
-- Name: fcn_actualiza_rubro(bigint, bigint, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_actualiza_rubro(bigint, bigint, double precision) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que actualiza rubros
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2014.10.31
*/
DECLARE
  v_cuenta ALIAS FOR $1;
  v_next ALIAS FOR $2;
  v_monto ALIAS FOR $3;
BEGIN
  
RETURN 1;
END;
$_$;


--
-- TOC entry 263 (class 1255 OID 17276)
-- Dependencies: 816 5
-- Name: fcn_actualiza_rubro(boolean, bigint, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_actualiza_rubro(boolean, bigint, double precision) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que actualiza rubros
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2014.10.31
*/
DECLARE
  v_debe ALIAS FOR $1;
  v_cuenta ALIAS FOR $2;
  v_monto ALIAS FOR $3;
  v_next BIGINT;
BEGIN
  LOOP
      EXIT WHEN v_cuenta ISNULL;
      SELECT "cuentaCodigo" INTO v_next FROM scr_cuenta WHERE id = v_cuenta;
      IF (v_next >  9 AND v_next < 100) THEN
        IF (v_debe) THEN
           UPDATE scr_cuenta SET "cuentaDebe" = "cuentaDebe" + v_monto WHERE id = v_cuenta;
        ELSE
          UPDATE scr_cuenta SET "cuentaHaber" = "cuentaHaber" + v_monto WHERE id = v_cuenta;
        END IF;
        v_cuenta := NULL;
        RAISE INFO 'Se llego a la cuenta rubro y se actualizara con el monto de las subcuentas';
      ELSIF (v_next <10) THEN
        v_cuenta := NULL;
        RAISE INFO 'Cuenta grupo, no se actualizan saldos en esta cuenta';
      ELSE
        SELECT cat_cuenta_id INTO v_cuenta FROM scr_cuenta WHERE id = v_cuenta;
      END IF;
  END LOOP;
RETURN 1;
END;
$_$;


--
-- TOC entry 264 (class 1255 OID 17277)
-- Dependencies: 816 5
-- Name: fcn_agrega_transacx(double precision, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_agrega_transacx(double precision, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
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
  debe := 259;
  haber := 204;
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
$_$;


--
-- TOC entry 265 (class 1255 OID 17278)
-- Dependencies: 816 5
-- Name: fcn_agrega_transacx_pago(double precision, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_agrega_transacx_pago(double precision, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
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
  debe := 96;
  haber := 96;
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
$_$;


--
-- TOC entry 266 (class 1255 OID 17279)
-- Dependencies: 5 816
-- Name: fcn_det_factura(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_det_factura() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
/**
 * Funcion que agrega costos permanentes a socios
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2014.08.25
*/
DECLARE
  var BIGINT;
  can DOUBLE PRECISION;
  mor DOUBLE PRECISION;
  p record;
  q record;
  r record;
BEGIN
  --Primero: genero facturas a usuario
  FOR p IN SELECT * FROM scr_usuario AS u, scr_usuario_rol AS ro WHERE u.id = ro.usuario_id AND ro.rol_id=1 AND u.estado_id = 1
    LOOP
      INSERT INTO scr_det_factura(socio_id, limite_pago) VALUES (p.id, (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date));
      RAISE notice 'factura generada para [%]',p.id;
    END LOOP;
  SELECT "cobroValor" INTO mor FROM scr_cobro WHERE id = 1;
  --Segundo: agrego cobro de mora a facturas ya generadas
  --		Agrego cobro por mora a los que no pagaron su ultimo recibo
    FOR p IN SELECT us.id, max(fa.id) AS fac
    FROM scr_usuario AS us, scr_usuario_rol AS ro, scr_det_factura AS fa
    WHERE us.id = ro.usuario_id AND ro.rol_id = 1 AND us.id = fa.socio_id AND
    fa.cancelada = FALSE AND (date_part('month', now())-date_part('month', fa.limite_pago))=1 GROUP BY us.id 
      LOOP
        SELECT total INTO can FROM scr_det_factura WHERE id = p.fac;
        SELECT id INTO var FROM scr_det_factura AS f WHERE socio_id = p.id ORDER BY 1 DESC LIMIT 1;
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (mor, 1, var);
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (can, 2, var);
        RAISE notice 'cargo de mora generado para [%] de [%] en [%]',p.id, can, var;
      END LOOP;
  --		Agrego cobro por mora a los que pagaron tarde su ultimo recibo
    FOR p IN SELECT us.id FROM scr_usuario AS us, scr_usuario_rol AS ro, scr_det_factura AS fa
    WHERE
    us.id = ro.usuario_id AND ro.rol_id = 1 AND us.id = fa.socio_id AND fa.cancelada = TRUE AND
    fecha_cancelada > fa.limite_pago AND (date_part('month', now())-date_part('month', fa.limite_pago))=1
      LOOP
        SELECT id INTO var FROM scr_det_factura AS f WHERE socio_id = p.id ORDER BY 1 DESC LIMIT 1;
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (mor, 1, var);
        RAISE notice 'cargo de mora generado para [%] de [%] en [%]',p.id, can, var;
      END LOOP;  
  
  --Tercero: agrego cobro permanente a facturas ya generadas
  FOR r IN SELECT * FROM scr_cobro WHERE "cobroPermanente" = TRUE
    LOOP
      FOR p IN SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
        LOOP
          INSERT INTO scr_consumo(cantidad, cobro_id, factura_id)
          VALUES (1, r.id, p.id);
          RAISE notice 'Cobro permanente [%] para [%]', r.id, p.id;
        END LOOP;
    END LOOP;
  --Cuarto: agrego cobro por consumo de recurso
  FOR r IN SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
    LOOP
      can := 0;
      mor := 0;
      var := 0;
      --can=inicial; mor=final; var=cobro_id
      SELECT l."valorLectura" INTO can FROM scr_lectura AS l 
      WHERE (date_part('month', now())-date_part('month',l."fechaLectura")) = 1 AND l.socio_id = r.socio_id;
      SELECT l."valorLectura" INTO mor FROM scr_lectura AS l 
      WHERE (date_part('month', now())-date_part('month',l."fechaLectura")) = 0 AND l.socio_id = r.socio_id;
      mor := mor - can;
      IF mor >= 0 THEN
        SELECT id INTO var FROM scr_cobro WHERE "cobroInicio" <= mor AND "cobroFin" >= mor AND cat_cobro_id = 1;
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (mor, var, r.id);
        RAISE notice 'Cobro consumo para [%] de [%]', r.id, mor;
      END IF;
    END LOOP;
  --Quinto: Actualizo total
  FOR r IN SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
    LOOP
      can := 0;
      mor := 0;
      --mor=consumo; can=otros cobros
/*      SELECT SUM(c.cantidad * k."cobroValor") INTO can FROM scr_consumo AS c, scr_cobro AS k 
      WHERE c.factura_id = r.id  AND c.cobro_id = k.id AND cat_cobro_id != 1
      GROUP BY factura_id;
      SELECT k."cobroValor" INTO mor FROM scr_consumo AS c, scr_cobro AS k 
      WHERE c.factura_id = r.id  AND c.cobro_id = k.id AND cat_cobro_id = 1;
      mor := mor + can;	*/
      SELECT SUM(c.cantidad * k."cobroValor") INTO mor FROM scr_consumo AS c, scr_cobro AS k 
      WHERE c.factura_id = r.id  AND c.cobro_id = k.id GROUP BY factura_id;
      UPDATE scr_det_factura SET total=mor WHERE id=r.id;
      SELECT * INTO var FROM fcn_agrega_transacx(mor, '['|| r.id ||'-'|| r.socio_id ||'] Recibo por consumo de agua');
      RAISE notice 'Se actualizo total de [%] para [%]', mor, r.id;
    END LOOP;
  RETURN 1;
END;
$$;


--
-- TOC entry 267 (class 1255 OID 17280)
-- Dependencies: 5 816
-- Name: fcn_det_factura(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_det_factura(bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que da por pagada una factura
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2014.09.06
*/
DECLARE
  v_cuenta ALIAS FOR $1;--Numero de recibo
  p_sec BIGINT;
  var BIGINT;
  can DOUBLE PRECISION;
  mor DOUBLE PRECISION;
  p record;
  q record;
  r record;
BEGIN
  --Primero: genero facturas a usuario
  FOR p IN SELECT * FROM scr_usuario AS u, scr_usuario_rol AS ro WHERE u.id = ro.usuario_id AND ro.rol_id=1
    LOOP
      INSERT INTO scr_det_factura(socio_id, limite_pago) VALUES (p.id, (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date));
      RAISE notice 'factura generada para [%]',p.id;
    END LOOP;
  SELECT "cobroValor" INTO mor FROM scr_cobro WHERE id = 1;
  --Segundo: agrego cobro de mora a facturas ya generadas
  --		Agrego cobro por mora a los que no pagaron su ultimo recibo
    FOR p IN SELECT us.id, max(fa.id) AS fac
    FROM scr_usuario AS us, scr_usuario_rol AS ro, scr_det_factura AS fa
    WHERE us.id = ro.usuario_id AND ro.rol_id = 1 AND us.id = fa.socio_id AND
    fa.cancelada = FALSE AND (date_part('month', now())-date_part('month', fa.limite_pago))=1 GROUP BY us.id 
      LOOP
        SELECT total INTO can FROM scr_det_factura WHERE id = p.fac;
        SELECT id INTO var FROM scr_det_factura AS f WHERE socio_id = p.id ORDER BY 1 DESC LIMIT 1;
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (mor, 1, var);
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (can, 2, var);
        RAISE notice 'cargo de mora generado para [%] de [%] en [%]',p.id, can, var;
      END LOOP;
  --		Agrego cobro por mora a los que pagaron tarde su ultimo recibo
    FOR p IN SELECT us.id FROM scr_usuario AS us, scr_usuario_rol AS ro, scr_det_factura AS fa
    WHERE
    us.id = ro.usuario_id AND ro.rol_id = 1 AND us.id = fa.socio_id AND fa.cancelada = TRUE AND
    fecha_cancelada > fa.limite_pago AND (date_part('month', now())-date_part('month', fa.limite_pago))=1
      LOOP
        SELECT id INTO var FROM scr_det_factura AS f WHERE socio_id = p.id ORDER BY 1 DESC LIMIT 1;
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (mor, 1, var);
        RAISE notice 'cargo de mora generado para [%] de [%] en [%]',p.id, can, var;
      END LOOP;  
  
  --Tercero: agrego cobro permanente a facturas ya generadas
  FOR r IN SELECT * FROM scr_cobro WHERE "cobroPermanente" = TRUE
    LOOP
      FOR p IN SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
        LOOP
          INSERT INTO scr_consumo(cantidad, cobro_id, factura_id)
          VALUES (1, r.id, p.id);
          RAISE notice 'Cobro permanente [%] para [%]', r.id, p.id;
        END LOOP;
    END LOOP;
  --Cuarto: agrego cobro por consumo de recurso
  FOR r IN SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
    LOOP
      can := 0;
      mor := 0;
      var := 0;
      --can=inicial; mor=final; var=cobro_id
      SELECT l."valorLectura" INTO can FROM scr_lectura AS l 
      WHERE (date_part('month', now())-date_part('month',l."fechaLectura")) = 1 AND l.socio_id = r.socio_id;
      SELECT l."valorLectura" INTO mor FROM scr_lectura AS l 
      WHERE (date_part('month', now())-date_part('month',l."fechaLectura")) = 0 AND l.socio_id = r.socio_id;
      mor := mor - can;
      IF mor >= 0 THEN
        SELECT id INTO var FROM scr_cobro WHERE "cobroInicio" <= mor AND "cobroFin" >= mor AND cat_cobro_id = 1;
        INSERT INTO scr_consumo(cantidad, cobro_id, factura_id) VALUES (mor, var, r.id);
        RAISE notice 'Cobro consumo para [%] de [%]', r.id, mor;
      END IF;
    END LOOP;
  --Quinto: Actualizo total
  FOR r IN SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
    LOOP
      can := 0;
      mor := 0;
      --mor=consumo; can=otros cobros
      SELECT SUM(c.cantidad * k."cobroValor") INTO can FROM scr_consumo AS c, scr_cobro AS k 
      WHERE c.factura_id = r.id  AND c.cobro_id = k.id AND cat_cobro_id != 1
      GROUP BY factura_id;
      SELECT k."cobroValor" INTO mor FROM scr_consumo AS c, scr_cobro AS k 
      WHERE c.factura_id = r.id  AND c.cobro_id = k.id AND cat_cobro_id = 1;
      mor := mor + can;
      UPDATE scr_det_factura SET total=mor WHERE id=r.id;
      RAISE notice 'Se actualizo total de [%] para [%]', mor, r.id;
    END LOOP;
  RETURN 1;
END;
$_$;


--
-- TOC entry 268 (class 1255 OID 17281)
-- Dependencies: 816 5
-- Name: fcn_es_subcuenta(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_es_subcuenta(bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que retorna verdadero si la cuenta evaluada es subcuenta o FALSO si es un rubro
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.30
*/
DECLARE
  v_cuenta ALIAS FOR $1;--Datos que se envian en formato de xml
  p_sec BIGINT;
BEGIN
  SELECT id INTO p_sec FROM scr_cuenta WHERE id = v_cuenta AND "cuentaCodigo" >= 100;
  IF (p_sec > 0) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$_$;


--
-- TOC entry 269 (class 1255 OID 17282)
-- Dependencies: 5 816
-- Name: fcn_find_nodoXML(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_find_nodoXML"(text, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que un nodo de un xml enviado
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.25
*/
DECLARE
  v_d ALIAS FOR $1;--Datos que se envian en formato de xml
  v_n ALIAS FOR $2;--nombre del primer nodo que se extaera
  p_xml XML; --Variable para comprobar el formato del xml recibido
  p_inicio INT;
  p_fin INT;
  v_tmp TEXT;
BEGIN
  p_xml := CAST(v_d AS XML);
  IF (p_xml IS DOCUMENT) THEN
       IF (strpos(v_d, v_n) < 1) THEN
           RETURN NULL;
       END IF;
       p_inicio := position('<'||v_n in v_d);
       p_fin := position('</'||v_n||'>' in v_d)-p_inicio+char_length('</'||v_n||'>');
       v_tmp := substring(v_d from p_inicio for p_fin);
       RAISE info 'El nodo es [%] cortado desde [%] hasta [%]', v_tmp, p_inicio, p_fin;
       RETURN v_tmp;
  END IF;
  RETURN NULL;
  EXCEPTION
    WHEN invalid_xml_content THEN
      RAISE NOTICE 'Por aqui paso un xml mal formado, [no se realiza extraccion de nodo]';
      RETURN NULL;
    WHEN substring_error THEN
      RAISE NOTICE 'No se encontro nada en el xml';
      RETURN NULL;
END;
$_$;


--
-- TOC entry 270 (class 1255 OID 17283)
-- Dependencies: 5 816
-- Name: fcn_genera_transaccion(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_genera_transaccion(text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que registra una transaccion de # cuentas afectadas
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.22
*/
DECLARE
  v_dato ALIAS FOR $1;
  v_indice BIGINT;
  v_fecha date;
  v_user BIGINT;
  v_tmp TEXT;
  v_xml TEXT;
  p_debe double precision;
  p_haber double precision;
  p_track BIGINT; --Secuencia de periodo contable
  p_periodo BIGINT;
  p_fecha DATE;
  p_empleado BIGINT;
  p_comentario TEXT;
BEGIN
  --definicion de constantes
  IF (fcn_xml2data(v_dato, '/transacx/fecha')::DATE IS NULL) THEN--Verifico que la fecha sea valida
    RAISE NOTICE 'no es fecha';
    RETURN FALSE;
  ELSIF (fcn_xml2data(v_dato, '/transacx/empleado')::BIGINT IS NULL) THEN--Verifico que exista el id del usuario
    RAISE NOTICE 'no es Empleado';
    RETURN FALSE;
  ELSIF (fcn_xml2data(v_dato, '/transacx/nodo') IS NULL) THEN
    RAISE NOTICE 'no posee nodos de transaccion';
    RETURN FALSE;
  ELSE
    v_tmp := "fcn_find_nodoXML"(v_dato, 'nodo');
    v_xml := v_dato;
    p_debe := 0;
    p_haber := 0;
    p_track := fcn_sec_transacx(fcn_xml2data(v_dato, '/transacx/fecha')::DATE);
    p_periodo := fcn_periodo(fcn_xml2data(v_dato, '/transacx/fecha')::DATE);
    p_fecha := fcn_xml2data(v_dato, '/transacx/fecha')::DATE;
    p_empleado := fcn_xml2data(v_dato, '/transacx/empleado')::BIGINT;
    p_comentario := fcn_xml2data(v_dato, '/transacx/comentario');
    IF (character_length(p_comentario) < 3 ) THEN
      p_comentario := 'Sin detalle de transaccion';
    END IF;
    IF (p_periodo = 0) THEN
      RAISE EXCEPTION 'Transaccion en periodo no valido';
      RETURN FALSE;
    END IF;
    LOOP
      EXIT WHEN v_tmp ISNULL;
      IF (fcn_xml2data(v_tmp, '/nodo/debe')::INTEGER NOTNULL AND fcn_xml2data(v_tmp, '/nodo/debe')::INTEGER = 1 OR fcn_xml2data(v_tmp, '/nodo/debe')::INTEGER = 0) THEN
        IF (fcn_xml2data(v_tmp, '/nodo/debe')::INTEGER = 1) THEN
          p_debe := p_debe + fcn_xml2data(v_tmp, '/nodo/monto')::double precision;
          IF (fcn_es_subcuenta(fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT) = FALSE) THEN
            RAISE EXCEPTION 'No se puede agregar transacciones en cuentas grupo o rubro';
            RETURN FALSE;
          END IF;
          INSERT INTO scr_transaccion("transaxSecuencia", cuenta_id,
                                      "transaxMonto", "transaxDebeHaber", 
                                      empleado_id, "transaxFecha", pcontable_id, comentario)
          VALUES (p_track, fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT,
                  fcn_xml2data(v_tmp, '/nodo/monto')::double precision, TRUE,
                  p_empleado, p_fecha, p_periodo, p_comentario);
          v_indice := fcn_actualiza_cuenta(TRUE, fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT, fcn_xml2data(v_tmp, '/nodo/monto')::double precision);
          v_indice := fcn_actualiza_rubro(TRUE, fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT, fcn_xml2data(v_tmp, '/nodo/monto')::double precision);
        ELSE
          p_haber := p_haber + fcn_xml2data(v_tmp, '/nodo/monto')::double precision;
          INSERT INTO scr_transaccion("transaxSecuencia", cuenta_id,
                                      "transaxMonto", "transaxDebeHaber", 
                                      empleado_id, "transaxFecha", pcontable_id, comentario)
          VALUES (p_track, fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT,
                  fcn_xml2data(v_tmp, '/nodo/monto')::double precision, FALSE,
                  p_empleado, p_fecha, p_periodo, p_comentario);
          v_indice := fcn_actualiza_cuenta(FALSE, fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT, fcn_xml2data(v_tmp, '/nodo/monto')::double precision);
          v_indice := fcn_actualiza_rubro(FALSE, fcn_xml2data(v_tmp, '/nodo/cuenta')::BIGINT, fcn_xml2data(v_tmp, '/nodo/monto')::double precision);
        END IF;
      ELSE
        RAISE EXCEPTION 'Se debe especificar tipo de registro (DEBE=1, HABER=0)';
        RETURN FALSE;
      END IF;
      v_xml := "fcn_get_nodoXML"(v_xml, v_tmp);
      v_tmp := "fcn_find_nodoXML"(v_xml, 'nodo');
    END LOOP;
    IF (p_haber != p_debe) THEN
      RAISE EXCEPTION 'DEBE no es igual al HABER';
      RETURN FALSE;
    END IF;
  END IF;
  RETURN true;
  EXCEPTION
    WHEN invalid_datetime_format OR DATETIME_FIELD_OVERFLOW THEN
      RAISE NOTICE 'Fecha no valida';
      RETURN FALSE;
    WHEN invalid_text_representation THEN
      RAISE NOTICE 'numero no valido';
      RETURN FALSE;
    WHEN integrity_constraint_violation OR restrict_violation OR not_null_violation OR foreign_key_violation OR unique_violation OR check_violation THEN
      RAISE NOTICE 'Restriccion no cunplida para transacción';
      RETURN FALSE;
END;
$_$;


--
-- TOC entry 271 (class 1255 OID 17284)
-- Dependencies: 5 816
-- Name: fcn_get_nodoXML(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_get_nodoXML"(text, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que elimina el primer nodo de un xml enviado
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.25
*/
DECLARE
  v_d ALIAS FOR $1;--Datos que se envian en formato de xml
  v_n ALIAS FOR $2;--nombre del primer nodo que se extaera
  p_xml XML; --Variable para comprobar el formato del xml recibido
BEGIN
  p_xml := CAST(v_d AS XML);
  IF (p_xml IS DOCUMENT) THEN
       RAISE info 'El nodo es [%]', v_n;
       RETURN replace(v_d, v_n, '');
  END IF;
  RETURN NULL;
  EXCEPTION
    WHEN invalid_xml_content THEN
      RAISE NOTICE 'Por aqui paso un xml mal formado, [no se realiza extraccion de nodo]';
      RETURN NULL;
END;
$_$;


--
-- TOC entry 272 (class 1255 OID 17285)
-- Dependencies: 5 816
-- Name: fcn_pago_factura(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_pago_factura(bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que da por pagada una factura
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2014.09.06
*/
DECLARE
  v_cuenta ALIAS FOR $1;--Numero de recibo
  p_sec BIGINT;
  var BIGINT;
  can DOUBLE PRECISION;
  mor DOUBLE PRECISION;
  p record;
  q record;
  r record;
BEGIN
  IF v_cuenta > 1 THEN
    SELECT * INTO p FROM scr_det_factura WHERE det_factur_numero = v_cuenta;
    UPDATE scr_det_factura SET cancelada = TRUE, fecha_cancelada = now() 
    WHERE id <= p.id AND cancelada = FALSE AND socio_id=p.socio_id;
    SELECT * INTO var FROM fcn_agrega_transacx_pago(p.total, '['|| p.id ||'-'|| p.socio_id ||'] Pago por consumo de agua');
    RAISE INFO 'Facturas actualizadas';
    RETURN 1;
  ELSE
    RAISE WARNING 'Dato no valido';
    RETURN 0;
  END IF;
END;
$_$;


--
-- TOC entry 273 (class 1255 OID 17286)
-- Dependencies: 5 816
-- Name: fcn_periodo(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_periodo(date) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que retorna el periodo contable activo
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.11.26
*/
DECLARE
  v_dato ALIAS FOR $1;
  p_sec BIGINT;
BEGIN
  SELECT id INTO p_sec FROM scr_det_contable WHERE "dConActivo" = TRUE AND "dConIniPeriodo" <= v_dato AND "dConFinPeriodo" >= v_dato;
  IF (p_sec > 0) THEN
    RETURN p_sec;
  ELSE
    RAISE EXCEPTION 'No se puede hacer registros en periodos contables no activos';
    RETURN 0;
  END IF;
  EXCEPTION
    WHEN invalid_datetime_format OR DATETIME_FIELD_OVERFLOW OR DATETIME_FIELD_OVERFLOW THEN
      RAISE EXCEPTION 'Fecha no valida';
      RETURN 0;
END;
$_$;


--
-- TOC entry 274 (class 1255 OID 17287)
-- Dependencies: 816 5
-- Name: fcn_sec_transacx(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_sec_transacx(date) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que retorna el correlativo de la transaccion del periodo contable activo
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.11.26
*/
DECLARE
  v_dato ALIAS FOR $1;
  p_sec BIGINT;
BEGIN
  SELECT id INTO p_sec FROM scr_det_contable WHERE "dConActivo" = TRUE AND "dConIniPeriodo" <= v_dato AND "dConFinPeriodo" >= v_dato;
  IF (p_sec > 0) THEN
    SELECT COUNT (*) INTO p_sec FROM (SELECT COUNT("transaxSecuencia") FROM scr_transaccion WHERE pcontable_id = p_sec GROUP BY "transaxSecuencia") AS total;
    RETURN p_sec+1;
  ELSE
    RAISE EXCEPTION 'No se puede hacer registros en periodos contables no activos';
  END IF;
  EXCEPTION
    WHEN invalid_datetime_format OR DATETIME_FIELD_OVERFLOW OR DATETIME_FIELD_OVERFLOW THEN
      RAISE EXCEPTION 'Fecha no valida';
      RETURN NULL;
END;
$_$;


--
-- TOC entry 275 (class 1255 OID 17288)
-- Dependencies: 816 5
-- Name: fcn_xml2data(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fcn_xml2data(text, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
/**
 * Funcion que retorna el valor del nodo solicitado de un xml, si no existe retorna NULL
 * Acceso: publico
 * Autor:  William Vides - wilx.sv@gmail.com
 * Fecha: 2012.10.24
*/
DECLARE
  v_xml ALIAS FOR $1;
  v_path ALIAS FOR $2;
  v_data TEXT;
  p_xml XML;
BEGIN
  p_xml:= v_xml::XML;--CAST(v_xml AS XML);
  IF (p_xml IS DOCUMENT) THEN
    --IF () THEN
    SELECT * into v_data from xpath(v_path||'/text()', p_xml);
    v_data := replace(replace( v_data, '}', ''), '{', '');
    RETURN v_data;
  END IF;
  RETURN NULL;
  EXCEPTION
    WHEN invalid_xml_content THEN
      RAISE NOTICE 'Por aqui paso un xml mal formado, [no se realiza extraccion de nodo]';
      RETURN NULL;
/*
<transacx>
 <nodo>
  <cuenta></cuenta>
  <monto></monto>
  <debe></debe>
 <nodo/>
 <fecha></fecha>
 <usuario></usuario>
</transacx>
*/
END;
$_$;


--
-- TOC entry 276 (class 1255 OID 17289)
-- Dependencies: 5 816
-- Name: getallfoo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION getallfoo() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM scr_usuario
    WHERE id > 13
    LOOP
        INSERT INTO scr_usuario_rol(usuario_id, rol_id) VALUES (r.id, 1);
    END LOOP;
    RETURN 1;
END
$$;


--
-- TOC entry 277 (class 1255 OID 17290)
-- Dependencies: 816 5
-- Name: tgr_actualiza_contador(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_actualiza_contador() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que modifica lecturas despues de un cambio de contador.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2014.09.03
*/
DECLARE
  var BIGINT;
  dat BIGINT;
BEGIN  
  IF (TG_OP = 'OLD' OR TG_OP = 'UPDATE') THEN
    IF (NEW.contador <> OLD.contador) THEN
      SELECT id INTO var FROM scr_lectura WHERE (date_part('month', now())-date_part('month',"fechaLectura")) = 0 AND socio_id = OLD.id;
      --SELECT id INTO var FROM scr_lectura WHERE socio_id = OLD.id ORDER BY id DESC LIMIT 1;
      IF (var > 0) THEN
        --SELECT * FROM scr_det_factura WHERE limite_pago = (SELECT (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date)
        UPDATE scr_lectura SET "valorLectura"='0' WHERE id = var;
        SELECT id INTO var FROM scr_lectura WHERE (date_part('month', now())-date_part('month',"fechaLectura")) = 1 AND socio_id = OLD.id;
        UPDATE scr_lectura SET "valorLectura"='0' WHERE id = var;
      ELSE
        SELECT id INTO var FROM scr_lectura WHERE (date_part('month', now())-date_part('month',"fechaLectura")) = 1 AND socio_id = OLD.id;
        IF (var > 0) THEN
          UPDATE scr_lectura SET "valorLectura"='0' WHERE id = var;
        END IF;
      END IF;
      RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
      RETURN NEW;
      --
    END IF;
  ELSIF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  END IF;
END;
$$;


--
-- TOC entry 278 (class 1255 OID 17291)
-- Dependencies: 5 816
-- Name: tgr_actualiza_cuenta(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_actualiza_cuenta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que actualiza el monto (debe/haber) de una cuenta a partir de una transaccion.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2012.11.37
*/
BEGIN
  IF (TG_OP = 'INSERT') THEN
    IF (fcn_es_subcuenta(NEW.cuenta_id)) THEN
      IF (NEW."transaxDebeHaber") THEN
      UPDATE scr_cuenta SET "cuentaDebe" = "cuentaDebe" + NEW."transaxMonto" WHERE id = NEW.cuenta_id;
      ELSE
        UPDATE scr_cuenta SET "cuentaHaber" = "cuentaHaber" + NEW."transaxMonto" WHERE id = NEW.cuenta_id;
      END IF;
      RETURN NEW;
    ELSE
      RAISE EXCEPTION 'No se puede hacer registros en rubros, solo en sub-cuentas';
      RETURN NULL;
    END IF;
    RETURN NEW;
  END IF;
END;
$$;


--
-- TOC entry 279 (class 1255 OID 17292)
-- Dependencies: 816 5
-- Name: tgr_actualiza_rubro(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_actualiza_rubro() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que actualiza cuentas grupo o rubro
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2014.10.31
*/
DECLARE
  v_cuenta BIGINT;
  v_next BIGINT;
BEGIN
  v_cuenta := NEW.id;
  LOOP
      EXIT WHEN v_cuenta ISNULL;
      SELECT "cuentaCodigo" INTO v_next FROM scr_cuenta WHERE id = v_cuenta;
      IF (v_next >  9 AND v_next < 100) THEN
        UPDATE scr_cuenta SET "cuentaDebe" = "cuentaDebe" + NEW."cuentaDebe" - OLD."cuentaDebe", "cuentaHaber" = "cuentaHaber" + NEW."cuentaHaber" - OLD."cuentaHaber" WHERE id = v_cuenta;
        v_cuenta := NULL;
        --EXIT;
        RAISE EXCEPTION 'Se llego a la cuenta rubro y se actualizara con el monto de las subcuentas';
      ELSIF (v_next <10) THEN
        v_cuenta := NULL;
        --EXIT;
        RAISE EXCEPTION 'Cuenta grupo, no se actualizan saldos en esta cuenta';
      ELSE
        SELECT cat_cuenta_id INTO v_cuenta FROM scr_cuenta WHERE id = v_cuenta;
      END IF;
  END LOOP;
  RETURN NEW;
END
$$;


--
-- TOC entry 280 (class 1255 OID 17293)
-- Dependencies: 5 816
-- Name: tgr_agrega_costo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_agrega_costo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que agrega un costo a una factura (t) o no (f).
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2014.09.09
*/
DECLARE
  v_result INTEGER;
  v_valor DOUBLE PRECISION;
BEGIN
  --Se verifica el inicio del periodo contable
  IF (TG_OP = 'INSERT') THEN
    SELECT id INTO v_result FROM scr_det_factura WHERE id = NEW.factura_id AND cancelada = TRUE;
    RAISE INFO 'Entro a insert';
    IF v_result NOTNULL THEN
      RETURN NULL;
    ELSE
      SELECT id INTO v_result FROM scr_det_factura WHERE id = NEW.factura_id AND total = 0;
      IF v_result NOTNULL THEN
        RETURN NEW;
      ELSE
        --cobroValor
        SELECT c."cobroValor" INTO v_valor FROM scr_cobro AS c, scr_cat_cobro cc 
        WHERE c.cat_cobro_id = cc.id AND cc.id != 1 AND c.id = NEW.cobro_id;
        IF v_valor NOTNULL THEN
          RAISE INFO 'valor a sumar % - % - %', NEW.cantidad * v_result,NEW.cantidad, v_valor;
          UPDATE scr_det_factura SET total=total + NEW.cantidad * v_valor WHERE id=NEW.factura_id;
          RETURN NEW;
        ELSE
          RETURN NULL;
        END IF;
      END IF;
      RETURN NEW;
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    SELECT id INTO v_result FROM scr_det_factura WHERE id = NEW.factura_id AND cancelada = TRUE;
    IF v_result NOTNULL THEN
      RETURN NULL;
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
END;
$$;


--
-- TOC entry 281 (class 1255 OID 17294)
-- Dependencies: 816 5
-- Name: tgr_asigna_contador(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_asigna_contador() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que asigna correlativo de contador.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2014.09.03
*/
DECLARE
  var BIGINT;
  dat BIGINT;
BEGIN  
  IF (TG_OP = 'NEW' AND NEW.contador > 0) THEN
    RETURN NEW;
  ELSE
    RETURN NULL;
  END IF;
  EXCEPTION WHEN OTHERS THEN
    --RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', v_input;
    NEW.contador := NEW.id;
    RETURN NEW;
END;
$$;


--
-- TOC entry 282 (class 1255 OID 17295)
-- Dependencies: 816 5
-- Name: tgr_gestion_transacx(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_gestion_transacx() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que no permite modificar/eliminar las transacciones despues de registradas.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2012.11.26
*/
BEGIN
  IF (TG_OP = 'OLD' OR TG_OP = 'DELETE') THEN
    RETURN NULL;
  END IF;
END;
$$;


--
-- TOC entry 283 (class 1255 OID 17296)
-- Dependencies: 5 816
-- Name: tgr_inhabilita_mod_transax(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_inhabilita_mod_transax() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que inhabilita las actualizaciones de transacciones.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2012.10.19
*/
BEGIN
  RETURN NULL;
END
$$;


--
-- TOC entry 284 (class 1255 OID 17297)
-- Dependencies: 5 816
-- Name: tgr_verifica_activo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_verifica_activo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que actualiza el campo activo para las cuentas que son activo.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2012.10.16
*/
BEGIN
  IF (substring(NEW."cuentaCodigo"::TEXT from 1 for 1) = '1') THEN
    NEW."cuentaActivo" := 't';
    RAISE INFO 'Se actualiza cuenta a rubro activo';
  ELSE
    NEW."cuentaActivo" := 'f';
    RAISE INFO 'Se actualiza cuenta a pasivo/capital';
  END IF;
  RETURN NEW;
END
$$;


--
-- TOC entry 285 (class 1255 OID 17298)
-- Dependencies: 816 5
-- Name: tgr_verifica_cod_cuenta(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_verifica_cod_cuenta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que  el campo del codigo de una cuenta.
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2012.10.17
*/
DECLARE
  v_codigo TEXT;
  v_cuenta BIGINT;
BEGIN
  --Se verifica si es cuenta de mayor o sub cuenta
  IF (NEW.cat_cuenta_id ISNULL) THEN --Se verifica que si es una cuenta mayor
    SELECT COUNT(*) INTO v_cuenta FROM scr_cuenta WHERE "cuentaCodigo" <= 8; -- Se contabiliza el numero de cuentas mayores
    IF v_cuenta < 8 THEN --Se verifica que no existan cuentas mayores
      NEW."cuentaCodigo" := v_cuenta+1;
      RAISE INFO 'Se registrara una la cuenta [%] con codigo [%]',NEW."cuentaNombre" ,NEW."cuentaCodigo";
    ELSE
      RAISE EXCEPTION 'No esta permitido agregar cuentas de mayor [Habilite la opcion para generar cuentas acreedoras]';
      RETURN NULL;
    END IF;
  ELSE
    --Se genera el codigo para las sub cuentas
    SELECT "cuentaCodigo" INTO v_cuenta FROM scr_cuenta WHERE id = NEW.cat_cuenta_id;
    --Se verifica si es cuenta de orden mayor
    --IF (character_length(v_cuenta::TEXT)<= 3) THEN
    --  IF (character_length(NEW."cuentaCodigo"::TEXT) BETWEEN 2 AND 4) THEN
    --    RETURN NEW;
    --  ELSE
    --    RAISE EXCEPTION 'Cuenta con codigo invalido';
    --    RETURN NULL;
    --  END IF;
    --END IF;
    NEW."cuentaCodigo" := v_cuenta;
    RAISE INFO '% - %',  NEW."cuentaCodigo", v_cuenta;
    SELECT COUNT(*) INTO v_cuenta FROM (
      SELECT COUNT(*) FROM scr_cuenta group by "cuentaCodigo" having ("cuentaCodigo"/v_cuenta)::BIGINT = 100 
    ) AS List;
    SELECT COUNT(*) INTO v_cuenta FROM scr_cuenta where cat_cuenta_id = NEW.cat_cuenta_id group by cat_cuenta_id;
    RAISE INFO '% - %',  NEW."cuentaCodigo", v_cuenta;
    IF (v_cuenta ISNULL) THEN
      v_cuenta := 0;
    END IF;
    v_cuenta := v_cuenta + 1;
    IF (character_length(NEW."cuentaCodigo"::TEXT)< 3) THEN
      NEW."cuentaCodigo" := (NEW."cuentaCodigo"::TEXT||v_cuenta::TEXT)::BIGINT;
    ELSE
      NEW."cuentaCodigo" := (NEW."cuentaCodigo"::TEXT||'0'||v_cuenta::TEXT)::BIGINT;
    END IF;
    RAISE INFO 'Se registrara la sub-cuenta [%] con codigo [%]',NEW."cuentaNombre" ,NEW."cuentaCodigo";
  END IF;
  --Clasificacion de cuentas de activo
  IF (substring(NEW."cuentaCodigo"::TEXT from 1 for 1) = '1') THEN
    NEW."cuentaActivo" := 't';
    RAISE INFO 'Se actualiza cuenta a rubro activo';
  ELSE
    NEW."cuentaActivo" := 'f';
    RAISE INFO 'Se actualiza cuenta a pasivo/capital';
  END IF;
  RETURN NEW;
END
$$;


--
-- TOC entry 286 (class 1255 OID 17299)
-- Dependencies: 816 5
-- Name: tgr_verifica_tcontable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_verifica_tcontable() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que verifica su un periodo contable es valido (t) o no(f).
 *Acceso: Público.
 *Autor: William Vides - wilx.sv@gmail.com
 *Fecha: 2012.10.18
*/
DECLARE
  v_result INTEGER;
BEGIN
  --Se verifica el inicio del periodo contable
  IF (TG_OP = 'INSERT') THEN
    SELECT id INTO v_result FROM scr_det_contable WHERE id != NEW.id AND "dConFinPeriodo" > NEW."dConIniPeriodo";
    IF v_result NOTNULL THEN
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
    --Se verifica que solo exista un solo periodo contable activo
    IF (NEW."dConActivo" IS TRUE) THEN
      SELECT COUNT(*) INTO v_result FROM scr_det_contable WHERE id != NEW.id AND "dConActivo" IS TRUE;
      IF v_result = 0 THEN
        RETURN NEW;
      ELSE
        RETURN NULL;
      END IF;
    END IF;
  ELSIF (TG_OP = 'UPDATE' AND OLD."dConActivo" IS TRUE) THEN
    NEW."dConIniPeriodo" := OLD."dConIniPeriodo";
    NEW."dConPagoXMes" := OLD."dConPagoXMes";
    NEW.organizacion_id := OLD.organizacion_id;
    SELECT id INTO v_result FROM scr_det_contable WHERE NEW."dConFinPeriodo" >= OLD."dConIniPeriodo";
    IF v_result NOTNULL THEN
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
END;
$$;


--
-- TOC entry 287 (class 1255 OID 17300)
-- Dependencies: 816 5
-- Name: tgr_verificar_tiempo_act(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tgr_verificar_tiempo_act() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/**
 *Función que verifica el tiempo de las subactividades y de la actividad macro.
 *Acceso: Público.
 *Autor: Mario Menjivar - mariomenjivar12@gmail.com
 *Fecha: 2012.09.28
*/
DECLARE
   act_padre RECORD;

   id_hermanas integer[];
   act_hermana RECORD;

   sum_dur_sub_act interval; /*Suma de duración subactividades*/

   duracion_new interval;
   duracion_padre interval;

   num_hermanas double precision;
BEGIN

   SELECT * INTO act_padre FROM scr_actividad WHERE id = NEW.actividad_id; /*Selecionamos al padre de NEW*/
   duracion_new := age(NEW."actividadFin", NEW."actividadInicio"); /*Obtenemos el intervalo de fechas de NEW*/
   IF duracion_new > age(act_padre."actividadFin", act_padre."actividadInicio") THEN
      RETURN NULL;
   ELSE

      SELECT count(*) INTO num_hermanas FROM scr_actividad WHERE actividad_id = NEW.actividad_id; /*Contamos hermanos new*/
      SELECT id INTO id_hermanas FROM scr_actividad WHERE actividad_id = NEW.actividad_id;	

      /*Obtenemos la sumatoria de los intervalos de los hermanos de NEW*/
      FOR i IN 1 .. num_hermanas LOOP
         SELECT * INTO act_hermana FROM scr_actividad WHERE actividad_id = id_hermanas[i];
         sum_dur_sub_act := sum_dur_sub_act + age(act_hermana[i]."actividadFin", act_hermana[i]."actividadInicio");
      END LOOP;
      
      /*Por último, verificamos si es válido*/
      IF (sum_dur_sub_act + duracion_new) > duracion_padre THEN
         RETURN NULL;
      ELSE
         RETURN NEW;
      END IF;
   END IF;
END
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 161 (class 1259 OID 17301)
-- Dependencies: 5
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- TOC entry 162 (class 1259 OID 17304)
-- Dependencies: 2079 2080 2082 2083 5
-- Name: scr_actividad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_actividad (
    id bigint NOT NULL,
    "actividadNombre" character varying(150) NOT NULL,
    "actividadDescripcion" text,
    "actividadInicio" date NOT NULL,
    "actividadFin" date NOT NULL,
    "actividadPresupuesto" double precision DEFAULT 0 NOT NULL,
    actividad_id bigint,
    cat_actividad_id bigint NOT NULL,
    "actividadEjecutado" numeric(3,2) DEFAULT 0 NOT NULL,
    proyecto_id bigint NOT NULL,
    CONSTRAINT "CK_actividad_ejecutado" CHECK ((("actividadEjecutado" >= (0)::numeric) AND ("actividadEjecutado" <= (100)::numeric))),
    CONSTRAINT "CK_valor_actividad" CHECK (("actividadPresupuesto" > (0)::double precision))
);


--
-- TOC entry 2598 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN scr_actividad."actividadPresupuesto"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN scr_actividad."actividadPresupuesto" IS 'presupuesto';


--
-- TOC entry 163 (class 1259 OID 17314)
-- Dependencies: 5 162
-- Name: scr_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2599 (class 0 OID 0)
-- Dependencies: 163
-- Name: scr_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_actividad_id_seq OWNED BY scr_actividad.id;


--
-- TOC entry 164 (class 1259 OID 17316)
-- Dependencies: 5
-- Name: scr_area_trabajo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_area_trabajo (
    id bigint NOT NULL,
    "aTrabajoNombre" character varying(150) NOT NULL,
    "aTrabajoDescripcion" text,
    area_trabajo_id bigint,
    organizacion_id bigint NOT NULL,
    cargo_id bigint NOT NULL
);


--
-- TOC entry 165 (class 1259 OID 17322)
-- Dependencies: 164 5
-- Name: scr_area_de_trabajo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_area_de_trabajo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2600 (class 0 OID 0)
-- Dependencies: 165
-- Name: scr_area_de_trabajo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_area_de_trabajo_id_seq OWNED BY scr_area_trabajo.id;


--
-- TOC entry 166 (class 1259 OID 17324)
-- Dependencies: 5
-- Name: scr_banco; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_banco (
    id bigint NOT NULL,
    banco_nombre character varying(100) NOT NULL
);


--
-- TOC entry 167 (class 1259 OID 17327)
-- Dependencies: 166 5
-- Name: scr_banco_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_banco_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2601 (class 0 OID 0)
-- Dependencies: 167
-- Name: scr_banco_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_banco_id_seq OWNED BY scr_banco.id;


--
-- TOC entry 168 (class 1259 OID 17329)
-- Dependencies: 2086 2087 2088 2089 2090 2091 5
-- Name: scr_bombeo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_bombeo (
    id bigint NOT NULL,
    fecha date DEFAULT ('now'::text)::date NOT NULL,
    bombeo_inicio time without time zone NOT NULL,
    bombeo_fin time without time zone NOT NULL,
    voltaje double precision DEFAULT 0 NOT NULL,
    amperaje double precision DEFAULT 0 NOT NULL,
    presion double precision DEFAULT 0 NOT NULL,
    lectura double precision DEFAULT 0 NOT NULL,
    produccion double precision DEFAULT 0 NOT NULL,
    empleado_id bigint NOT NULL
)
WITH (autovacuum_enabled=true);


--
-- TOC entry 169 (class 1259 OID 17338)
-- Dependencies: 168 5
-- Name: scr_bombeo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_bombeo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2602 (class 0 OID 0)
-- Dependencies: 169
-- Name: scr_bombeo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_bombeo_id_seq OWNED BY scr_bombeo.id;


--
-- TOC entry 170 (class 1259 OID 17340)
-- Dependencies: 2093 2095 5
-- Name: scr_cargo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cargo (
    id bigint NOT NULL,
    "cargoNombre" character varying(150) NOT NULL,
    "cargoDescripcion" text,
    "cargoSalario" double precision DEFAULT 1 NOT NULL,
    cargo_id bigint,
    CONSTRAINT "CK_cargoSalario" CHECK (("cargoSalario" > (1)::double precision))
);


--
-- TOC entry 171 (class 1259 OID 17348)
-- Dependencies: 5 170
-- Name: scr_cargo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_cargo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2603 (class 0 OID 0)
-- Dependencies: 171
-- Name: scr_cargo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_cargo_id_seq OWNED BY scr_cargo.id;


--
-- TOC entry 172 (class 1259 OID 17350)
-- Dependencies: 5
-- Name: scr_cat_actividad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_actividad (
    id bigint NOT NULL,
    "cActividadNombre" character varying(150) NOT NULL,
    "catActividadDescripcion" text
);


--
-- TOC entry 173 (class 1259 OID 17356)
-- Dependencies: 5 172
-- Name: scr_tipo_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_tipo_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2604 (class 0 OID 0)
-- Dependencies: 173
-- Name: scr_tipo_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_tipo_actividad_id_seq OWNED BY scr_cat_actividad.id;


--
-- TOC entry 174 (class 1259 OID 17358)
-- Dependencies: 2097 5
-- Name: scr_cat_cobro; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_cobro (
    id bigint DEFAULT nextval('scr_tipo_actividad_id_seq'::regclass) NOT NULL,
    "cCobroNombre" character varying(150) NOT NULL,
    "cCobroDescripcion" text
);


--
-- TOC entry 175 (class 1259 OID 17365)
-- Dependencies: 5
-- Name: scr_cat_cooperante; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_cooperante (
    id bigint NOT NULL,
    "catCoopNombre" character varying(100) NOT NULL,
    "catCoopDescrip" text
);


--
-- TOC entry 176 (class 1259 OID 17371)
-- Dependencies: 5
-- Name: scr_cat_depreciacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_depreciacion (
    id bigint NOT NULL,
    "depreciacionNombre" character varying(100) NOT NULL,
    "depreciacionDescripcion" text
);


--
-- TOC entry 177 (class 1259 OID 17377)
-- Dependencies: 5
-- Name: scr_cat_organizacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_organizacion (
    id bigint NOT NULL,
    "cOrgNombre" character varying(150) NOT NULL,
    "cOrgDescripcion" text
);


--
-- TOC entry 178 (class 1259 OID 17383)
-- Dependencies: 5
-- Name: scr_cat_produc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_produc (
    id bigint NOT NULL,
    "catProducNombre" character varying(100) NOT NULL,
    "catProducDescrip" text
);


--
-- TOC entry 179 (class 1259 OID 17389)
-- Dependencies: 2102 2103 5
-- Name: scr_cat_rep_legal; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cat_rep_legal (
    id bigint NOT NULL,
    "catRLegalNombre" character varying(150) NOT NULL,
    "catRLegalDescripcion" text,
    "catRLegalRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "catRLegalFirma" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 2605 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN scr_cat_rep_legal."catRLegalFirma"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN scr_cat_rep_legal."catRLegalFirma" IS 'Usuario habilitado para firmar estados financieros';


--
-- TOC entry 180 (class 1259 OID 17397)
-- Dependencies: 5
-- Name: scr_cheq_recurso; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cheq_recurso (
    id bigint NOT NULL,
    cheq_rr_codigo bigint NOT NULL,
    cheq_rr_quien_recibe character varying(100) NOT NULL,
    cheq_rr_fecha_emision timestamp without time zone NOT NULL,
    cheq_rr_fecha_vence timestamp without time zone NOT NULL,
    chequera_id bigint NOT NULL
);


--
-- TOC entry 181 (class 1259 OID 17400)
-- Dependencies: 180 5
-- Name: scr_cheq_recurso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_cheq_recurso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2606 (class 0 OID 0)
-- Dependencies: 181
-- Name: scr_cheq_recurso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_cheq_recurso_id_seq OWNED BY scr_cheq_recurso.id;


--
-- TOC entry 182 (class 1259 OID 17402)
-- Dependencies: 5
-- Name: scr_chequera; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_chequera (
    id bigint NOT NULL,
    chequera_correlativo bigint NOT NULL,
    banco_id bigint
);


--
-- TOC entry 183 (class 1259 OID 17405)
-- Dependencies: 5 182
-- Name: scr_chequera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_chequera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2607 (class 0 OID 0)
-- Dependencies: 183
-- Name: scr_chequera_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_chequera_id_seq OWNED BY scr_chequera.id;


--
-- TOC entry 184 (class 1259 OID 17407)
-- Dependencies: 2107 2109 5
-- Name: scr_cloracion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cloracion (
    id bigint NOT NULL,
    fecha date NOT NULL,
    hora time without time zone NOT NULL,
    gramos double precision NOT NULL,
    localidad_id bigint NOT NULL,
    empleado_id bigint NOT NULL,
    observacion text DEFAULT 'ninguna'::text NOT NULL,
    CONSTRAINT "CK_gramos_positivos" CHECK ((gramos >= (0)::double precision))
)
WITH (autovacuum_enabled=true);


--
-- TOC entry 185 (class 1259 OID 17415)
-- Dependencies: 5 184
-- Name: scr_cloracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_cloracion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2608 (class 0 OID 0)
-- Dependencies: 185
-- Name: scr_cloracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_cloracion_id_seq OWNED BY scr_cloracion.id;


--
-- TOC entry 186 (class 1259 OID 17417)
-- Dependencies: 2110 2111 5
-- Name: scr_cobro; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cobro (
    id bigint NOT NULL,
    "cobroNombre" character varying(150) NOT NULL,
    "cobroCodigo" character varying(10) NOT NULL,
    "cobroDescripcion" text,
    "cobroInicio" double precision NOT NULL,
    "cobroFin" double precision NOT NULL,
    "cobroValor" double precision DEFAULT 0 NOT NULL,
    "cobroPermanente" boolean DEFAULT false NOT NULL,
    cat_cobro_id bigint NOT NULL
);


--
-- TOC entry 187 (class 1259 OID 17425)
-- Dependencies: 186 5
-- Name: scr_cobro_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_cobro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2609 (class 0 OID 0)
-- Dependencies: 187
-- Name: scr_cobro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_cobro_id_seq OWNED BY scr_cobro.id;


--
-- TOC entry 188 (class 1259 OID 17427)
-- Dependencies: 2113 2114 5
-- Name: scr_consumo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_consumo (
    id bigint NOT NULL,
    registro timestamp without time zone DEFAULT now() NOT NULL,
    cantidad double precision DEFAULT 0 NOT NULL,
    cobro_id bigint NOT NULL,
    factura_id bigint NOT NULL
);


--
-- TOC entry 189 (class 1259 OID 17432)
-- Dependencies: 188 5
-- Name: scr_consumo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_consumo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2610 (class 0 OID 0)
-- Dependencies: 189
-- Name: scr_consumo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_consumo_id_seq OWNED BY scr_consumo.id;


--
-- TOC entry 190 (class 1259 OID 17434)
-- Dependencies: 5
-- Name: scr_cooperante; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cooperante (
    id bigint NOT NULL,
    "cooperanteNombre" character varying(100) NOT NULL,
    "cooperanteDescripcion" text,
    "catCooperante_id" bigint NOT NULL
);


--
-- TOC entry 191 (class 1259 OID 17440)
-- Dependencies: 190 5
-- Name: scr_cooperante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_cooperante_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2611 (class 0 OID 0)
-- Dependencies: 191
-- Name: scr_cooperante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_cooperante_id_seq OWNED BY scr_cooperante.id;


--
-- TOC entry 192 (class 1259 OID 17442)
-- Dependencies: 2117 2118 2119 2120 2121 2122 2124 5
-- Name: scr_cuenta; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_cuenta (
    id bigint NOT NULL,
    "cuentaNombre" character varying(150) NOT NULL,
    "cuentaRegistro" timestamp without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    "cuentaDebe" double precision DEFAULT 0 NOT NULL,
    "cuentaHaber" double precision DEFAULT 0 NOT NULL,
    cat_cuenta_id integer,
    "cuentaActivo" boolean DEFAULT false NOT NULL,
    "cuentaCodigo" bigint DEFAULT 0 NOT NULL,
    "cuentaDescripcion" text,
    "cuentaNegativa" boolean DEFAULT false NOT NULL,
    CONSTRAINT "CK_valores_positivos" CHECK (((("cuentaDebe" >= (0)::double precision) AND ("cuentaHaber" >= (0)::double precision)) AND ("cuentaCodigo" > (0)::bigint)))
);


--
-- TOC entry 193 (class 1259 OID 17455)
-- Dependencies: 192 5
-- Name: scr_cuenta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_cuenta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2612 (class 0 OID 0)
-- Dependencies: 193
-- Name: scr_cuenta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_cuenta_id_seq OWNED BY scr_cuenta.id;


--
-- TOC entry 194 (class 1259 OID 17457)
-- Dependencies: 2125 2126 2127 2129 2130 5
-- Name: scr_det_contable; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_det_contable (
    id bigint NOT NULL,
    "dConIniPeriodo" date NOT NULL,
    "dConFinPeriodo" date NOT NULL,
    "dConActivo" boolean DEFAULT false NOT NULL,
    "dConSimboloMoneda" character varying(3) DEFAULT '$'::character varying NOT NULL,
    "dConPagoXMes" smallint DEFAULT 1 NOT NULL,
    organizacion_id bigint NOT NULL,
    empleado_id bigint NOT NULL,
    CONSTRAINT "CK_fechasValidas" CHECK (("dConIniPeriodo" < "dConFinPeriodo")),
    CONSTRAINT "CK_pagos_x_mes" CHECK (("dConPagoXMes" > 0))
);


--
-- TOC entry 2613 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN scr_det_contable."dConIniPeriodo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN scr_det_contable."dConIniPeriodo" IS 'Inicio de periodo contable';


--
-- TOC entry 2614 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN scr_det_contable."dConFinPeriodo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN scr_det_contable."dConFinPeriodo" IS 'Fin de periodo contable';


--
-- TOC entry 2615 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN scr_det_contable."dConActivo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN scr_det_contable."dConActivo" IS 'activo mientras no se cierra el periodo contable';


--
-- TOC entry 2616 (class 0 OID 0)
-- Dependencies: 194
-- Name: CONSTRAINT "CK_fechasValidas" ON scr_det_contable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT "CK_fechasValidas" ON scr_det_contable IS 'Verifica que el fin no sea menor a inicio y que el inicio no sea menor a un fin ya registrado.';


--
-- TOC entry 195 (class 1259 OID 17465)
-- Dependencies: 5
-- Name: scr_factura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_factura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


--
-- TOC entry 196 (class 1259 OID 17467)
-- Dependencies: 2131 2132 2133 2134 5
-- Name: scr_det_factura; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_det_factura (
    id bigint NOT NULL,
    det_factur_numero bigint DEFAULT nextval('scr_factura_id_seq'::regclass) NOT NULL,
    det_factur_fecha timestamp without time zone DEFAULT now() NOT NULL,
    socio_id bigint NOT NULL,
    cancelada boolean DEFAULT false NOT NULL,
    fecha_cancelada timestamp without time zone,
    total double precision DEFAULT 0 NOT NULL,
    limite_pago date NOT NULL
)
WITH (autovacuum_enabled=true);


--
-- TOC entry 197 (class 1259 OID 17474)
-- Dependencies: 5 196
-- Name: scr_det_factura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_det_factura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2617 (class 0 OID 0)
-- Dependencies: 197
-- Name: scr_det_factura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_det_factura_id_seq OWNED BY scr_det_factura.id;


--
-- TOC entry 198 (class 1259 OID 17476)
-- Dependencies: 5 194
-- Name: scr_detalle_org_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_detalle_org_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2618 (class 0 OID 0)
-- Dependencies: 198
-- Name: scr_detalle_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_detalle_org_id_seq OWNED BY scr_det_contable.id;


--
-- TOC entry 199 (class 1259 OID 17478)
-- Dependencies: 2136 2137 597 5
-- Name: scr_empleado; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_empleado (
    id bigint NOT NULL,
    "empleadoNombre" character varying(150) NOT NULL,
    "empleadoApellido" character varying(150) NOT NULL,
    "empleadoTelefono" bigint NOT NULL,
    "empleadoCelular" bigint,
    "empleadoDireccion" text NOT NULL,
    "empleadoDui" bigint NOT NULL,
    "empleadoIsss" bigint NOT NULL,
    "empleadoRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "empleadoFechaIngreso" date NOT NULL,
    cargo_id bigint NOT NULL,
    "empleadoEmail" dominio_email NOT NULL,
    "empleadoNit" bigint NOT NULL,
    localidad_id bigint NOT NULL,
    usuario_id bigint DEFAULT 1 NOT NULL
);


--
-- TOC entry 2619 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN scr_empleado."empleadoRegistro"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN scr_empleado."empleadoRegistro" IS 'fecha de registro en el sistema';


--
-- TOC entry 200 (class 1259 OID 17486)
-- Dependencies: 5
-- Name: scr_empleado_actividad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_empleado_actividad (
    empleado_id bigint NOT NULL,
    actividad_id bigint NOT NULL
);


--
-- TOC entry 201 (class 1259 OID 17489)
-- Dependencies: 5 199
-- Name: scr_empleado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_empleado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2620 (class 0 OID 0)
-- Dependencies: 201
-- Name: scr_empleado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_empleado_id_seq OWNED BY scr_empleado.id;


--
-- TOC entry 202 (class 1259 OID 17491)
-- Dependencies: 5
-- Name: scr_estado; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_estado (
    id bigint NOT NULL,
    "nombreEstado" character varying(150) NOT NULL
);


--
-- TOC entry 203 (class 1259 OID 17494)
-- Dependencies: 5 202
-- Name: scr_estado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_estado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2621 (class 0 OID 0)
-- Dependencies: 203
-- Name: scr_estado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_estado_id_seq OWNED BY scr_estado.id;


--
-- TOC entry 204 (class 1259 OID 17496)
-- Dependencies: 5
-- Name: scr_his_rep_legal; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_his_rep_legal (
    id bigint NOT NULL,
    his_rep_leg_nombre character varying(150) NOT NULL,
    his_rep_leg_apellido character varying(150) NOT NULL,
    his_rep_leg_telefono bigint NOT NULL,
    his_rep_leg_celular bigint,
    his_rep_leg_email character varying(100),
    his_rep_leg_direccion character varying(200) NOT NULL,
    his_rep_leg_fecha_registro timestamp without time zone NOT NULL,
    representante_legal_id bigint NOT NULL
);


--
-- TOC entry 205 (class 1259 OID 17502)
-- Dependencies: 5 204
-- Name: scr_historial_representante_legal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_historial_representante_legal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2622 (class 0 OID 0)
-- Dependencies: 205
-- Name: scr_historial_representante_legal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_historial_representante_legal_id_seq OWNED BY scr_his_rep_legal.id;


--
-- TOC entry 206 (class 1259 OID 17504)
-- Dependencies: 2141 5
-- Name: scr_lectura; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_lectura (
    id bigint NOT NULL,
    "valorLectura" character varying(150) NOT NULL,
    "fechaLectura" date NOT NULL,
    "registroLectura" timestamp without time zone DEFAULT ('now'::text)::date NOT NULL,
    socio_id bigint NOT NULL,
    tecnico_id bigint NOT NULL
);


--
-- TOC entry 207 (class 1259 OID 17508)
-- Dependencies: 5 206
-- Name: scr_lectura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_lectura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2623 (class 0 OID 0)
-- Dependencies: 207
-- Name: scr_lectura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_lectura_id_seq OWNED BY scr_lectura.id;


--
-- TOC entry 208 (class 1259 OID 17510)
-- Dependencies: 2143 2145 5
-- Name: scr_linea_estrategica; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_linea_estrategica (
    id bigint NOT NULL,
    organizacion_id bigint NOT NULL,
    "lEstrategicaNombre" character varying(150) NOT NULL,
    "lEstrategicaDescripcion" text,
    "lEstrategicaInicio" date DEFAULT now() NOT NULL,
    "lEstrategicaFin" date NOT NULL,
    linea_estrategica_id bigint,
    CONSTRAINT "CK_periodo_lEstrategica" CHECK (("lEstrategicaFin" > "lEstrategicaInicio"))
);


--
-- TOC entry 209 (class 1259 OID 17518)
-- Dependencies: 5 208
-- Name: scr_lin_estrateg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_lin_estrateg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2624 (class 0 OID 0)
-- Dependencies: 209
-- Name: scr_lin_estrateg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_lin_estrateg_id_seq OWNED BY scr_linea_estrategica.id;


--
-- TOC entry 210 (class 1259 OID 17520)
-- Dependencies: 5
-- Name: scr_linea_proyecto; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_linea_proyecto (
    linea_estrategica_id bigint NOT NULL,
    proyecto_id bigint NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 17523)
-- Dependencies: 5
-- Name: scr_localidad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_localidad (
    id bigint NOT NULL,
    localidad_nombre character varying(150) NOT NULL,
    localidad_descripcion text,
    localidad_id bigint,
    localidad_lat double precision NOT NULL,
    localidad_lon double precision NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 17529)
-- Dependencies: 5 211
-- Name: scr_localidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_localidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2625 (class 0 OID 0)
-- Dependencies: 212
-- Name: scr_localidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_localidad_id_seq OWNED BY scr_localidad.id;


--
-- TOC entry 213 (class 1259 OID 17531)
-- Dependencies: 5
-- Name: scr_log; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_log (
    id bigint NOT NULL,
    src_fecha timestamp without time zone NOT NULL,
    src_descripcion text NOT NULL,
    usuario_id bigint NOT NULL
);


--
-- TOC entry 214 (class 1259 OID 17537)
-- Dependencies: 5
-- Name: scr_marca_produc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_marca_produc (
    id bigint NOT NULL,
    "marcaProducNombre" character varying(100) NOT NULL,
    "marcaProducDescrip" text
);


--
-- TOC entry 215 (class 1259 OID 17543)
-- Dependencies: 214 5
-- Name: scr_marca_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_marca_produc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2626 (class 0 OID 0)
-- Dependencies: 215
-- Name: scr_marca_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_marca_produc_id_seq OWNED BY scr_marca_produc.id;


--
-- TOC entry 216 (class 1259 OID 17545)
-- Dependencies: 5
-- Name: scr_organizacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_organizacion (
    id bigint NOT NULL,
    "organizacionNombre" character varying(150) NOT NULL,
    "organizacionDescripcion" text,
    localidad_id bigint NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 17551)
-- Dependencies: 5 216
-- Name: scr_organizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_organizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2627 (class 0 OID 0)
-- Dependencies: 217
-- Name: scr_organizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_organizacion_id_seq OWNED BY scr_organizacion.id;


--
-- TOC entry 218 (class 1259 OID 17553)
-- Dependencies: 2150 2151 2152 5
-- Name: scr_periodo_representante; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_periodo_representante (
    organizacion_id bigint NOT NULL,
    representante_legal_id bigint NOT NULL,
    "periodoInicio" date DEFAULT now() NOT NULL,
    "periodoFin" date NOT NULL,
    CONSTRAINT "CK_periodo_dentro" CHECK (((date_part('month'::text, age(("periodoFin")::timestamp without time zone, ("periodoInicio")::timestamp without time zone)) > (1)::double precision) AND (date_part('month'::text, age(("periodoFin")::timestamp without time zone, ("periodoInicio")::timestamp without time zone)) < (12)::double precision))),
    CONSTRAINT "CK_periodo_valido" CHECK (("periodoInicio" < "periodoFin"))
);


--
-- TOC entry 219 (class 1259 OID 17559)
-- Dependencies: 5
-- Name: scr_presen_produc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_presen_produc (
    id bigint NOT NULL,
    "presenProducNombre" character varying(100) NOT NULL,
    "presenProducDescrip" text
);


--
-- TOC entry 220 (class 1259 OID 17565)
-- Dependencies: 5 219
-- Name: scr_presen_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_presen_produc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2628 (class 0 OID 0)
-- Dependencies: 220
-- Name: scr_presen_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_presen_produc_id_seq OWNED BY scr_presen_produc.id;


--
-- TOC entry 221 (class 1259 OID 17567)
-- Dependencies: 5
-- Name: scr_producto; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_producto (
    id bigint NOT NULL,
    "productoNombre" character varying(100) NOT NULL,
    "productoDescripcion" text,
    marca_id bigint NOT NULL,
    "catProduc_id" bigint NOT NULL,
    u_medida_id bigint NOT NULL,
    presentacion_id bigint NOT NULL,
    "catDepresiacion_id" bigint NOT NULL,
    "productoComprobante" character varying(100) NOT NULL,
    proveedor_id bigint NOT NULL,
    "productoCodigo" text NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 17573)
-- Dependencies: 5
-- Name: scr_producto_area; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_producto_area (
    producto_id bigint NOT NULL,
    "areaTrabajo_id" bigint NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 17576)
-- Dependencies: 221 5
-- Name: scr_producto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2629 (class 0 OID 0)
-- Dependencies: 223
-- Name: scr_producto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_producto_id_seq OWNED BY scr_producto.id;


--
-- TOC entry 224 (class 1259 OID 17578)
-- Dependencies: 5
-- Name: scr_proveedor; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_proveedor (
    id bigint NOT NULL,
    "proveedorNombre" character varying(100) NOT NULL,
    "proveedorDescripcion" text
);


--
-- TOC entry 225 (class 1259 OID 17584)
-- Dependencies: 224 5
-- Name: scr_proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_proveedor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2630 (class 0 OID 0)
-- Dependencies: 225
-- Name: scr_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_proveedor_id_seq OWNED BY scr_proveedor.id;


--
-- TOC entry 226 (class 1259 OID 17586)
-- Dependencies: 5
-- Name: scr_proyecto; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_proyecto (
    id bigint NOT NULL,
    "proyectoNombre" character varying(100) NOT NULL,
    "proyectoDescrip" text,
    cooperante_id bigint NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 17592)
-- Dependencies: 5 226
-- Name: scr_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_proyecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2631 (class 0 OID 0)
-- Dependencies: 227
-- Name: scr_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_proyecto_id_seq OWNED BY scr_proyecto.id;


--
-- TOC entry 228 (class 1259 OID 17594)
-- Dependencies: 5
-- Name: scr_recibo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_recibo (
    id bigint NOT NULL,
    recibonumero bigint NOT NULL,
    recibocuenta bigint NOT NULL,
    recibosocio text NOT NULL,
    recibolecturax text NOT NULL,
    recibolecturay text NOT NULL,
    recibofecha timestamp without time zone NOT NULL,
    usuario_id bigint NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 17600)
-- Dependencies: 228 5
-- Name: scr_recibo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_recibo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2632 (class 0 OID 0)
-- Dependencies: 229
-- Name: scr_recibo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_recibo_id_seq OWNED BY scr_recibo.id;


--
-- TOC entry 230 (class 1259 OID 17602)
-- Dependencies: 2158 5 597
-- Name: scr_representante_legal; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_representante_legal (
    id bigint NOT NULL,
    "rLegalNombre" character varying(150) NOT NULL,
    "rLegalApellido" character varying(150) NOT NULL,
    "rLegalTelefono" bigint NOT NULL,
    "rLegalCelular" bigint,
    "rLegalDireccion" text NOT NULL,
    "rLegalRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    cat_rep_legal_id bigint NOT NULL,
    "rLegalemail" dominio_email NOT NULL
);


--
-- TOC entry 231 (class 1259 OID 17609)
-- Dependencies: 5 230
-- Name: scr_representate_legal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_representate_legal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2633 (class 0 OID 0)
-- Dependencies: 231
-- Name: scr_representate_legal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_representate_legal_id_seq OWNED BY scr_representante_legal.id;


--
-- TOC entry 232 (class 1259 OID 17611)
-- Dependencies: 5
-- Name: scr_rol; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_rol (
    id integer NOT NULL,
    nombrerol character varying(75) NOT NULL,
    detallerol text
);


--
-- TOC entry 233 (class 1259 OID 17617)
-- Dependencies: 5
-- Name: scr_rr_ejecucion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_rr_ejecucion (
    id bigint NOT NULL,
    solic_rr_id bigint NOT NULL,
    empleado_id bigint NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 17620)
-- Dependencies: 233 5
-- Name: scr_rr_ejecucion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_rr_ejecucion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2634 (class 0 OID 0)
-- Dependencies: 234
-- Name: scr_rr_ejecucion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_rr_ejecucion_id_seq OWNED BY scr_rr_ejecucion.id;


--
-- TOC entry 235 (class 1259 OID 17622)
-- Dependencies: 176 5
-- Name: scr_tip_depresiacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_tip_depresiacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2635 (class 0 OID 0)
-- Dependencies: 235
-- Name: scr_tip_depresiacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_tip_depresiacion_id_seq OWNED BY scr_cat_depreciacion.id;


--
-- TOC entry 236 (class 1259 OID 17624)
-- Dependencies: 5 175
-- Name: scr_tipo_cooperante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_tipo_cooperante_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2636 (class 0 OID 0)
-- Dependencies: 236
-- Name: scr_tipo_cooperante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_tipo_cooperante_id_seq OWNED BY scr_cat_cooperante.id;


--
-- TOC entry 237 (class 1259 OID 17626)
-- Dependencies: 178 5
-- Name: scr_tipo_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_tipo_produc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2637 (class 0 OID 0)
-- Dependencies: 237
-- Name: scr_tipo_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_tipo_produc_id_seq OWNED BY scr_cat_produc.id;


--
-- TOC entry 238 (class 1259 OID 17628)
-- Dependencies: 2162 2163 2164 2165 2166 2168 2169 5
-- Name: scr_transaccion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_transaccion (
    id bigint NOT NULL,
    "transaxSecuencia" bigint NOT NULL,
    cuenta_id bigint NOT NULL,
    "transaxMonto" double precision DEFAULT 0 NOT NULL,
    "transaxDebeHaber" boolean DEFAULT true NOT NULL,
    empleado_id bigint NOT NULL,
    "transaxRegistro" timestamp without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    "transaxFecha" date NOT NULL,
    pcontable_id bigint NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    comentario text DEFAULT 'Sin detalle'::text,
    "transaxImg" text,
    CONSTRAINT "CK_monto_positivo" CHECK (("transaxMonto" > (0)::double precision)),
    CONSTRAINT "CK_secuencia_positiva" CHECK (("transaxSecuencia" > 0))
);


--
-- TOC entry 239 (class 1259 OID 17641)
-- Dependencies: 5 238
-- Name: scr_transaccion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_transaccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2638 (class 0 OID 0)
-- Dependencies: 239
-- Name: scr_transaccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_transaccion_id_seq OWNED BY scr_transaccion.id;


--
-- TOC entry 240 (class 1259 OID 17643)
-- Dependencies: 5
-- Name: scr_u_medida_produc; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_u_medida_produc (
    id bigint NOT NULL,
    "uMedidaProducNombre" character varying(100) NOT NULL,
    "uMedidaProducDescrip" text
);


--
-- TOC entry 241 (class 1259 OID 17649)
-- Dependencies: 240 5
-- Name: scr_u_medida_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scr_u_medida_produc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2639 (class 0 OID 0)
-- Dependencies: 241
-- Name: scr_u_medida_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scr_u_medida_produc_id_seq OWNED BY scr_u_medida_produc.id;


--
-- TOC entry 242 (class 1259 OID 17651)
-- Dependencies: 2171 2172 2173 2174 2175 2176 601 597 599 5
-- Name: scr_usuario; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_usuario (
    id bigint NOT NULL,
    username character varying(50) NOT NULL,
    password text NOT NULL,
    correousuario dominio_email NOT NULL,
    detalleuuario text,
    ultimavisitausuario timestamp without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    ipusuario dominio_ip DEFAULT '127.0.0.1'::character varying NOT NULL,
    salt text NOT NULL,
    nombreusuario character varying(150) NOT NULL,
    apellidousuario character varying(150) NOT NULL,
    telefonousuario bigint NOT NULL,
    nacimientousuario date,
    latusuario double precision NOT NULL,
    lonusuario double precision NOT NULL,
    direccionusuario text,
    sexousuario numeric(1,0) DEFAULT 0 NOT NULL,
    registrousuario timestamp without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    cuentausuario dominio_xml DEFAULT '<cuentas><anda>0000</anda></cuentas>'::text NOT NULL,
    estado_id bigint NOT NULL,
    localidad_id bigint NOT NULL,
    imagenusuario text,
    contador text DEFAULT 'x'::text NOT NULL
);


--
-- TOC entry 243 (class 1259 OID 17663)
-- Dependencies: 5
-- Name: scr_usuario_rol; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scr_usuario_rol (
    usuario_id bigint NOT NULL,
    rol_id bigint NOT NULL
);


--
-- TOC entry 244 (class 1259 OID 17666)
-- Dependencies: 5 213
-- Name: src_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE src_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2640 (class 0 OID 0)
-- Dependencies: 244
-- Name: src_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE src_log_id_seq OWNED BY scr_log.id;


--
-- TOC entry 245 (class 1259 OID 17668)
-- Dependencies: 5 232
-- Name: src_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE src_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2641 (class 0 OID 0)
-- Dependencies: 245
-- Name: src_rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE src_rol_id_seq OWNED BY scr_rol.id;


--
-- TOC entry 246 (class 1259 OID 17670)
-- Dependencies: 5 179
-- Name: src_tip_rep_legal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE src_tip_rep_legal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2642 (class 0 OID 0)
-- Dependencies: 246
-- Name: src_tip_rep_legal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE src_tip_rep_legal_id_seq OWNED BY scr_cat_rep_legal.id;


--
-- TOC entry 247 (class 1259 OID 17672)
-- Dependencies: 5 177
-- Name: src_tipo_org_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE src_tipo_org_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2643 (class 0 OID 0)
-- Dependencies: 247
-- Name: src_tipo_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE src_tipo_org_id_seq OWNED BY scr_cat_organizacion.id;


--
-- TOC entry 248 (class 1259 OID 17674)
-- Dependencies: 242 5
-- Name: src_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE src_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2644 (class 0 OID 0)
-- Dependencies: 248
-- Name: src_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE src_usuario_id_seq OWNED BY scr_usuario.id;


--
-- TOC entry 2081 (class 2604 OID 17676)
-- Dependencies: 163 162
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_actividad ALTER COLUMN id SET DEFAULT nextval('scr_actividad_id_seq'::regclass);


--
-- TOC entry 2084 (class 2604 OID 17677)
-- Dependencies: 165 164
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_area_trabajo ALTER COLUMN id SET DEFAULT nextval('scr_area_de_trabajo_id_seq'::regclass);


--
-- TOC entry 2085 (class 2604 OID 17678)
-- Dependencies: 167 166
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_banco ALTER COLUMN id SET DEFAULT nextval('scr_banco_id_seq'::regclass);


--
-- TOC entry 2092 (class 2604 OID 17679)
-- Dependencies: 169 168
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_bombeo ALTER COLUMN id SET DEFAULT nextval('scr_bombeo_id_seq'::regclass);


--
-- TOC entry 2094 (class 2604 OID 17680)
-- Dependencies: 171 170
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cargo ALTER COLUMN id SET DEFAULT nextval('scr_cargo_id_seq'::regclass);


--
-- TOC entry 2096 (class 2604 OID 17681)
-- Dependencies: 173 172
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cat_actividad ALTER COLUMN id SET DEFAULT nextval('scr_tipo_actividad_id_seq'::regclass);


--
-- TOC entry 2098 (class 2604 OID 17682)
-- Dependencies: 236 175
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cat_cooperante ALTER COLUMN id SET DEFAULT nextval('scr_tipo_cooperante_id_seq'::regclass);


--
-- TOC entry 2099 (class 2604 OID 17683)
-- Dependencies: 235 176
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cat_depreciacion ALTER COLUMN id SET DEFAULT nextval('scr_tip_depresiacion_id_seq'::regclass);


--
-- TOC entry 2100 (class 2604 OID 17684)
-- Dependencies: 247 177
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cat_organizacion ALTER COLUMN id SET DEFAULT nextval('src_tipo_org_id_seq'::regclass);


--
-- TOC entry 2101 (class 2604 OID 17685)
-- Dependencies: 237 178
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cat_produc ALTER COLUMN id SET DEFAULT nextval('scr_tipo_produc_id_seq'::regclass);


--
-- TOC entry 2104 (class 2604 OID 17686)
-- Dependencies: 246 179
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cat_rep_legal ALTER COLUMN id SET DEFAULT nextval('src_tip_rep_legal_id_seq'::regclass);


--
-- TOC entry 2105 (class 2604 OID 17687)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cheq_recurso ALTER COLUMN id SET DEFAULT nextval('scr_cheq_recurso_id_seq'::regclass);


--
-- TOC entry 2106 (class 2604 OID 17688)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_chequera ALTER COLUMN id SET DEFAULT nextval('scr_chequera_id_seq'::regclass);


--
-- TOC entry 2108 (class 2604 OID 17689)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cloracion ALTER COLUMN id SET DEFAULT nextval('scr_cloracion_id_seq'::regclass);


--
-- TOC entry 2112 (class 2604 OID 17690)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cobro ALTER COLUMN id SET DEFAULT nextval('scr_cobro_id_seq'::regclass);


--
-- TOC entry 2115 (class 2604 OID 17691)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_consumo ALTER COLUMN id SET DEFAULT nextval('scr_consumo_id_seq'::regclass);


--
-- TOC entry 2116 (class 2604 OID 17692)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cooperante ALTER COLUMN id SET DEFAULT nextval('scr_cooperante_id_seq'::regclass);


--
-- TOC entry 2123 (class 2604 OID 17693)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cuenta ALTER COLUMN id SET DEFAULT nextval('scr_cuenta_id_seq'::regclass);


--
-- TOC entry 2128 (class 2604 OID 17694)
-- Dependencies: 198 194
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_det_contable ALTER COLUMN id SET DEFAULT nextval('scr_detalle_org_id_seq'::regclass);


--
-- TOC entry 2135 (class 2604 OID 17695)
-- Dependencies: 197 196
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_det_factura ALTER COLUMN id SET DEFAULT nextval('scr_det_factura_id_seq'::regclass);


--
-- TOC entry 2138 (class 2604 OID 17696)
-- Dependencies: 201 199
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_empleado ALTER COLUMN id SET DEFAULT nextval('scr_empleado_id_seq'::regclass);


--
-- TOC entry 2139 (class 2604 OID 17697)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_estado ALTER COLUMN id SET DEFAULT nextval('scr_estado_id_seq'::regclass);


--
-- TOC entry 2140 (class 2604 OID 17698)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_his_rep_legal ALTER COLUMN id SET DEFAULT nextval('scr_historial_representante_legal_id_seq'::regclass);


--
-- TOC entry 2142 (class 2604 OID 17699)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_lectura ALTER COLUMN id SET DEFAULT nextval('scr_lectura_id_seq'::regclass);


--
-- TOC entry 2144 (class 2604 OID 17700)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_linea_estrategica ALTER COLUMN id SET DEFAULT nextval('scr_lin_estrateg_id_seq'::regclass);


--
-- TOC entry 2146 (class 2604 OID 17701)
-- Dependencies: 212 211
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_localidad ALTER COLUMN id SET DEFAULT nextval('scr_localidad_id_seq'::regclass);


--
-- TOC entry 2147 (class 2604 OID 17702)
-- Dependencies: 244 213
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_log ALTER COLUMN id SET DEFAULT nextval('src_log_id_seq'::regclass);


--
-- TOC entry 2148 (class 2604 OID 17703)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_marca_produc ALTER COLUMN id SET DEFAULT nextval('scr_marca_produc_id_seq'::regclass);


--
-- TOC entry 2149 (class 2604 OID 17704)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_organizacion ALTER COLUMN id SET DEFAULT nextval('scr_organizacion_id_seq'::regclass);


--
-- TOC entry 2153 (class 2604 OID 17705)
-- Dependencies: 220 219
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_presen_produc ALTER COLUMN id SET DEFAULT nextval('scr_presen_produc_id_seq'::regclass);


--
-- TOC entry 2154 (class 2604 OID 17706)
-- Dependencies: 223 221
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_producto ALTER COLUMN id SET DEFAULT nextval('scr_producto_id_seq'::regclass);


--
-- TOC entry 2155 (class 2604 OID 17707)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_proveedor ALTER COLUMN id SET DEFAULT nextval('scr_proveedor_id_seq'::regclass);


--
-- TOC entry 2156 (class 2604 OID 17708)
-- Dependencies: 227 226
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_proyecto ALTER COLUMN id SET DEFAULT nextval('scr_proyecto_id_seq'::regclass);


--
-- TOC entry 2157 (class 2604 OID 17709)
-- Dependencies: 229 228
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_recibo ALTER COLUMN id SET DEFAULT nextval('scr_recibo_id_seq'::regclass);


--
-- TOC entry 2159 (class 2604 OID 17710)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_representante_legal ALTER COLUMN id SET DEFAULT nextval('scr_representate_legal_id_seq'::regclass);


--
-- TOC entry 2160 (class 2604 OID 17711)
-- Dependencies: 245 232
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_rol ALTER COLUMN id SET DEFAULT nextval('src_rol_id_seq'::regclass);


--
-- TOC entry 2161 (class 2604 OID 17712)
-- Dependencies: 234 233
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_rr_ejecucion ALTER COLUMN id SET DEFAULT nextval('scr_rr_ejecucion_id_seq'::regclass);


--
-- TOC entry 2167 (class 2604 OID 17713)
-- Dependencies: 239 238
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_transaccion ALTER COLUMN id SET DEFAULT nextval('scr_transaccion_id_seq'::regclass);


--
-- TOC entry 2170 (class 2604 OID 17714)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_u_medida_produc ALTER COLUMN id SET DEFAULT nextval('scr_u_medida_produc_id_seq'::regclass);


--
-- TOC entry 2177 (class 2604 OID 17715)
-- Dependencies: 248 242
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_usuario ALTER COLUMN id SET DEFAULT nextval('src_usuario_id_seq'::regclass);


--
-- TOC entry 2502 (class 0 OID 17301)
-- Dependencies: 161 2590
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
\.


--
-- TOC entry 2503 (class 0 OID 17304)
-- Dependencies: 162 2590
-- Data for Name: scr_actividad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_actividad (id, "actividadNombre", "actividadDescripcion", "actividadInicio", "actividadFin", "actividadPresupuesto", actividad_id, cat_actividad_id, "actividadEjecutado", proyecto_id) FROM stdin;
\.


--
-- TOC entry 2645 (class 0 OID 0)
-- Dependencies: 163
-- Name: scr_actividad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_actividad_id_seq', 1, false);


--
-- TOC entry 2646 (class 0 OID 0)
-- Dependencies: 165
-- Name: scr_area_de_trabajo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_area_de_trabajo_id_seq', 1, false);


--
-- TOC entry 2505 (class 0 OID 17316)
-- Dependencies: 164 2590
-- Data for Name: scr_area_trabajo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_area_trabajo (id, "aTrabajoNombre", "aTrabajoDescripcion", area_trabajo_id, organizacion_id, cargo_id) FROM stdin;
\.


--
-- TOC entry 2507 (class 0 OID 17324)
-- Dependencies: 166 2590
-- Data for Name: scr_banco; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_banco (id, banco_nombre) FROM stdin;
1	Banco de Fomento Agropecuario (BFA.)
2	Banco Agrícola Comercial (B.A.)
3	ACORG, DE R.L.
\.


--
-- TOC entry 2647 (class 0 OID 0)
-- Dependencies: 167
-- Name: scr_banco_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_banco_id_seq', 3, true);


--
-- TOC entry 2509 (class 0 OID 17329)
-- Dependencies: 168 2590
-- Data for Name: scr_bombeo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_bombeo (id, fecha, bombeo_inicio, bombeo_fin, voltaje, amperaje, presion, lectura, produccion, empleado_id) FROM stdin;
\.


--
-- TOC entry 2648 (class 0 OID 0)
-- Dependencies: 169
-- Name: scr_bombeo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_bombeo_id_seq', 1, false);


--
-- TOC entry 2511 (class 0 OID 17340)
-- Dependencies: 170 2590
-- Data for Name: scr_cargo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cargo (id, "cargoNombre", "cargoDescripcion", "cargoSalario", cargo_id) FROM stdin;
1	contador	none	200	1
3	directiva	none	200	1
4	administrador	test	15	1
15	root		30	\N
2	tecnico	test	15	1
\.


--
-- TOC entry 2649 (class 0 OID 0)
-- Dependencies: 171
-- Name: scr_cargo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_cargo_id_seq', 15, true);


--
-- TOC entry 2513 (class 0 OID 17350)
-- Dependencies: 172 2590
-- Data for Name: scr_cat_actividad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_actividad (id, "cActividadNombre", "catActividadDescripcion") FROM stdin;
\.


--
-- TOC entry 2515 (class 0 OID 17358)
-- Dependencies: 174 2590
-- Data for Name: scr_cat_cobro; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_cobro (id, "cCobroNombre", "cCobroDescripcion") FROM stdin;
2	Administrativo	
3	Operativo	
4	Mantenimiento	
5	Constante	
1	Consumo	\N
6	Compensacion	
\.


--
-- TOC entry 2516 (class 0 OID 17365)
-- Dependencies: 175 2590
-- Data for Name: scr_cat_cooperante; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_cooperante (id, "catCoopNombre", "catCoopDescrip") FROM stdin;
\.


--
-- TOC entry 2517 (class 0 OID 17371)
-- Dependencies: 176 2590
-- Data for Name: scr_cat_depreciacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_depreciacion (id, "depreciacionNombre", "depreciacionDescripcion") FROM stdin;
\.


--
-- TOC entry 2518 (class 0 OID 17377)
-- Dependencies: 177 2590
-- Data for Name: scr_cat_organizacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_organizacion (id, "cOrgNombre", "cOrgDescripcion") FROM stdin;
1	Onganizacion no gubernamental	\N
2	Gubernamental	\N
3	Privada	\N
4	Fundación	\N
\.


--
-- TOC entry 2519 (class 0 OID 17383)
-- Dependencies: 178 2590
-- Data for Name: scr_cat_produc; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_produc (id, "catProducNombre", "catProducDescrip") FROM stdin;
\.


--
-- TOC entry 2520 (class 0 OID 17389)
-- Dependencies: 179 2590
-- Data for Name: scr_cat_rep_legal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cat_rep_legal (id, "catRLegalNombre", "catRLegalDescripcion", "catRLegalRegistro", "catRLegalFirma") FROM stdin;
1	Auditor Interno	Auditor Interno	2012-09-03 10:32:32.813746	f
2	Auditor Esterno	Auditor Esterno	2012-09-03 10:33:22.330562	f
5	testing	nalalalala	2014-10-09 16:22:06.799005	t
3	Representante legal ACRASAME - ZP	Presidente de ACRASAME-ZP.	2014-11-26 19:28:39.745709	f
\.


--
-- TOC entry 2521 (class 0 OID 17397)
-- Dependencies: 180 2590
-- Data for Name: scr_cheq_recurso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cheq_recurso (id, cheq_rr_codigo, cheq_rr_quien_recibe, cheq_rr_fecha_emision, cheq_rr_fecha_vence, chequera_id) FROM stdin;
\.


--
-- TOC entry 2650 (class 0 OID 0)
-- Dependencies: 181
-- Name: scr_cheq_recurso_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_cheq_recurso_id_seq', 1, false);


--
-- TOC entry 2523 (class 0 OID 17402)
-- Dependencies: 182 2590
-- Data for Name: scr_chequera; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_chequera (id, chequera_correlativo, banco_id) FROM stdin;
\.


--
-- TOC entry 2651 (class 0 OID 0)
-- Dependencies: 183
-- Name: scr_chequera_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_chequera_id_seq', 1, false);


--
-- TOC entry 2525 (class 0 OID 17407)
-- Dependencies: 184 2590
-- Data for Name: scr_cloracion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cloracion (id, fecha, hora, gramos, localidad_id, empleado_id, observacion) FROM stdin;
\.


--
-- TOC entry 2652 (class 0 OID 0)
-- Dependencies: 185
-- Name: scr_cloracion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_cloracion_id_seq', 1, false);


--
-- TOC entry 2527 (class 0 OID 17417)
-- Dependencies: 186 2590
-- Data for Name: scr_cobro; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cobro (id, "cobroNombre", "cobroCodigo", "cobroDescripcion", "cobroInicio", "cobroFin", "cobroValor", "cobroPermanente", cat_cobro_id) FROM stdin;
6	Bloque # 1	Bq.01	Primer bloque de sonsumo 	0	0	0.429999999999999993	f	1
1	Cobro Fijo 	C.F.01	Cobro servicio fijo	0	0	5.25	f	5
3	Bloque # 2	Bq.02	Segundo bloque de consumo 	0	0	0.469999999999999973	f	1
4	Bloque # 3	Bq.03	Tercer bloque de consumo	0	0	0.689999999999999947	f	1
5	Bloque # 4	Bq.04	cuarto bloque de consumo	0	0	0.939999999999999947	f	1
7	Instalacion	IN.01	Pago de contado de instalacion	0	0	312	f	3
\.


--
-- TOC entry 2653 (class 0 OID 0)
-- Dependencies: 187
-- Name: scr_cobro_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_cobro_id_seq', 7, true);


--
-- TOC entry 2529 (class 0 OID 17427)
-- Dependencies: 188 2590
-- Data for Name: scr_consumo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_consumo (id, registro, cantidad, cobro_id, factura_id) FROM stdin;
3970	2015-02-16 20:51:44.402592	1	1	3968
3971	2015-02-16 20:51:44.402592	1	1	3969
3972	2015-02-16 20:51:44.402592	1	1	3970
3973	2015-02-16 20:51:44.402592	1	1	3971
3974	2015-02-16 20:51:44.402592	1	1	3972
3975	2015-02-16 20:51:44.402592	1	1	3973
3976	2015-02-16 20:51:44.402592	1	1	3974
3977	2015-02-16 20:51:44.402592	1	1	3975
3978	2015-02-16 20:51:44.402592	1	1	3976
3979	2015-02-16 20:51:44.402592	1	1	3977
3980	2015-02-16 20:51:44.402592	1	1	3978
3981	2015-02-16 20:51:44.402592	1	1	3979
3982	2015-02-16 20:51:44.402592	1	1	3980
3983	2015-02-16 20:51:44.402592	1	1	3981
3984	2015-02-16 20:51:44.402592	1	1	3982
3985	2015-02-16 20:51:44.402592	1	1	3983
3986	2015-02-16 20:51:44.402592	1	1	3984
3987	2015-02-16 20:51:44.402592	1	1	3985
3988	2015-02-16 20:51:44.402592	1	1	3986
3989	2015-02-16 20:51:44.402592	1	1	3987
3990	2015-02-16 20:51:44.402592	1	1	3988
3991	2015-02-16 20:51:44.402592	1	1	3989
3992	2015-02-16 20:51:44.402592	1	1	3990
3993	2015-02-16 20:51:44.402592	1	1	3991
3994	2015-02-16 20:51:44.402592	1	1	3992
3995	2015-02-16 20:51:44.402592	1	1	3993
3996	2015-02-16 20:51:44.402592	1	1	3994
3997	2015-02-16 20:51:44.402592	1	1	3995
3998	2015-02-16 20:51:44.402592	1	1	3996
3999	2015-02-16 20:51:44.402592	1	1	3997
4000	2015-02-16 20:51:44.402592	1	1	3998
4001	2015-02-16 20:51:44.402592	1	1	3999
4002	2015-02-16 20:51:44.402592	1	1	4000
4003	2015-02-16 20:51:44.402592	1	1	4001
4004	2015-02-16 20:51:44.402592	1	1	4002
4005	2015-02-16 20:51:44.402592	1	1	4003
4006	2015-02-16 20:51:44.402592	1	1	4004
4007	2015-02-16 20:51:44.402592	1	1	4005
4008	2015-02-16 20:51:44.402592	1	1	4006
4009	2015-02-16 20:51:44.402592	1	1	4007
4010	2015-02-16 20:51:44.402592	1	1	4008
4011	2015-02-16 20:51:44.402592	1	1	4009
4012	2015-02-16 20:51:44.402592	1	1	4010
4013	2015-02-16 20:51:44.402592	1	1	4011
4014	2015-02-16 20:51:44.402592	1	1	4012
4015	2015-02-16 20:51:44.402592	1	1	4013
4016	2015-02-16 20:51:44.402592	1	1	4014
4017	2015-02-16 20:51:44.402592	1	1	4015
4018	2015-02-16 20:51:44.402592	1	1	4016
4019	2015-02-16 20:51:44.402592	1	1	4017
4020	2015-02-16 20:51:44.402592	1	1	4018
4021	2015-02-16 20:51:44.402592	1	1	4019
4022	2015-02-16 20:51:44.402592	1	1	4020
4023	2015-02-16 20:51:44.402592	1	1	4021
4024	2015-02-16 20:51:44.402592	1	1	4022
4025	2015-02-16 20:51:44.402592	1	1	4023
4026	2015-02-16 20:51:44.402592	1	1	4024
4027	2015-02-16 20:51:44.402592	1	1	4025
4028	2015-02-16 20:51:44.402592	1	1	4026
4029	2015-02-16 20:51:44.402592	1	1	4027
4030	2015-02-16 20:51:44.402592	1	1	4028
4031	2015-02-16 20:51:44.402592	1	1	4029
4032	2015-02-16 20:51:44.402592	1	1	4030
4033	2015-02-16 20:51:44.402592	1	1	4031
4034	2015-02-16 20:51:44.402592	1	1	4032
4035	2015-02-16 20:51:44.402592	1	1	4033
4036	2015-02-16 20:51:44.402592	1	1	4034
4037	2015-02-16 20:51:44.402592	1	1	4035
4038	2015-02-16 20:51:44.402592	1	1	4036
4039	2015-02-16 20:51:44.402592	1	1	4037
4040	2015-02-16 20:51:44.402592	1	1	4038
4041	2015-02-16 20:51:44.402592	1	1	4039
4042	2015-02-16 20:51:44.402592	1	1	4040
4043	2015-02-16 20:51:44.402592	1	1	4041
4044	2015-02-16 20:51:44.402592	1	1	4042
4045	2015-02-16 20:51:44.402592	1	1	4043
4046	2015-02-16 20:51:44.402592	1	1	4044
4047	2015-02-16 20:51:44.402592	1	1	4045
4048	2015-02-16 20:51:44.402592	1	1	4046
4049	2015-02-16 20:51:44.402592	1	1	4047
4050	2015-02-16 20:51:44.402592	1	1	4048
4051	2015-02-16 20:51:44.402592	1	1	4049
4052	2015-02-16 20:51:44.402592	1	1	4050
4053	2015-02-16 20:51:44.402592	1	1	4051
4054	2015-02-16 20:51:44.402592	1	1	4052
4055	2015-02-16 20:51:44.402592	1	1	4053
4056	2015-02-16 20:51:44.402592	1	1	4054
4057	2015-02-16 20:51:44.402592	1	1	4055
4058	2015-02-16 20:51:44.402592	1	1	4056
4059	2015-02-16 20:51:44.402592	1	1	4057
4060	2015-02-16 20:51:44.402592	1	1	4058
4061	2015-02-16 20:51:44.402592	1	1	4059
4062	2015-02-16 20:51:44.402592	1	1	4060
4063	2015-02-16 20:51:44.402592	1	1	4061
4064	2015-02-16 20:51:44.402592	1	1	4062
4065	2015-02-16 20:51:44.402592	1	1	4063
4066	2015-02-16 20:51:44.402592	1	1	4064
4067	2015-02-16 20:51:44.402592	1	1	4065
4068	2015-02-16 20:51:44.402592	1	1	4066
4069	2015-02-16 20:51:44.402592	1	1	4067
4070	2015-02-16 20:51:44.402592	1	1	4068
4071	2015-02-16 20:51:44.402592	1	1	4069
4072	2015-02-16 20:51:44.402592	1	1	4070
4073	2015-02-16 20:51:44.402592	1	1	4071
4074	2015-02-16 20:51:44.402592	1	1	4072
4075	2015-02-16 20:51:44.402592	1	1	4073
4076	2015-02-16 20:51:44.402592	1	1	4074
4077	2015-02-16 20:51:44.402592	1	1	4075
4078	2015-02-16 20:51:44.402592	1	1	4076
4079	2015-02-16 20:51:44.402592	1	1	4077
4080	2015-02-16 20:51:44.402592	1	1	4078
4081	2015-02-16 20:51:44.402592	1	1	4079
4082	2015-02-16 20:51:44.402592	1	1	4080
4083	2015-02-16 20:51:44.402592	1	1	4081
4084	2015-02-16 20:51:44.402592	1	1	4082
4085	2015-02-16 20:51:44.402592	1	1	4083
4086	2015-02-16 20:51:44.402592	1	1	4084
4087	2015-02-16 20:51:44.402592	1	1	4085
4088	2015-02-16 20:51:44.402592	1	1	4086
4089	2015-02-16 20:51:44.402592	1	1	4087
4090	2015-02-16 20:51:44.402592	1	1	4088
4091	2015-02-16 20:51:44.402592	1	1	4089
4092	2015-02-16 20:51:44.402592	1	1	4090
4093	2015-02-16 20:51:44.402592	1	1	4091
4094	2015-02-16 20:51:44.402592	1	1	4092
4095	2015-02-16 20:51:44.402592	1	1	4093
4096	2015-02-16 20:51:44.402592	1	1	4094
4097	2015-02-16 20:51:44.402592	1	1	4095
4098	2015-02-16 20:51:44.402592	1	1	4096
4099	2015-02-16 20:51:44.402592	1	1	4097
4100	2015-02-16 20:51:44.402592	1	1	4098
4101	2015-02-16 20:51:44.402592	1	1	4099
4102	2015-02-16 20:51:44.402592	1	1	4100
4103	2015-02-16 20:51:44.402592	1	1	4101
4104	2015-02-16 20:51:44.402592	1	1	4102
4105	2015-02-16 20:51:44.402592	1	1	4103
4106	2015-02-16 20:51:44.402592	1	1	4104
4107	2015-02-16 20:51:44.402592	1	1	4105
4108	2015-02-16 20:51:44.402592	1	1	4106
4109	2015-02-16 20:51:44.402592	1	1	4107
4110	2015-02-16 20:51:44.402592	1	1	4108
4111	2015-02-16 20:51:44.402592	1	1	4109
4112	2015-02-16 20:51:44.402592	1	1	4110
4113	2015-02-16 20:51:44.402592	1	1	4111
4114	2015-02-16 20:51:44.402592	1	1	4112
4115	2015-02-16 20:51:44.402592	1	1	4113
4116	2015-02-16 20:51:44.402592	1	1	4114
4117	2015-02-16 20:51:44.402592	1	1	4115
4118	2015-02-16 20:51:44.402592	1	1	4116
4119	2015-02-16 20:51:44.402592	1	1	4117
4120	2015-02-16 20:51:44.402592	1	1	4118
4121	2015-02-16 20:51:44.402592	1	1	4119
4122	2015-02-16 20:51:44.402592	1	1	4120
4123	2015-02-16 20:51:44.402592	1	1	4121
4124	2015-02-16 20:51:44.402592	1	1	4122
4125	2015-02-16 20:51:44.402592	1	1	4123
4126	2015-02-16 20:51:44.402592	1	1	4124
4127	2015-02-16 20:51:44.402592	1	1	4125
4128	2015-02-16 20:51:44.402592	1	1	4126
4129	2015-02-16 20:51:44.402592	1	1	4127
4130	2015-02-16 20:51:44.402592	1	1	4128
4131	2015-02-16 20:51:44.402592	1	1	4129
4132	2015-02-16 20:51:44.402592	1	1	4130
4133	2015-02-16 20:51:44.402592	1	1	4131
4134	2015-02-16 20:51:44.402592	1	1	4132
4135	2015-02-16 20:51:44.402592	1	1	4133
4136	2015-02-16 20:51:44.402592	1	1	4134
4137	2015-02-16 20:51:44.402592	1	1	4135
4138	2015-02-16 20:51:44.402592	1	1	4136
4139	2015-02-16 20:51:44.402592	1	1	4137
4140	2015-02-16 20:51:44.402592	1	1	4138
4141	2015-02-16 20:51:44.402592	1	1	4139
4142	2015-02-16 20:51:44.402592	1	1	4140
4143	2015-02-16 20:51:44.402592	1	1	4141
4144	2015-02-16 20:51:44.402592	1	1	4142
4145	2015-02-16 20:51:44.402592	1	1	4143
4146	2015-02-16 20:51:44.402592	1	1	4144
4147	2015-02-16 20:51:44.402592	1	1	4145
4148	2015-02-16 20:51:44.402592	1	1	4146
4149	2015-02-16 20:51:44.402592	1	1	4147
4150	2015-02-16 20:51:44.402592	1	1	4148
4151	2015-02-16 20:51:44.402592	1	1	4149
4152	2015-02-16 20:51:44.402592	1	1	4150
4153	2015-02-16 20:51:44.402592	1	1	4151
4154	2015-02-16 20:51:44.402592	1	1	4152
4155	2015-02-16 20:51:44.402592	1	1	4153
4156	2015-02-16 20:51:44.402592	1	1	4154
4157	2015-02-16 20:51:44.402592	1	1	4155
4158	2015-02-16 20:51:44.402592	1	1	4156
4159	2015-02-16 20:51:44.402592	1	1	4157
4160	2015-02-16 20:51:44.402592	1	1	4158
4161	2015-02-16 20:51:44.402592	1	1	4159
4162	2015-02-16 20:51:44.402592	1	1	4160
4163	2015-02-16 20:51:44.402592	1	1	4161
4164	2015-02-16 20:51:44.402592	1	1	4162
4165	2015-02-16 20:51:44.402592	1	1	4163
4166	2015-02-16 20:51:44.402592	1	1	4164
4167	2015-02-16 20:51:44.402592	1	1	4165
4168	2015-02-16 20:51:44.402592	1	1	4166
4169	2015-02-16 20:51:44.402592	1	1	4167
4170	2015-02-16 20:51:44.402592	1	1	4168
4171	2015-02-16 20:51:44.402592	1	1	4169
4172	2015-02-16 20:51:44.402592	1	1	4170
4173	2015-02-16 20:51:44.402592	1	1	4171
4174	2015-02-16 20:51:44.402592	1	1	4172
4175	2015-02-16 20:51:44.402592	1	1	4173
4176	2015-02-16 20:51:44.402592	1	1	4174
4177	2015-02-16 20:51:44.402592	1	1	4175
4178	2015-02-16 20:51:44.402592	1	1	4176
4179	2015-02-16 20:51:44.402592	1	1	4177
4180	2015-02-16 20:51:44.402592	1	1	4178
4181	2015-02-16 20:51:44.402592	1	1	4179
4182	2015-02-16 20:51:44.402592	1	1	4180
4183	2015-02-16 20:51:44.402592	1	1	4181
4184	2015-02-16 20:51:44.402592	1	1	4182
4185	2015-02-16 20:51:44.402592	1	1	4183
4186	2015-02-16 20:51:44.402592	1	1	4184
4187	2015-02-16 20:51:44.402592	1	1	4185
4188	2015-02-16 20:51:44.402592	1	1	4186
4189	2015-02-16 20:51:44.402592	1	1	4187
4190	2015-02-16 20:51:44.402592	1	1	4188
4191	2015-02-16 20:51:44.402592	1	1	4189
4192	2015-02-16 20:51:44.402592	1	1	4190
4193	2015-02-16 20:51:44.402592	1	1	4191
4194	2015-02-16 20:51:44.402592	1	1	4192
4195	2015-02-16 20:51:44.402592	1	1	4193
4196	2015-02-16 20:51:44.402592	1	1	4194
4197	2015-02-16 20:51:44.402592	1	1	4195
4198	2015-02-16 20:51:44.402592	1	1	4196
4199	2015-02-16 20:51:44.402592	1	1	4197
4200	2015-02-16 20:51:44.402592	1	1	4198
4201	2015-02-16 20:51:44.402592	1	1	4199
4202	2015-02-16 20:51:44.402592	1	1	4200
4203	2015-02-16 20:51:44.402592	1	1	4201
4204	2015-02-16 20:51:44.402592	1	1	4202
4205	2015-02-16 20:51:44.402592	1	1	4203
4206	2015-02-16 20:51:44.402592	1	1	4204
4207	2015-02-16 20:51:44.402592	1	1	4205
4208	2015-02-16 20:51:44.402592	1	1	4206
4209	2015-02-16 20:51:44.402592	1	1	4207
4210	2015-02-16 20:51:44.402592	1	1	4208
4211	2015-02-16 20:51:44.402592	1	1	4209
4212	2015-02-16 20:51:44.402592	1	1	4210
4213	2015-02-16 20:51:44.402592	1	1	4211
4214	2015-02-16 20:51:44.402592	1	1	4212
4215	2015-02-16 20:51:44.402592	1	1	4213
4216	2015-02-16 20:51:44.402592	1	1	4214
4217	2015-02-16 20:51:44.402592	1	1	4215
4218	2015-02-16 20:51:44.402592	1	1	4216
4219	2015-02-16 20:51:44.402592	1	1	4217
4220	2015-02-16 20:51:44.402592	1	1	4218
4221	2015-02-16 20:51:44.402592	1	1	4219
4222	2015-02-16 20:51:44.402592	1	1	4220
4223	2015-02-16 20:51:44.402592	1	1	4221
4224	2015-02-16 20:51:44.402592	1	1	4222
4225	2015-02-16 20:51:44.402592	1	1	4223
4226	2015-02-16 20:51:44.402592	1	1	4224
4227	2015-02-16 20:51:44.402592	1	1	4225
4228	2015-02-16 20:51:44.402592	1	1	4226
4229	2015-02-16 20:51:44.402592	1	1	4227
4230	2015-02-16 20:51:44.402592	1	1	4228
4231	2015-02-16 20:51:44.402592	1	1	4229
4232	2015-02-16 20:51:44.402592	1	1	4230
4233	2015-02-16 20:51:44.402592	1	1	4231
4234	2015-02-16 20:51:44.402592	1	1	4232
4235	2015-02-16 20:51:44.402592	1	1	4233
4236	2015-02-16 20:51:44.402592	1	1	4234
4237	2015-02-16 20:51:44.402592	1	1	4235
4238	2015-02-16 20:51:44.402592	1	1	4236
4239	2015-02-16 20:51:44.402592	1	1	4237
4240	2015-02-16 20:51:44.402592	1	1	4238
4241	2015-02-16 20:51:44.402592	1	1	4239
4242	2015-02-16 20:51:44.402592	1	1	4240
4243	2015-02-16 20:51:44.402592	1	1	4241
4244	2015-02-16 20:51:44.402592	1	1	4242
4245	2015-02-16 20:51:44.402592	1	1	4243
4246	2015-02-16 20:51:44.402592	1	1	4244
4247	2015-02-16 20:51:44.402592	1	1	4245
4248	2015-02-16 20:51:44.402592	1	1	4246
4249	2015-02-16 20:51:44.402592	1	1	4247
4250	2015-02-16 20:51:44.402592	1	1	4248
4251	2015-02-16 20:51:44.402592	1	1	4249
4252	2015-02-16 20:51:44.402592	1	1	4250
4253	2015-02-16 20:51:44.402592	1	1	4251
4254	2015-02-16 20:51:44.402592	1	1	4252
4255	2015-02-16 20:51:44.402592	1	1	4253
4256	2015-02-16 20:51:44.402592	1	1	4254
4257	2015-02-16 20:51:44.402592	1	1	4255
4258	2015-02-16 20:51:44.402592	1	1	4256
4259	2015-02-16 20:51:44.402592	1	1	4257
4260	2015-02-16 20:51:44.402592	1	1	4258
4261	2015-02-16 20:51:44.402592	1	1	4259
4262	2015-02-16 20:51:44.402592	1	1	4260
4263	2015-02-16 20:51:44.402592	1	1	4261
4264	2015-02-16 20:51:44.402592	1	1	4262
4265	2015-02-16 20:51:44.402592	1	1	4263
4266	2015-02-16 20:51:44.402592	1	1	4264
4267	2015-02-16 20:51:44.402592	1	1	4265
4268	2015-02-16 20:51:44.402592	1	1	4266
4269	2015-02-16 20:51:44.402592	1	1	4267
4270	2015-02-16 20:51:44.402592	1	1	4268
4271	2015-02-16 20:51:44.402592	1	1	4269
4272	2015-02-16 20:51:44.402592	1	1	4270
4273	2015-02-16 20:51:44.402592	1	1	4271
4274	2015-02-16 20:51:44.402592	1	1	4272
4275	2015-02-16 20:51:44.402592	1	1	4273
4276	2015-02-16 20:51:44.402592	1	1	4274
4277	2015-02-16 20:51:44.402592	1	1	4275
4278	2015-02-16 20:51:44.402592	1	1	4276
4279	2015-02-16 20:51:44.402592	1	1	4277
4280	2015-02-16 20:51:44.402592	1	1	4278
4281	2015-02-16 20:51:44.402592	1	1	4279
4282	2015-02-16 20:51:44.402592	1	1	4280
4283	2015-02-16 20:51:44.402592	1	1	4281
4284	2015-02-16 20:51:44.402592	1	1	4282
4285	2015-02-16 20:51:44.402592	1	1	4283
4286	2015-02-16 20:51:44.402592	1	1	4284
4287	2015-02-16 20:51:44.402592	1	1	4285
4288	2015-02-16 20:51:44.402592	1	1	4286
4289	2015-02-16 20:51:44.402592	1	1	4287
4290	2015-02-16 20:51:44.402592	1	1	4288
4291	2015-02-16 20:51:44.402592	1	1	4289
4292	2015-02-16 20:51:44.402592	1	1	4290
4293	2015-02-16 20:51:44.402592	1	1	4291
4294	2015-02-16 20:51:44.402592	1	1	4292
4295	2015-02-16 20:51:44.402592	1	1	4293
4296	2015-02-16 20:51:44.402592	1	1	4294
4297	2015-02-16 20:51:44.402592	1	1	4295
4298	2015-02-16 20:51:44.402592	1	1	4296
4299	2015-02-16 20:51:44.402592	1	1	4297
4300	2015-02-16 20:51:44.402592	1	1	4298
4301	2015-02-16 20:51:44.402592	1	1	4299
4302	2015-02-16 20:51:44.402592	1	1	4300
4303	2015-02-16 20:51:44.402592	1	1	4301
4304	2015-02-16 20:51:44.402592	1	1	4302
4305	2015-02-16 20:51:44.402592	1	1	4303
4306	2015-02-16 20:51:44.402592	1	1	4304
4307	2015-02-16 20:51:44.402592	1	1	4305
4308	2015-02-16 20:51:44.402592	1	1	4306
4309	2015-02-16 20:51:44.402592	1	1	4307
4310	2015-02-16 20:51:44.402592	1	1	4308
4311	2015-02-16 20:51:44.402592	1	1	4309
4312	2015-02-16 20:51:44.402592	1	1	4310
4313	2015-02-16 20:51:44.402592	1	1	4311
4314	2015-02-16 20:51:44.402592	1	1	4312
4315	2015-02-16 20:51:44.402592	1	1	4313
4316	2015-02-16 20:51:44.402592	1	1	4314
4317	2015-02-16 20:51:44.402592	1	1	4315
4318	2015-02-16 20:51:44.402592	1	1	4316
4319	2015-02-16 20:51:44.402592	1	1	4317
4320	2015-02-16 20:51:44.402592	1	1	4318
4321	2015-02-16 20:51:44.402592	1	1	4319
4322	2015-02-16 20:51:44.402592	1	1	4320
4323	2015-02-16 20:51:44.402592	1	1	4321
4324	2015-02-16 20:51:44.402592	1	1	4322
4325	2015-02-16 20:51:44.402592	1	1	4323
4326	2015-02-16 20:51:44.402592	1	1	4324
4327	2015-02-16 20:51:44.402592	1	1	4325
4328	2015-02-16 20:51:44.402592	1	1	4326
4329	2015-02-16 20:51:44.402592	1	1	4327
4330	2015-02-16 20:51:44.402592	1	1	4328
4331	2015-02-16 20:51:44.402592	1	1	4329
4332	2015-02-16 20:51:44.402592	1	1	4330
4333	2015-02-16 20:51:44.402592	1	1	4331
4334	2015-02-16 20:51:44.402592	1	1	4332
4335	2015-02-16 20:51:44.402592	1	1	4333
4336	2015-02-16 20:51:44.402592	1	1	4334
4337	2015-02-16 20:51:44.402592	1	1	4335
4338	2015-02-16 20:51:44.402592	1	1	4336
4339	2015-02-16 20:51:44.402592	1	1	4337
4340	2015-02-16 20:51:44.402592	1	1	4338
4341	2015-02-16 20:51:44.402592	1	1	4339
4342	2015-02-16 20:51:44.402592	1	1	4340
4343	2015-02-16 20:51:44.402592	1	1	4341
4344	2015-02-16 20:51:44.402592	1	1	4342
4345	2015-02-16 20:51:44.402592	1	1	4343
4346	2015-02-16 20:51:44.402592	1	1	4344
4347	2015-02-16 20:51:44.402592	1	1	4345
4348	2015-02-16 20:51:44.402592	1	1	4346
4349	2015-02-16 20:51:44.402592	1	1	4347
4350	2015-02-16 20:51:44.402592	1	1	4348
4351	2015-02-16 20:51:44.402592	1	1	4349
4352	2015-02-16 20:51:44.402592	1	1	4350
4353	2015-02-16 20:51:44.402592	1	1	4351
4354	2015-02-16 20:51:44.402592	1	1	4352
4355	2015-02-16 20:51:44.402592	1	1	4353
4356	2015-02-16 20:51:44.402592	1	1	4354
4357	2015-02-16 20:51:44.402592	1	1	4355
4358	2015-02-16 20:51:44.402592	1	1	4356
4359	2015-02-16 20:51:44.402592	1	1	4357
4360	2015-02-16 20:51:44.402592	1	1	4358
4361	2015-02-16 20:51:44.402592	1	1	4359
4362	2015-02-16 20:51:44.402592	1	1	4360
4363	2015-02-16 20:51:44.402592	1	1	4361
4364	2015-02-16 20:51:44.402592	1	1	4362
4365	2015-02-16 20:51:44.402592	1	1	4363
4366	2015-02-16 20:51:44.402592	1	1	4364
4367	2015-02-16 20:51:44.402592	1	1	4365
4368	2015-02-16 20:51:44.402592	1	1	4366
4369	2015-02-16 20:51:44.402592	1	1	4367
4370	2015-02-16 20:51:44.402592	1	1	4368
4371	2015-02-16 20:51:44.402592	1	1	4369
4372	2015-02-16 20:51:44.402592	1	1	4370
4373	2015-02-16 20:51:44.402592	1	1	4371
4374	2015-02-16 20:51:44.402592	1	1	4372
4375	2015-02-16 20:51:44.402592	1	1	4373
4376	2015-02-16 20:51:44.402592	1	1	4374
4377	2015-02-16 20:51:44.402592	1	1	4375
4378	2015-02-16 20:51:44.402592	1	1	4376
4379	2015-02-16 20:51:44.402592	1	1	4377
4380	2015-02-16 20:51:44.402592	1	1	4378
4381	2015-02-16 20:51:44.402592	1	1	4379
4382	2015-02-16 20:51:44.402592	1	1	4380
4383	2015-02-16 20:51:44.402592	1	1	4381
4384	2015-02-16 20:51:44.402592	1	1	4382
4385	2015-02-16 20:51:44.402592	1	1	4383
4386	2015-02-16 20:51:44.402592	1	1	4384
4387	2015-02-16 20:51:44.402592	1	1	4385
4388	2015-02-16 20:51:44.402592	1	1	4386
4389	2015-02-16 20:51:44.402592	1	1	4387
4390	2015-02-16 20:51:44.402592	1	1	4388
4391	2015-02-16 20:51:44.402592	1	1	4389
4392	2015-02-16 20:51:44.402592	1	1	4390
4393	2015-02-16 20:51:44.402592	1	1	4391
4394	2015-02-16 20:51:44.402592	1	1	4392
4395	2015-02-16 20:51:44.402592	1	1	4393
4396	2015-02-16 20:51:44.402592	1	1	4394
4397	2015-02-16 20:51:44.402592	1	1	4395
4398	2015-02-16 20:51:44.402592	1	1	4396
4399	2015-02-16 20:51:44.402592	1	1	4397
4400	2015-02-16 20:51:44.402592	1	1	4398
4401	2015-02-16 20:51:44.402592	1	1	4399
4402	2015-02-16 20:51:44.402592	1	1	4400
4403	2015-02-16 20:51:44.402592	1	1	4401
4404	2015-02-16 20:51:44.402592	1	1	4402
4405	2015-02-16 20:51:44.402592	1	1	4403
4406	2015-02-16 20:51:44.402592	1	1	4404
4407	2015-02-16 20:51:44.402592	1	1	4405
4408	2015-02-16 20:51:44.402592	1	1	4406
4409	2015-02-16 20:51:44.402592	1	1	4407
4410	2015-02-16 20:51:44.402592	1	1	4408
4411	2015-02-16 20:51:44.402592	1	1	4409
4412	2015-02-16 20:51:44.402592	1	1	4410
4413	2015-02-16 20:51:44.402592	1	1	4411
4414	2015-02-16 20:51:44.402592	1	1	4412
4415	2015-02-16 20:51:44.402592	1	1	4413
4416	2015-02-16 20:51:44.402592	1	1	4414
4417	2015-02-16 20:51:44.402592	1	1	4415
4418	2015-02-16 20:51:44.402592	1	1	4416
4419	2015-02-16 20:51:44.402592	1	1	4417
4420	2015-02-16 20:51:44.402592	1	1	4418
4421	2015-02-16 20:51:44.402592	1	1	4419
4422	2015-02-16 20:51:44.402592	1	1	4420
4423	2015-02-16 20:51:44.402592	1	1	4421
4424	2015-02-16 20:51:44.402592	1	1	4422
4425	2015-02-16 20:51:44.402592	1	1	4423
4426	2015-02-16 20:51:44.402592	1	1	4424
4427	2015-02-16 20:51:44.402592	1	1	4425
4428	2015-02-16 20:51:44.402592	1	1	4426
4429	2015-02-16 20:51:44.402592	1	1	4427
4430	2015-02-16 20:51:44.402592	1	1	4428
4431	2015-02-16 20:51:44.402592	1	1	4429
4432	2015-02-16 20:51:44.402592	1	1	4430
4433	2015-02-16 20:51:44.402592	1	1	4431
4434	2015-02-16 20:51:44.402592	1	1	4432
4435	2015-02-16 20:51:44.402592	1	1	4433
4436	2015-02-16 20:51:44.402592	1	1	4434
4437	2015-02-16 20:51:44.402592	1	1	4435
4438	2015-02-16 20:51:44.402592	1	1	4436
4439	2015-02-16 20:51:44.402592	1	1	4437
4440	2015-02-16 20:51:44.402592	1	1	4438
4441	2015-02-16 20:51:44.402592	1	1	4439
4442	2015-02-16 20:51:44.402592	1	1	4440
4443	2015-02-16 20:51:44.402592	1	1	4441
4444	2015-02-16 20:51:44.402592	1	1	4442
4445	2015-02-16 20:51:44.402592	1	1	4443
4446	2015-02-16 20:51:44.402592	1	1	4444
4447	2015-02-16 20:51:44.402592	1	1	4445
4448	2015-02-16 20:51:44.402592	1	1	4446
4449	2015-02-16 20:51:44.402592	1	1	4447
4450	2015-02-16 20:51:44.402592	1	1	4448
4451	2015-02-16 20:51:44.402592	1	1	4449
4452	2015-02-16 20:51:44.402592	1	1	4450
4453	2015-02-16 20:51:44.402592	1	1	4451
4454	2015-02-16 20:51:44.402592	1	1	4452
4455	2015-02-16 20:51:44.402592	1	1	4453
4456	2015-02-16 20:51:44.402592	1	1	4454
4457	2015-02-16 20:51:44.402592	1	1	4455
4458	2015-02-16 20:51:44.402592	1	1	4456
4459	2015-02-16 20:51:44.402592	1	1	4457
4460	2015-02-16 20:51:44.402592	1	1	4458
4461	2015-02-16 20:51:44.402592	1	1	4459
4462	2015-02-16 20:51:44.402592	1	1	4460
4463	2015-02-16 20:51:44.402592	1	1	4461
4464	2015-02-16 20:51:44.402592	1	1	4462
4465	2015-02-16 20:51:44.402592	1	1	4463
4466	2015-02-16 20:51:44.402592	1	1	4464
4467	2015-02-16 20:51:44.402592	1	1	4465
4468	2015-02-16 20:51:44.402592	1	1	4466
4469	2015-02-16 20:51:44.402592	1	1	4467
4470	2015-02-16 20:51:44.402592	1	1	4468
4471	2015-02-16 20:51:44.402592	1	1	4469
4472	2015-02-16 20:51:44.402592	1	1	4470
4473	2015-02-16 20:51:44.402592	1	1	4471
4474	2015-02-16 20:51:44.402592	1	1	4472
4475	2015-02-16 20:51:44.402592	1	1	4473
4476	2015-02-16 20:51:44.402592	1	1	4474
4477	2015-02-16 20:51:44.402592	1	1	4475
4478	2015-02-16 20:51:44.402592	1	1	4476
4479	2015-02-16 20:51:44.402592	1	1	4477
4480	2015-02-16 20:51:44.402592	1	1	4478
4481	2015-02-16 20:51:44.402592	1	1	4479
4482	2015-02-16 20:51:44.402592	1	1	4480
4483	2015-02-16 20:51:44.402592	1	1	4481
4484	2015-02-16 20:51:44.402592	1	1	4482
4485	2015-02-16 20:51:44.402592	1	1	4483
4486	2015-02-16 20:51:44.402592	1	1	4484
4487	2015-02-16 20:51:44.402592	1	1	4485
4488	2015-02-16 20:51:44.402592	1	1	4486
4489	2015-02-16 20:51:44.402592	1	1	4487
4490	2015-02-16 20:51:44.402592	1	1	4488
4491	2015-02-16 20:51:44.402592	1	1	4489
4492	2015-02-16 20:51:44.402592	1	1	4490
4493	2015-02-16 20:51:44.402592	1	1	4491
4494	2015-02-16 20:51:44.402592	1	1	4492
4495	2015-02-16 20:51:44.402592	1	1	4493
4496	2015-02-16 20:51:44.402592	1	1	4494
4497	2015-02-16 20:51:44.402592	1	1	4495
4498	2015-02-16 20:51:44.402592	1	1	4496
4499	2015-02-16 20:51:44.402592	1	1	4497
4500	2015-02-16 20:51:44.402592	1	1	4498
4501	2015-02-16 20:51:44.402592	1	1	4499
4502	2015-02-16 20:51:44.402592	1	1	4500
4503	2015-02-16 20:51:44.402592	1	1	4501
4504	2015-02-16 20:51:44.402592	1	1	4502
4505	2015-02-16 20:51:44.402592	1	1	4503
4506	2015-02-16 20:51:44.402592	1	1	4504
4507	2015-02-16 20:51:44.402592	1	1	4505
4508	2015-02-16 20:51:44.402592	1	1	4506
4509	2015-02-16 20:51:44.402592	1	1	4507
4510	2015-02-16 20:51:44.402592	1	1	4508
4511	2015-02-16 20:51:44.402592	1	1	4509
4512	2015-02-16 20:51:44.402592	1	1	4510
4513	2015-02-16 20:51:44.402592	1	1	4511
4514	2015-02-16 20:51:44.402592	1	1	4512
4515	2015-02-16 20:51:44.402592	1	1	4513
4516	2015-02-16 20:51:44.402592	1	1	4514
4517	2015-02-16 20:51:44.402592	1	1	4515
4518	2015-02-16 20:51:44.402592	1	1	4516
4519	2015-02-16 20:51:44.402592	1	1	4517
4520	2015-02-23 15:55:25.588347	1	7	3970
\.


--
-- TOC entry 2654 (class 0 OID 0)
-- Dependencies: 189
-- Name: scr_consumo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_consumo_id_seq', 5618, true);


--
-- TOC entry 2531 (class 0 OID 17434)
-- Dependencies: 190 2590
-- Data for Name: scr_cooperante; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cooperante (id, "cooperanteNombre", "cooperanteDescripcion", "catCooperante_id") FROM stdin;
\.


--
-- TOC entry 2655 (class 0 OID 0)
-- Dependencies: 191
-- Name: scr_cooperante_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_cooperante_id_seq', 1, false);


--
-- TOC entry 2533 (class 0 OID 17442)
-- Dependencies: 192 2590
-- Data for Name: scr_cuenta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_cuenta (id, "cuentaNombre", "cuentaRegistro", "cuentaDebe", "cuentaHaber", cat_cuenta_id, "cuentaActivo", "cuentaCodigo", "cuentaDescripcion", "cuentaNegativa") FROM stdin;
1	ACTIVO	2014-11-25 20:19:07	0	0	\N	t	1	\N	f
3	ACTIVO CIRCULANTE	2014-11-25 20:29:33	0	0	1	t	11	\N	f
4	CAJA	2014-11-25 20:30:25	0	0	3	t	111	\N	f
5	Caja General	2014-11-25 20:30:54	0	0	4	t	11101	\N	f
6	Caja chica	2014-11-25 20:33:03	0	0	4	t	11102	\N	f
9	BANCOS	2014-11-25 20:42:07	0	0	3	t	112	\N	f
13	Banco Agrícola	2014-11-25 20:46:10	0	0	9	t	11201	\N	f
14	Cuenta Corriente	2014-11-25 20:48:41	0	0	13	t	1120101	\N	f
15	Cuenta de Ahorro	2014-11-25 20:49:10	0	0	13	t	1120102	\N	f
16	Banco de Fomento Agropecuario	2014-11-25 20:50:06	0	0	9	t	11202	\N	f
17	Cuenta Corriente	2014-11-25 20:50:26	0	0	16	t	1120201	\N	f
18	Cuenta de Ahorro	2014-11-25 20:51:10	0	0	16	t	1120202	\N	f
19	ACORG	2014-11-25 20:52:16	0	0	9	t	11203	\N	f
20	Cuenta Corriente	2014-11-25 20:52:40	0	0	19	t	1120301	\N	f
21	Cuenta de Ahorro	2014-11-25 20:52:57	0	0	19	t	1120302	\N	f
22	Cuenta a plazo	2014-11-25 20:53:26	0	0	19	t	1120303	\N	f
23	Banco DAVIVIENDA	2014-11-25 20:53:47	0	0	9	t	11204	\N	f
24	Cuenta Corriente	2014-11-25 20:54:10	0	0	23	t	1120401	\N	f
94	PASIVO	2014-11-26 10:49:01	0	0	\N	f	2		f
25	Cuenta de Ahorro	2014-11-25 21:04:12	0	0	23	t	1120402	\N	f
95	CIRCULANTE	2014-11-26 10:49:42	0	0	94	f	21		f
26	Banco CITIBANK	2014-11-25 21:07:29	0	0	9	t	11205	\N	f
114	CUENTAS POR PAGAR (C.P.)	2014-11-26 14:34:55	0	0	95	f	211		f
27	Cuenta Corriente	2014-11-25 21:07:51	0	0	26	t	1120501	\N	f
28	Cuenta de Ahorro	2014-11-25 21:08:12	0	0	26	t	1120502	\N	f
29	Banco Procredit	2014-11-25 21:08:28	0	0	9	t	11206	\N	f
30	Cuenta Corriente	2014-11-25 21:08:46	0	0	29	t	1120601	\N	f
115	Proveedores	2014-11-26 14:37:15	0	0	114	f	21101		f
116	Locales 	2014-11-26 14:37:55	0	0	115	f	2110101		f
117	Del Exterior	2014-11-26 14:38:42	0	0	115	f	2110102		f
31	Cuenta de Ahorro	2014-11-25 21:09:00	0	0	29	t	1120602	\N	f
118	Acreedores Varios 	2014-11-26 14:41:14	0	0	114	f	21102		f
119	Sueldos Pendientes de Pago 	2014-11-26 14:41:57	0	0	118	f	2110201		f
120	Honorarios Profecionales	2014-11-26 14:44:35	0	0	118	f	2110202		f
32	CUENTAS Y DOCUMENTOS POR COBRAR	2014-11-25 21:09:51	0	0	3	t	113	\N	f
33	Cuentas por Cobrar a Asociados	2014-11-25 21:14:53	0	0	32	t	11301	\N	f
34	Documentos por Cobrar a Asociados	2014-11-25 21:16:07	0	0	32	t	11302	\N	f
121	Servicios Básicos 	2014-11-26 14:45:32	0	0	118	f	2110203		f
122	ISSS-Cuota Patronal	2014-11-26 14:46:29	0	0	118	f	2110204		f
35	Letras de Cambio	2014-11-25 21:16:52	0	0	34	t	1130201	\N	f
123	AFP´S Cuota Patronal 	2014-11-26 14:48:04	0	0	118	f	2110205		f
124	Intereses	2014-11-26 14:49:01	0	0	118	f	2110206		f
125	Cuentas por Pagar a Instituciones y Particulares 	2014-11-26 14:49:54	0	0	118	f	2110207		f
126	Retenciones por Pagar 	2014-11-26 14:51:24	0	0	114	f	21103		f
127	ISSS	2014-11-26 14:52:20	0	0	126	f	2110301		f
36	Pagares	2014-11-25 21:17:06	0	0	34	t	1130202	\N	f
37	Otras Cuentas por Cobrar	2014-11-25 21:17:50	0	0	32	t	11303	\N	f
38	Anticipos a Empleados	2014-11-25 21:18:07	0	0	37	t	1130301	\N	f
39	Pago de Gastos de Asociados	2014-11-25 21:18:22	0	0	37	t	1130302	\N	f
40	Cuentas por cobrar a Instituciones	2014-11-25 21:18:43	0	0	37	t	1130303	\N	f
41	PROVISION PARA CUENTAS INCOBRABLES (R)	2014-11-25 21:19:27	0	0	3	t	114	\N	f
42	Cuentas por Cobrar a Asociados	2014-11-25 21:23:19	0	0	41	t	11401	\N	f
43	Documentos por Cobrar a Asociados	2014-11-25 21:23:43	0	0	41	t	11402	\N	f
44	Otras Cuentas por Cobrar	2014-11-25 21:24:03	0	0	41	t	11403	\N	f
45	INVENTARIO DE MATERIALES DE FONTANERIA	2014-11-25 21:25:26	0	0	3	t	115	\N	f
46	Materiales y accesorios	2014-11-25 21:25:58	0	0	45	t	11501	\N	f
47	Equipos y herramientas	2014-11-25 21:26:17	0	0	45	t	11502	\N	f
48	DEPOSITOS A PLAZO FIJO	2014-11-25 21:27:22	0	0	3	t	116	\N	f
49	Banco Agrícola	2014-11-25 21:30:45	0	0	48	t	11601	\N	f
50	Banco Fomento Agropecuario	2014-11-25 21:31:39	0	0	48	t	11602	\N	f
51	ACORG	2014-11-25 21:34:03	0	0	48	t	11603	\N	f
52	Banco DAVIVIENDA	2014-11-25 21:34:20	0	0	48	t	11604	\N	f
128	AFP´S	2014-11-26 14:53:40	0	0	126	f	2110302		f
129	Impuestos Sobre la Renta 	2014-11-26 14:54:26	0	0	126	f	2110303		f
130	Cuotas sobre Préstamo 	2014-11-26 14:55:13	0	0	126	f	2110304		f
131	Vialidad	2014-11-26 14:55:44	0	0	126	f	2110305		f
132	DOCUMENTOS POR PAGAR (C.P.)	2014-11-26 14:56:41	0	0	95	f	212		f
133	Letras  de Cambio 	2014-11-26 14:57:48	0	0	132	f	21201		f
134	Pagares 	2014-11-26 14:58:23	0	0	132	f	21202		f
135	Otras Cuotas 	2014-11-26 14:59:06	0	0	132	f	21203		f
136	PRESTAMOS BANCARIOS (C.P.)	2014-11-26 15:00:18	0	0	95	f	213		f
137	Banco Agrícola 	2014-11-26 15:01:16	0	0	136	f	21301		f
138	ACORG, De R.L.	2014-11-26 15:02:07	0	0	136	f	21302		f
139	Banco DAVIVIENDA	2014-11-26 15:02:51	0	0	136	f	21303		f
140	Banco De Fomento Agropecuario 	2014-11-26 15:03:44	0	0	136	f	21304		f
141	Caja de Credito Suchitoto 	2014-11-26 15:04:21	0	0	136	f	21305		f
142	EXIGIBLE A LARGO PLAZO	2014-11-26 15:10:58	0	0	94	f	22		f
53	Banco CITIBANK	2014-11-25 21:34:36	0	0	48	t	11605	\N	f
54	PAGOS ANTICIPADOS	2014-11-25 21:34:58	0	0	3	t	117	\N	f
55	Alquileres	2014-11-25 21:35:19	0	0	54	t	11701	\N	f
56	Seguros	2014-11-25 21:35:37	0	0	54	t	11702	\N	f
57	Depósitos en Garantía	2014-11-25 21:35:57	0	0	54	t	11703	\N	f
58	Papeles y Útiles	2014-11-25 21:36:12	0	0	54	t	11704	\N	f
59	Honorarios Profesionales	2014-11-25 21:36:25	0	0	54	t	11705	\N	f
60	Anticipo de Sueldo	2014-11-25 21:36:39	0	0	54	t	11706	\N	f
64	FIJO	2014-11-25 21:44:25	0	0	1	t	12	\N	f
65	BIENES NO DEPRECIABLES	2014-11-25 21:45:16	0	0	64	t	121	\N	f
66	Terrenos	2014-11-25 21:45:33	0	0	65	t	12101	\N	f
67	BIENES DEPRECIABLES	2014-11-25 21:46:05	0	0	64	t	122	\N	f
68	Acueducto de agua potable	2014-11-25 21:46:57	0	0	67	t	12201	\N	f
69	Edificaciones	2014-11-25 21:47:16	0	0	67	t	12202	\N	f
70	Mobiliario y Equipo de Oficina	2014-11-25 21:47:31	0	0	67	t	12203	\N	f
71	Equipo de Transporte	2014-11-25 21:47:45	0	0	67	t	12204	\N	f
72	Herramientas	2014-11-25 21:47:58	0	0	67	t	12205	\N	f
74	DEPRECIACION ACUMULADA (R)	2014-11-25 21:48:58	0	0	64	t	123	\N	f
75	Acueducto de agua potable	2014-11-25 21:51:36	0	0	74	t	12301	\N	f
76	Edificaciones	2014-11-25 21:51:52	0	0	74	t	12302	\N	f
77	Modificaciones y Equipo de Oficina	2014-11-25 21:52:04	0	0	74	t	12303	\N	f
78	Equipo de Transporte	2014-11-25 21:52:14	0	0	74	t	12304	\N	f
79	Herramientas	2014-11-25 21:52:25	0	0	74	t	12305	\N	f
80	REVALUACIONES	2014-11-25 21:53:25	0	0	64	t	124	\N	f
81	Terrenos	2014-11-25 21:53:45	0	0	80	t	12401	\N	f
82	Sistema de Agua	2014-11-25 21:53:58	0	0	80	t	12402	\N	f
83	Edificaciones	2014-11-25 21:54:06	0	0	80	t	12403	\N	f
84	Equipo de Transporte	2014-11-25 21:54:17	0	0	80	t	12404	\N	f
85	OTROS ACTIVOS	2014-11-25 21:54:35	0	0	1	t	13	\N	f
86	CONSTRUCIONES EN PROCESO	2014-11-25 21:54:54	0	0	85	t	131	\N	f
87	Edificaciones 	2014-11-25 21:55:10	0	0	86	t	13101	\N	f
88	Ampliaciones de red distribución	2014-11-25 21:55:21	0	0	86	t	13102	\N	f
89	Otras	2014-11-25 21:55:32	0	0	86	t	13103	\N	f
96	PATRIMONIO	2014-11-26 11:25:17	0	0	\N	f	3		f
97	EGRESOS	2014-11-26 11:25:43	0	0	\N	f	4		f
98	FONDO PATRIMONIAL	2014-11-26 11:26:28	0	0	96	f	31		f
99	APORTACIONES PATRIMNIALES DE ASOCIADOS	2014-11-26 11:26:58	0	0	98	f	311		f
100	Efectivo	2014-11-26 11:27:35	0	0	99	f	31101		f
101	Especie (Jornales)	2014-11-26 11:28:06	0	0	99	f	31102		f
102	FONDO PATRIMONIAL DE ACTIVO FIJO	2014-11-26 11:28:40	0	0	98	f	312		f
103	Fundaciones	2014-11-26 11:29:06	0	0	102	f	31201		f
104	USAID – CARE El Salvador	2014-11-26 11:29:38	0	0	102	f	31202		f
105	Alcaldía Municipales	2014-11-26 11:30:02	0	0	102	f	31203		f
106	ADESCO	2014-11-26 11:30:32	0	0	102	f	31204		f
107	FONDO PATRIMONIAL DE EXEDENTES	2014-11-26 11:31:08	0	0	98	f	313		f
108	De Ejercicios Anteriores	2014-11-26 11:31:40	0	0	107	f	31301		f
109	De Ejercicios Actual	2014-11-26 11:32:06	0	0	107	f	31302		f
110	RESERVAS POR REVALUACIONES	2014-11-26 11:32:41	0	0	98	f	314		f
111	DEFICIT (R)	2014-11-26 11:33:14	0	0	98	f	315		f
112	De Ejercicios Anteriores	2014-11-26 11:33:40	0	0	111	f	31501		f
113	De Ejercicios Actual	2014-11-26 11:34:05	0	0	111	f	31502		f
143	DOCUMENTOS POR PAGAR (L.P.)	2014-11-26 15:11:55	0	0	142	f	221		f
144	Letras de Cambio	2014-11-26 15:12:39	0	0	143	f	22101		f
145	Pagares	2014-11-26 15:13:07	0	0	143	f	22102		f
146	Otras Cuentas	2014-11-26 15:13:39	0	0	143	f	22103		f
147	OTROS PASIVOS	2014-11-26 15:14:20	0	0	94	f	23		f
148	INGRESOS RECIBIDOS POR ANTICIPO DE ASOCIADOS 	2014-11-26 15:15:38	0	0	147	f	231		f
149	PROVISIONES PARA OBLIGACIONES LABORALES 	2014-11-26 15:16:21	0	0	147	f	232		f
152	GASTOS POR SERVICIO DE AGUA 	2014-11-26 15:25:06	0	0	151	f	411		f
150	INGRESOS	2014-11-26 15:18:37	0	0	\N	f	5		f
153	INGRESOS	2014-11-26 15:26:01	0	0	150	f	51		f
154	APORTACIONES NO PATRIMONIALES DE ASOCIADOS	2014-11-26 15:26:28	0	0	153	f	511		f
155	Por servicio de agua	2014-11-26 15:26:44	0	0	154	f	51101		f
156	Sueldos y Salarios 	2014-11-26 15:26:45	0	0	152	f	41101		f
157	Afiliación nuevos servicios	2014-11-26 15:27:05	0	0	154	f	51102		f
158	Recargos	2014-11-26 15:27:23	0	0	154	f	51103		f
159	Otros	2014-11-26 15:27:40	0	0	154	f	51104		f
160	Vacaciones y Aguinaldos 	2014-11-26 15:29:40	0	0	152	f	41102		f
161	DONACIONES NO RESTRINGIDAS	2014-11-26 15:30:02	0	0	153	f	512		f
162	Cuota Patronal ISSS	2014-11-26 15:30:35	0	0	152	f	41103		f
163	INTERESES RECIBIDOS POR OPERCIONES FINANCIERAS	2014-11-26 15:31:11	0	0	153	f	513		f
164	Intereses ganados en banco	2014-11-26 15:31:43	0	0	163	f	51301		f
165	REBAJAS Y DEVOLUCIONES SOBRE BIENES Y SERVICIOS	2014-11-26 15:32:14	0	0	153	f	514		f
166	Cuotas Patrimonial AFP´S	2014-11-26 15:32:23	0	0	152	f	41104		f
167	Rebajas y devoluciones sobre compras de bienes 	2014-11-26 15:32:38	0	0	165	f	51401		f
168	Rebajas y devoluciones sobre compra de servicios 	2014-11-26 15:32:56	0	0	165	f	51402		f
169	Indemnozación 	2014-11-26 15:34:06	0	0	152	f	41105		f
170	Bonificaciones	2014-11-26 15:34:40	0	0	152	f	41106		f
171	Viáticos y Transporte	2014-11-26 15:35:33	0	0	152	f	41107		f
172	Honorarios Profesionales	2014-11-26 15:36:57	0	0	152	f	41108		f
173	Seguros 	2014-11-26 15:37:31	0	0	152	f	41109		f
174	Talonarios de Recibos 	2014-11-26 15:40:57	0	0	152	f	411010		f
175	Atención al Personal	2014-11-26 15:41:39	0	0	152	f	411011		f
176	Alquileres	2014-11-26 15:42:06	0	0	152	f	411012		f
177	CUENTA DE CIERRE	2014-11-26 15:42:57	0	0	\N	f	6		f
178	CUENTA LIQUIDADORA	2014-11-26 15:43:24	0	0	177	f	61		f
179	EXEDENTES Y DEFICIT	2014-11-26 15:43:42	0	0	178	f	611		f
180	Reparación y Mantenimiento de Sistema de Agua	2014-11-26 15:43:55	0	0	152	f	411013		f
181	CUENTAS DE ORDEN	2014-11-26 15:44:04	0	0	\N	f	7		f
182	CUENTAS DE ORDEN	2014-11-26 15:44:29	0	0	181	f	71		f
183	Limpieza de Pozo, Tanque y Cisterna	2014-11-26 15:44:39	0	0	152	f	411014		f
184	CUENTAS DE ORDEN	2014-11-26 15:44:42	0	0	182	f	711		f
185	Gastos por servicio de agua	2014-11-26 15:45:01	0	0	184	f	71101		f
186	Cloro 	2014-11-26 15:45:01	0	0	152	f	411015		f
187	Gastos de Administración	2014-11-26 15:45:19	0	0	184	f	71102		f
188	Energía Eléctrica 	2014-11-26 15:46:26	0	0	152	f	411016		f
189	Materiales y Accesorios Utilzados 	2014-11-26 15:47:56	0	0	152	f	411017		f
190	Exámenes Bacteriológicos	2014-11-26 15:48:50	0	0	152	f	411018		f
191	Atenciones Sociales	2014-11-26 15:49:26	0	0	152	f	411019		f
192	Combustible y Lubricantes 	2014-11-26 15:51:13	0	0	152	f	411020		f
193	Reparaciones y Mantenimiento de Equipo de Transporte	2014-11-26 15:52:14	0	0	152	f	411021		f
194	Pagos Temporales 	2014-11-26 15:53:17	0	0	152	f	411022		f
195	Vigilancia Temporal 	2014-11-26 15:53:59	0	0	152	f	411023		f
196	Cuentas Incobrables 	2014-11-26 16:01:54	0	0	152	f	411024		f
197	Materiales de Aseo y Limpieza	2014-11-26 16:02:23	0	0	152	f	411025		f
198	Descuentos a Asociados 	2014-11-26 16:02:47	0	0	152	f	411026		f
199	Depreciaciones 	2014-11-26 16:03:17	0	0	152	f	411027		f
200	Materiales Pétreos 	2014-11-26 16:03:46	0	0	152	f	411028		f
201	Perdidas en Agua Servida 	2014-11-26 16:04:10	0	0	152	f	411029		f
202	Consumo Telefonico 	2014-11-26 16:04:40	0	0	152	f	411030		f
203	Fallas en distribución 	2014-11-26 16:05:16	0	0	152	f	411031		f
205	Gastos Varios 	2014-11-26 16:06:15	0	0	152	f	411033		f
207	Sueldos y Salarios	2014-11-26 16:18:19	0	0	206	f	41201		f
208	Vacaciones y Aguinaldos 	2014-11-26 16:18:53	0	0	206	f	41202		f
206	GASTOS ADMINISTRATIVOS 	2014-11-26 16:16:42	0	0	151	f	412		f
209	Cuota Patronal ISSS	2014-11-26 16:20:36	0	0	206	f	41203		f
210	Cuota Patronal AFP´S	2014-11-26 16:21:07	0	0	206	f	41204		f
211	Bonificacines 	2014-11-26 16:21:35	0	0	206	f	41205		f
212	Indemnizaciones 	2014-11-26 16:22:07	0	0	206	f	41206		f
213	Viáticos y Transporte	2014-11-26 16:23:35	0	0	206	f	41207		f
214	Dietas a Directivos 	2014-11-26 16:24:13	0	0	206	f	41208		f
215	Honorarios Profesionales 	2014-11-26 16:24:54	0	0	206	f	41209		f
216	Seguros	2014-11-26 16:25:24	0	0	206	f	412010		f
217	Papelería y Utiles 	2014-11-26 16:26:10	0	0	206	f	412011		f
218	Fotocopias	2014-11-26 16:26:40	0	0	206	f	412012		f
219	Alquileres 	2014-11-26 16:27:31	0	0	206	f	412013		f
220	Suscripciones	2014-11-26 16:28:04	0	0	206	f	412014		f
221	Combustibles y Lubricantes	2014-11-26 16:28:55	0	0	206	f	412015		f
222	Telecomunicaciones y Correos 	2014-11-26 16:29:32	0	0	206	f	412016		f
223	Energía Electrica 	2014-11-26 16:30:10	0	0	206	f	412017		f
224	Atenciones Sociales 	2014-11-26 16:30:48	0	0	206	f	412018		f
225	Atenciones a Usuarios 	2014-11-26 16:31:27	0	0	206	f	412019		f
226	Útiles de Aseo y Limpieza 	2014-11-26 16:32:13	0	0	206	f	412020		f
227	Pagos Temporales 	2014-11-26 16:32:36	0	0	206	f	412021		f
228	Mantenimiento de Instalación	2014-11-26 16:33:34	0	0	206	f	412022		f
229	Mantenimiento de Mobiliario y Equipo	2014-11-26 16:34:21	0	0	206	f	412023		f
230	Reparación y Mantenimiento Equipo de Transporte	2014-11-26 16:36:06	0	0	206	f	412024		f
231	Fletes y Encomiendas	2014-11-26 16:37:45	0	0	206	f	412025		f
232	Compensaciones e incentivos	2014-11-26 16:38:41	0	0	206	f	412026		f
233	Gastos Varios 	2014-11-26 16:39:08	0	0	206	f	412027		f
234	GASTOS FINANCIEROS	2014-11-26 16:43:13	0	0	151	f	413		f
235	Gastos Notariales	2014-11-26 16:45:20	0	0	234	f	41301		f
236	Comisiones Bancarias	2014-11-26 16:46:26	0	0	234	f	41302		f
237	Intereses	2014-11-26 16:47:16	0	0	234	f	41303		f
238	Diferencia en Tipo de Cambio 	2014-11-26 16:48:27	0	0	234	f	41304		f
239	Gastos Varios 	2014-11-26 16:49:40	0	0	234	f	41305		f
240	OTROS GASTOS	2014-11-26 16:50:55	0	0	151	f	414		f
241	Donaciones 	2014-11-26 16:51:32	0	0	240	f	41401		f
242	Perdidas en Retiro o Ventas de Activo Fijo	2014-11-26 16:52:25	0	0	240	f	41402		f
247	PROYECTOS DE SALUD Y MEDIO AMBIENTE 	2014-11-26 17:24:54	0	0	246	f	421		f
248	Sueldos y Salarios 	2014-11-26 17:26:34	0	0	247	f	42101		f
249	Vacaciones y Aguinaldos 	2014-11-26 17:27:10	0	0	247	f	42102		f
250	Cuota Patronal ISSS	2014-11-26 17:29:02	0	0	247	f	42103		f
251	Cuota Patronla AFP´S	2014-11-26 17:29:40	0	0	247	f	42104		f
252	Bonificaciones 	2014-11-26 17:30:04	0	0	247	f	42105		f
253	Indemnizaciones 	2014-11-26 17:30:56	0	0	247	f	42106		f
254	Viáticos y Transporte 	2014-11-26 17:31:34	0	0	247	f	42107		f
255	Dietas a Directivos 	2014-11-26 17:32:16	0	0	247	f	42108		f
256	Honorarios Profecionales 	2014-11-26 17:32:52	0	0	247	f	42109		f
257	Seguros 	2014-11-26 17:33:20	0	0	247	f	421010		f
258	Papelería y Útiles	2014-11-26 17:34:02	0	0	247	f	421011		f
260	Alquiles 	2014-11-26 17:35:06	0	0	247	f	421013		f
261	Suscripciones 	2014-11-26 17:35:59	0	0	247	f	421014		f
262	Combustible y Lubricantes	2014-11-26 17:38:24	0	0	247	f	421015		f
263	Telecomunicaciones y Correos 	2014-11-26 17:38:56	0	0	247	f	421016		f
264	Energía Eléctrica	2014-11-26 17:39:49	0	0	247	f	421017		f
265	Atenciones Saciales 	2014-11-26 17:40:17	0	0	247	f	421018		f
266	Atenciones Personales 	2014-11-26 17:40:43	0	0	247	f	421019		f
267	Útiles de Aseo i Limpieza	2014-11-26 17:41:18	0	0	247	f	421020		f
268	Vigilancia Temporal 	2014-11-26 17:41:40	0	0	247	f	421021		f
269	Mantenimiento de Instalaciones 	2014-11-26 17:42:15	0	0	247	f	421022		f
270	Matenimiento de Mobiliario y Equipo	2014-11-26 17:42:49	0	0	247	f	421023		f
271	Reparacion y Mantenimiento de Equipo de Transporte 	2014-11-26 17:43:33	0	0	247	f	421024		f
272	Gastos Varios 	2014-11-26 17:43:58	0	0	247	f	421025		f
259	Fotocopias 	2014-11-26 17:34:37	6357.75	0	247	f	421012		f
246	GASTOS POR EJECUCION DE PROGRAMAS Y PROYECTOS	2014-11-26 17:24:12	6357.75	0	97	f	42		f
204	Refrigerios 	2014-11-26 16:05:47	0	6357.75	152	f	411032		f
151	GASTOS DE OPERACIÓN 	2014-11-26 15:24:33	0	6357.75	97	f	41		f
\.


--
-- TOC entry 2656 (class 0 OID 0)
-- Dependencies: 193
-- Name: scr_cuenta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_cuenta_id_seq', 272, true);


--
-- TOC entry 2535 (class 0 OID 17457)
-- Dependencies: 194 2590
-- Data for Name: scr_det_contable; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_det_contable (id, "dConIniPeriodo", "dConFinPeriodo", "dConActivo", "dConSimboloMoneda", "dConPagoXMes", organizacion_id, empleado_id) FROM stdin;
7	2014-11-26	2014-12-31	f	$	1	1	1
9	2015-01-06	2015-12-06	t	$	1	1	1
\.


--
-- TOC entry 2537 (class 0 OID 17467)
-- Dependencies: 196 2590
-- Data for Name: scr_det_factura; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_det_factura (id, det_factur_numero, det_factur_fecha, socio_id, cancelada, fecha_cancelada, total, limite_pago) FROM stdin;
3970	3970	2015-02-16 20:51:44.402592	26	f	\N	317.25	2015-02-28
3968	3968	2015-02-16 20:51:44.402592	9	f	\N	5.25	2015-02-28
3969	3969	2015-02-16 20:51:44.402592	25	f	\N	5.25	2015-02-28
3971	3971	2015-02-16 20:51:44.402592	27	f	\N	5.25	2015-02-28
3972	3972	2015-02-16 20:51:44.402592	30	f	\N	5.25	2015-02-28
3973	3973	2015-02-16 20:51:44.402592	712	f	\N	5.25	2015-02-28
3974	3974	2015-02-16 20:51:44.402592	713	f	\N	5.25	2015-02-28
3975	3975	2015-02-16 20:51:44.402592	714	f	\N	5.25	2015-02-28
3976	3976	2015-02-16 20:51:44.402592	32	f	\N	5.25	2015-02-28
3977	3977	2015-02-16 20:51:44.402592	33	f	\N	5.25	2015-02-28
3978	3978	2015-02-16 20:51:44.402592	38	f	\N	5.25	2015-02-28
3979	3979	2015-02-16 20:51:44.402592	39	f	\N	5.25	2015-02-28
3980	3980	2015-02-16 20:51:44.402592	40	f	\N	5.25	2015-02-28
3981	3981	2015-02-16 20:51:44.402592	41	f	\N	5.25	2015-02-28
3982	3982	2015-02-16 20:51:44.402592	43	f	\N	5.25	2015-02-28
3983	3983	2015-02-16 20:51:44.402592	44	f	\N	5.25	2015-02-28
3984	3984	2015-02-16 20:51:44.402592	45	f	\N	5.25	2015-02-28
3985	3985	2015-02-16 20:51:44.402592	46	f	\N	5.25	2015-02-28
3986	3986	2015-02-16 20:51:44.402592	47	f	\N	5.25	2015-02-28
3987	3987	2015-02-16 20:51:44.402592	48	f	\N	5.25	2015-02-28
3988	3988	2015-02-16 20:51:44.402592	49	f	\N	5.25	2015-02-28
3989	3989	2015-02-16 20:51:44.402592	50	f	\N	5.25	2015-02-28
3990	3990	2015-02-16 20:51:44.402592	51	f	\N	5.25	2015-02-28
3991	3991	2015-02-16 20:51:44.402592	52	f	\N	5.25	2015-02-28
3992	3992	2015-02-16 20:51:44.402592	53	f	\N	5.25	2015-02-28
3993	3993	2015-02-16 20:51:44.402592	54	f	\N	5.25	2015-02-28
3994	3994	2015-02-16 20:51:44.402592	55	f	\N	5.25	2015-02-28
3995	3995	2015-02-16 20:51:44.402592	56	f	\N	5.25	2015-02-28
3996	3996	2015-02-16 20:51:44.402592	57	f	\N	5.25	2015-02-28
3997	3997	2015-02-16 20:51:44.402592	58	f	\N	5.25	2015-02-28
3998	3998	2015-02-16 20:51:44.402592	59	f	\N	5.25	2015-02-28
3999	3999	2015-02-16 20:51:44.402592	60	f	\N	5.25	2015-02-28
4000	4000	2015-02-16 20:51:44.402592	61	f	\N	5.25	2015-02-28
4001	4001	2015-02-16 20:51:44.402592	62	f	\N	5.25	2015-02-28
4002	4002	2015-02-16 20:51:44.402592	63	f	\N	5.25	2015-02-28
4003	4003	2015-02-16 20:51:44.402592	64	f	\N	5.25	2015-02-28
4004	4004	2015-02-16 20:51:44.402592	65	f	\N	5.25	2015-02-28
4005	4005	2015-02-16 20:51:44.402592	67	f	\N	5.25	2015-02-28
4006	4006	2015-02-16 20:51:44.402592	68	f	\N	5.25	2015-02-28
4007	4007	2015-02-16 20:51:44.402592	70	f	\N	5.25	2015-02-28
4008	4008	2015-02-16 20:51:44.402592	71	f	\N	5.25	2015-02-28
4009	4009	2015-02-16 20:51:44.402592	72	f	\N	5.25	2015-02-28
4010	4010	2015-02-16 20:51:44.402592	73	f	\N	5.25	2015-02-28
4011	4011	2015-02-16 20:51:44.402592	74	f	\N	5.25	2015-02-28
4012	4012	2015-02-16 20:51:44.402592	75	f	\N	5.25	2015-02-28
4013	4013	2015-02-16 20:51:44.402592	76	f	\N	5.25	2015-02-28
4014	4014	2015-02-16 20:51:44.402592	77	f	\N	5.25	2015-02-28
4015	4015	2015-02-16 20:51:44.402592	78	f	\N	5.25	2015-02-28
4016	4016	2015-02-16 20:51:44.402592	79	f	\N	5.25	2015-02-28
4017	4017	2015-02-16 20:51:44.402592	80	f	\N	5.25	2015-02-28
4018	4018	2015-02-16 20:51:44.402592	82	f	\N	5.25	2015-02-28
4019	4019	2015-02-16 20:51:44.402592	85	f	\N	5.25	2015-02-28
4020	4020	2015-02-16 20:51:44.402592	86	f	\N	5.25	2015-02-28
4021	4021	2015-02-16 20:51:44.402592	87	f	\N	5.25	2015-02-28
4022	4022	2015-02-16 20:51:44.402592	88	f	\N	5.25	2015-02-28
4023	4023	2015-02-16 20:51:44.402592	91	f	\N	5.25	2015-02-28
4024	4024	2015-02-16 20:51:44.402592	92	f	\N	5.25	2015-02-28
4025	4025	2015-02-16 20:51:44.402592	93	f	\N	5.25	2015-02-28
4026	4026	2015-02-16 20:51:44.402592	94	f	\N	5.25	2015-02-28
4027	4027	2015-02-16 20:51:44.402592	95	f	\N	5.25	2015-02-28
4028	4028	2015-02-16 20:51:44.402592	96	f	\N	5.25	2015-02-28
4029	4029	2015-02-16 20:51:44.402592	97	f	\N	5.25	2015-02-28
4030	4030	2015-02-16 20:51:44.402592	98	f	\N	5.25	2015-02-28
4031	4031	2015-02-16 20:51:44.402592	99	f	\N	5.25	2015-02-28
4032	4032	2015-02-16 20:51:44.402592	100	f	\N	5.25	2015-02-28
4033	4033	2015-02-16 20:51:44.402592	101	f	\N	5.25	2015-02-28
4034	4034	2015-02-16 20:51:44.402592	102	f	\N	5.25	2015-02-28
4035	4035	2015-02-16 20:51:44.402592	103	f	\N	5.25	2015-02-28
4036	4036	2015-02-16 20:51:44.402592	104	f	\N	5.25	2015-02-28
4037	4037	2015-02-16 20:51:44.402592	105	f	\N	5.25	2015-02-28
4038	4038	2015-02-16 20:51:44.402592	106	f	\N	5.25	2015-02-28
4039	4039	2015-02-16 20:51:44.402592	107	f	\N	5.25	2015-02-28
4040	4040	2015-02-16 20:51:44.402592	108	f	\N	5.25	2015-02-28
4041	4041	2015-02-16 20:51:44.402592	110	f	\N	5.25	2015-02-28
4042	4042	2015-02-16 20:51:44.402592	111	f	\N	5.25	2015-02-28
4043	4043	2015-02-16 20:51:44.402592	112	f	\N	5.25	2015-02-28
4044	4044	2015-02-16 20:51:44.402592	114	f	\N	5.25	2015-02-28
4045	4045	2015-02-16 20:51:44.402592	115	f	\N	5.25	2015-02-28
4046	4046	2015-02-16 20:51:44.402592	116	f	\N	5.25	2015-02-28
4047	4047	2015-02-16 20:51:44.402592	117	f	\N	5.25	2015-02-28
4048	4048	2015-02-16 20:51:44.402592	118	f	\N	5.25	2015-02-28
4049	4049	2015-02-16 20:51:44.402592	119	f	\N	5.25	2015-02-28
4050	4050	2015-02-16 20:51:44.402592	120	f	\N	5.25	2015-02-28
4051	4051	2015-02-16 20:51:44.402592	121	f	\N	5.25	2015-02-28
4052	4052	2015-02-16 20:51:44.402592	122	f	\N	5.25	2015-02-28
4053	4053	2015-02-16 20:51:44.402592	123	f	\N	5.25	2015-02-28
4054	4054	2015-02-16 20:51:44.402592	124	f	\N	5.25	2015-02-28
4055	4055	2015-02-16 20:51:44.402592	125	f	\N	5.25	2015-02-28
4056	4056	2015-02-16 20:51:44.402592	128	f	\N	5.25	2015-02-28
4057	4057	2015-02-16 20:51:44.402592	130	f	\N	5.25	2015-02-28
4058	4058	2015-02-16 20:51:44.402592	131	f	\N	5.25	2015-02-28
4059	4059	2015-02-16 20:51:44.402592	132	f	\N	5.25	2015-02-28
4060	4060	2015-02-16 20:51:44.402592	137	f	\N	5.25	2015-02-28
4061	4061	2015-02-16 20:51:44.402592	138	f	\N	5.25	2015-02-28
4062	4062	2015-02-16 20:51:44.402592	139	f	\N	5.25	2015-02-28
4063	4063	2015-02-16 20:51:44.402592	142	f	\N	5.25	2015-02-28
4064	4064	2015-02-16 20:51:44.402592	143	f	\N	5.25	2015-02-28
4065	4065	2015-02-16 20:51:44.402592	144	f	\N	5.25	2015-02-28
4066	4066	2015-02-16 20:51:44.402592	145	f	\N	5.25	2015-02-28
4067	4067	2015-02-16 20:51:44.402592	146	f	\N	5.25	2015-02-28
4068	4068	2015-02-16 20:51:44.402592	147	f	\N	5.25	2015-02-28
4069	4069	2015-02-16 20:51:44.402592	148	f	\N	5.25	2015-02-28
4070	4070	2015-02-16 20:51:44.402592	151	f	\N	5.25	2015-02-28
4071	4071	2015-02-16 20:51:44.402592	153	f	\N	5.25	2015-02-28
4072	4072	2015-02-16 20:51:44.402592	154	f	\N	5.25	2015-02-28
4073	4073	2015-02-16 20:51:44.402592	155	f	\N	5.25	2015-02-28
4074	4074	2015-02-16 20:51:44.402592	156	f	\N	5.25	2015-02-28
4075	4075	2015-02-16 20:51:44.402592	159	f	\N	5.25	2015-02-28
4076	4076	2015-02-16 20:51:44.402592	160	f	\N	5.25	2015-02-28
4077	4077	2015-02-16 20:51:44.402592	161	f	\N	5.25	2015-02-28
4078	4078	2015-02-16 20:51:44.402592	162	f	\N	5.25	2015-02-28
4079	4079	2015-02-16 20:51:44.402592	165	f	\N	5.25	2015-02-28
4080	4080	2015-02-16 20:51:44.402592	169	f	\N	5.25	2015-02-28
4081	4081	2015-02-16 20:51:44.402592	170	f	\N	5.25	2015-02-28
4082	4082	2015-02-16 20:51:44.402592	171	f	\N	5.25	2015-02-28
4083	4083	2015-02-16 20:51:44.402592	172	f	\N	5.25	2015-02-28
4084	4084	2015-02-16 20:51:44.402592	173	f	\N	5.25	2015-02-28
4085	4085	2015-02-16 20:51:44.402592	174	f	\N	5.25	2015-02-28
4086	4086	2015-02-16 20:51:44.402592	175	f	\N	5.25	2015-02-28
4087	4087	2015-02-16 20:51:44.402592	176	f	\N	5.25	2015-02-28
4088	4088	2015-02-16 20:51:44.402592	177	f	\N	5.25	2015-02-28
4089	4089	2015-02-16 20:51:44.402592	178	f	\N	5.25	2015-02-28
4090	4090	2015-02-16 20:51:44.402592	179	f	\N	5.25	2015-02-28
4091	4091	2015-02-16 20:51:44.402592	180	f	\N	5.25	2015-02-28
4092	4092	2015-02-16 20:51:44.402592	181	f	\N	5.25	2015-02-28
4093	4093	2015-02-16 20:51:44.402592	182	f	\N	5.25	2015-02-28
4094	4094	2015-02-16 20:51:44.402592	183	f	\N	5.25	2015-02-28
4095	4095	2015-02-16 20:51:44.402592	184	f	\N	5.25	2015-02-28
4096	4096	2015-02-16 20:51:44.402592	185	f	\N	5.25	2015-02-28
4097	4097	2015-02-16 20:51:44.402592	186	f	\N	5.25	2015-02-28
4098	4098	2015-02-16 20:51:44.402592	187	f	\N	5.25	2015-02-28
4099	4099	2015-02-16 20:51:44.402592	188	f	\N	5.25	2015-02-28
4100	4100	2015-02-16 20:51:44.402592	189	f	\N	5.25	2015-02-28
4101	4101	2015-02-16 20:51:44.402592	190	f	\N	5.25	2015-02-28
4102	4102	2015-02-16 20:51:44.402592	191	f	\N	5.25	2015-02-28
4103	4103	2015-02-16 20:51:44.402592	192	f	\N	5.25	2015-02-28
4104	4104	2015-02-16 20:51:44.402592	193	f	\N	5.25	2015-02-28
4105	4105	2015-02-16 20:51:44.402592	194	f	\N	5.25	2015-02-28
4106	4106	2015-02-16 20:51:44.402592	195	f	\N	5.25	2015-02-28
4107	4107	2015-02-16 20:51:44.402592	196	f	\N	5.25	2015-02-28
4108	4108	2015-02-16 20:51:44.402592	197	f	\N	5.25	2015-02-28
4109	4109	2015-02-16 20:51:44.402592	198	f	\N	5.25	2015-02-28
4110	4110	2015-02-16 20:51:44.402592	199	f	\N	5.25	2015-02-28
4111	4111	2015-02-16 20:51:44.402592	200	f	\N	5.25	2015-02-28
4112	4112	2015-02-16 20:51:44.402592	201	f	\N	5.25	2015-02-28
4113	4113	2015-02-16 20:51:44.402592	202	f	\N	5.25	2015-02-28
4114	4114	2015-02-16 20:51:44.402592	203	f	\N	5.25	2015-02-28
4115	4115	2015-02-16 20:51:44.402592	204	f	\N	5.25	2015-02-28
4116	4116	2015-02-16 20:51:44.402592	205	f	\N	5.25	2015-02-28
4117	4117	2015-02-16 20:51:44.402592	206	f	\N	5.25	2015-02-28
4118	4118	2015-02-16 20:51:44.402592	207	f	\N	5.25	2015-02-28
4119	4119	2015-02-16 20:51:44.402592	208	f	\N	5.25	2015-02-28
4120	4120	2015-02-16 20:51:44.402592	209	f	\N	5.25	2015-02-28
4121	4121	2015-02-16 20:51:44.402592	210	f	\N	5.25	2015-02-28
4122	4122	2015-02-16 20:51:44.402592	211	f	\N	5.25	2015-02-28
4123	4123	2015-02-16 20:51:44.402592	214	f	\N	5.25	2015-02-28
4124	4124	2015-02-16 20:51:44.402592	215	f	\N	5.25	2015-02-28
4125	4125	2015-02-16 20:51:44.402592	216	f	\N	5.25	2015-02-28
4126	4126	2015-02-16 20:51:44.402592	217	f	\N	5.25	2015-02-28
4127	4127	2015-02-16 20:51:44.402592	218	f	\N	5.25	2015-02-28
4128	4128	2015-02-16 20:51:44.402592	219	f	\N	5.25	2015-02-28
4129	4129	2015-02-16 20:51:44.402592	220	f	\N	5.25	2015-02-28
4130	4130	2015-02-16 20:51:44.402592	221	f	\N	5.25	2015-02-28
4131	4131	2015-02-16 20:51:44.402592	223	f	\N	5.25	2015-02-28
4132	4132	2015-02-16 20:51:44.402592	224	f	\N	5.25	2015-02-28
4133	4133	2015-02-16 20:51:44.402592	226	f	\N	5.25	2015-02-28
4134	4134	2015-02-16 20:51:44.402592	227	f	\N	5.25	2015-02-28
4135	4135	2015-02-16 20:51:44.402592	228	f	\N	5.25	2015-02-28
4136	4136	2015-02-16 20:51:44.402592	229	f	\N	5.25	2015-02-28
4137	4137	2015-02-16 20:51:44.402592	230	f	\N	5.25	2015-02-28
4138	4138	2015-02-16 20:51:44.402592	231	f	\N	5.25	2015-02-28
4139	4139	2015-02-16 20:51:44.402592	232	f	\N	5.25	2015-02-28
4140	4140	2015-02-16 20:51:44.402592	233	f	\N	5.25	2015-02-28
4141	4141	2015-02-16 20:51:44.402592	234	f	\N	5.25	2015-02-28
4142	4142	2015-02-16 20:51:44.402592	236	f	\N	5.25	2015-02-28
4143	4143	2015-02-16 20:51:44.402592	237	f	\N	5.25	2015-02-28
4144	4144	2015-02-16 20:51:44.402592	238	f	\N	5.25	2015-02-28
4145	4145	2015-02-16 20:51:44.402592	239	f	\N	5.25	2015-02-28
4146	4146	2015-02-16 20:51:44.402592	240	f	\N	5.25	2015-02-28
4147	4147	2015-02-16 20:51:44.402592	242	f	\N	5.25	2015-02-28
4148	4148	2015-02-16 20:51:44.402592	243	f	\N	5.25	2015-02-28
4149	4149	2015-02-16 20:51:44.402592	244	f	\N	5.25	2015-02-28
4150	4150	2015-02-16 20:51:44.402592	245	f	\N	5.25	2015-02-28
4151	4151	2015-02-16 20:51:44.402592	246	f	\N	5.25	2015-02-28
4152	4152	2015-02-16 20:51:44.402592	247	f	\N	5.25	2015-02-28
4153	4153	2015-02-16 20:51:44.402592	248	f	\N	5.25	2015-02-28
4154	4154	2015-02-16 20:51:44.402592	249	f	\N	5.25	2015-02-28
4155	4155	2015-02-16 20:51:44.402592	250	f	\N	5.25	2015-02-28
4156	4156	2015-02-16 20:51:44.402592	252	f	\N	5.25	2015-02-28
4157	4157	2015-02-16 20:51:44.402592	253	f	\N	5.25	2015-02-28
4158	4158	2015-02-16 20:51:44.402592	255	f	\N	5.25	2015-02-28
4159	4159	2015-02-16 20:51:44.402592	256	f	\N	5.25	2015-02-28
4160	4160	2015-02-16 20:51:44.402592	257	f	\N	5.25	2015-02-28
4161	4161	2015-02-16 20:51:44.402592	258	f	\N	5.25	2015-02-28
4162	4162	2015-02-16 20:51:44.402592	259	f	\N	5.25	2015-02-28
4163	4163	2015-02-16 20:51:44.402592	260	f	\N	5.25	2015-02-28
4164	4164	2015-02-16 20:51:44.402592	261	f	\N	5.25	2015-02-28
4165	4165	2015-02-16 20:51:44.402592	262	f	\N	5.25	2015-02-28
4166	4166	2015-02-16 20:51:44.402592	263	f	\N	5.25	2015-02-28
4167	4167	2015-02-16 20:51:44.402592	264	f	\N	5.25	2015-02-28
4168	4168	2015-02-16 20:51:44.402592	265	f	\N	5.25	2015-02-28
4169	4169	2015-02-16 20:51:44.402592	266	f	\N	5.25	2015-02-28
4170	4170	2015-02-16 20:51:44.402592	267	f	\N	5.25	2015-02-28
4171	4171	2015-02-16 20:51:44.402592	268	f	\N	5.25	2015-02-28
4172	4172	2015-02-16 20:51:44.402592	269	f	\N	5.25	2015-02-28
4173	4173	2015-02-16 20:51:44.402592	271	f	\N	5.25	2015-02-28
4174	4174	2015-02-16 20:51:44.402592	272	f	\N	5.25	2015-02-28
4175	4175	2015-02-16 20:51:44.402592	273	f	\N	5.25	2015-02-28
4176	4176	2015-02-16 20:51:44.402592	274	f	\N	5.25	2015-02-28
4177	4177	2015-02-16 20:51:44.402592	275	f	\N	5.25	2015-02-28
4178	4178	2015-02-16 20:51:44.402592	276	f	\N	5.25	2015-02-28
4179	4179	2015-02-16 20:51:44.402592	278	f	\N	5.25	2015-02-28
4180	4180	2015-02-16 20:51:44.402592	279	f	\N	5.25	2015-02-28
4181	4181	2015-02-16 20:51:44.402592	280	f	\N	5.25	2015-02-28
4182	4182	2015-02-16 20:51:44.402592	281	f	\N	5.25	2015-02-28
4183	4183	2015-02-16 20:51:44.402592	282	f	\N	5.25	2015-02-28
4184	4184	2015-02-16 20:51:44.402592	283	f	\N	5.25	2015-02-28
4185	4185	2015-02-16 20:51:44.402592	284	f	\N	5.25	2015-02-28
4186	4186	2015-02-16 20:51:44.402592	286	f	\N	5.25	2015-02-28
4187	4187	2015-02-16 20:51:44.402592	287	f	\N	5.25	2015-02-28
4188	4188	2015-02-16 20:51:44.402592	288	f	\N	5.25	2015-02-28
4189	4189	2015-02-16 20:51:44.402592	289	f	\N	5.25	2015-02-28
4190	4190	2015-02-16 20:51:44.402592	290	f	\N	5.25	2015-02-28
4191	4191	2015-02-16 20:51:44.402592	291	f	\N	5.25	2015-02-28
4192	4192	2015-02-16 20:51:44.402592	292	f	\N	5.25	2015-02-28
4193	4193	2015-02-16 20:51:44.402592	293	f	\N	5.25	2015-02-28
4194	4194	2015-02-16 20:51:44.402592	295	f	\N	5.25	2015-02-28
4195	4195	2015-02-16 20:51:44.402592	309	f	\N	5.25	2015-02-28
4196	4196	2015-02-16 20:51:44.402592	310	f	\N	5.25	2015-02-28
4197	4197	2015-02-16 20:51:44.402592	311	f	\N	5.25	2015-02-28
4198	4198	2015-02-16 20:51:44.402592	312	f	\N	5.25	2015-02-28
4199	4199	2015-02-16 20:51:44.402592	313	f	\N	5.25	2015-02-28
4200	4200	2015-02-16 20:51:44.402592	314	f	\N	5.25	2015-02-28
4201	4201	2015-02-16 20:51:44.402592	315	f	\N	5.25	2015-02-28
4202	4202	2015-02-16 20:51:44.402592	317	f	\N	5.25	2015-02-28
4203	4203	2015-02-16 20:51:44.402592	318	f	\N	5.25	2015-02-28
4204	4204	2015-02-16 20:51:44.402592	320	f	\N	5.25	2015-02-28
4205	4205	2015-02-16 20:51:44.402592	321	f	\N	5.25	2015-02-28
4206	4206	2015-02-16 20:51:44.402592	322	f	\N	5.25	2015-02-28
4207	4207	2015-02-16 20:51:44.402592	323	f	\N	5.25	2015-02-28
4208	4208	2015-02-16 20:51:44.402592	324	f	\N	5.25	2015-02-28
4209	4209	2015-02-16 20:51:44.402592	325	f	\N	5.25	2015-02-28
4210	4210	2015-02-16 20:51:44.402592	326	f	\N	5.25	2015-02-28
4211	4211	2015-02-16 20:51:44.402592	327	f	\N	5.25	2015-02-28
4212	4212	2015-02-16 20:51:44.402592	328	f	\N	5.25	2015-02-28
4213	4213	2015-02-16 20:51:44.402592	329	f	\N	5.25	2015-02-28
4214	4214	2015-02-16 20:51:44.402592	330	f	\N	5.25	2015-02-28
4215	4215	2015-02-16 20:51:44.402592	331	f	\N	5.25	2015-02-28
4216	4216	2015-02-16 20:51:44.402592	332	f	\N	5.25	2015-02-28
4217	4217	2015-02-16 20:51:44.402592	333	f	\N	5.25	2015-02-28
4218	4218	2015-02-16 20:51:44.402592	334	f	\N	5.25	2015-02-28
4219	4219	2015-02-16 20:51:44.402592	335	f	\N	5.25	2015-02-28
4220	4220	2015-02-16 20:51:44.402592	336	f	\N	5.25	2015-02-28
4221	4221	2015-02-16 20:51:44.402592	337	f	\N	5.25	2015-02-28
4222	4222	2015-02-16 20:51:44.402592	340	f	\N	5.25	2015-02-28
4223	4223	2015-02-16 20:51:44.402592	341	f	\N	5.25	2015-02-28
4224	4224	2015-02-16 20:51:44.402592	342	f	\N	5.25	2015-02-28
4225	4225	2015-02-16 20:51:44.402592	343	f	\N	5.25	2015-02-28
4226	4226	2015-02-16 20:51:44.402592	344	f	\N	5.25	2015-02-28
4227	4227	2015-02-16 20:51:44.402592	345	f	\N	5.25	2015-02-28
4228	4228	2015-02-16 20:51:44.402592	346	f	\N	5.25	2015-02-28
4229	4229	2015-02-16 20:51:44.402592	347	f	\N	5.25	2015-02-28
4230	4230	2015-02-16 20:51:44.402592	348	f	\N	5.25	2015-02-28
4231	4231	2015-02-16 20:51:44.402592	349	f	\N	5.25	2015-02-28
4232	4232	2015-02-16 20:51:44.402592	350	f	\N	5.25	2015-02-28
4233	4233	2015-02-16 20:51:44.402592	351	f	\N	5.25	2015-02-28
4234	4234	2015-02-16 20:51:44.402592	353	f	\N	5.25	2015-02-28
4235	4235	2015-02-16 20:51:44.402592	354	f	\N	5.25	2015-02-28
4236	4236	2015-02-16 20:51:44.402592	355	f	\N	5.25	2015-02-28
4237	4237	2015-02-16 20:51:44.402592	356	f	\N	5.25	2015-02-28
4238	4238	2015-02-16 20:51:44.402592	357	f	\N	5.25	2015-02-28
4239	4239	2015-02-16 20:51:44.402592	358	f	\N	5.25	2015-02-28
4240	4240	2015-02-16 20:51:44.402592	360	f	\N	5.25	2015-02-28
4241	4241	2015-02-16 20:51:44.402592	361	f	\N	5.25	2015-02-28
4242	4242	2015-02-16 20:51:44.402592	362	f	\N	5.25	2015-02-28
4243	4243	2015-02-16 20:51:44.402592	363	f	\N	5.25	2015-02-28
4244	4244	2015-02-16 20:51:44.402592	364	f	\N	5.25	2015-02-28
4245	4245	2015-02-16 20:51:44.402592	365	f	\N	5.25	2015-02-28
4246	4246	2015-02-16 20:51:44.402592	366	f	\N	5.25	2015-02-28
4247	4247	2015-02-16 20:51:44.402592	367	f	\N	5.25	2015-02-28
4248	4248	2015-02-16 20:51:44.402592	368	f	\N	5.25	2015-02-28
4249	4249	2015-02-16 20:51:44.402592	369	f	\N	5.25	2015-02-28
4250	4250	2015-02-16 20:51:44.402592	370	f	\N	5.25	2015-02-28
4251	4251	2015-02-16 20:51:44.402592	371	f	\N	5.25	2015-02-28
4252	4252	2015-02-16 20:51:44.402592	372	f	\N	5.25	2015-02-28
4253	4253	2015-02-16 20:51:44.402592	373	f	\N	5.25	2015-02-28
4254	4254	2015-02-16 20:51:44.402592	374	f	\N	5.25	2015-02-28
4255	4255	2015-02-16 20:51:44.402592	375	f	\N	5.25	2015-02-28
4256	4256	2015-02-16 20:51:44.402592	377	f	\N	5.25	2015-02-28
4257	4257	2015-02-16 20:51:44.402592	378	f	\N	5.25	2015-02-28
4258	4258	2015-02-16 20:51:44.402592	379	f	\N	5.25	2015-02-28
4259	4259	2015-02-16 20:51:44.402592	380	f	\N	5.25	2015-02-28
4260	4260	2015-02-16 20:51:44.402592	381	f	\N	5.25	2015-02-28
4261	4261	2015-02-16 20:51:44.402592	382	f	\N	5.25	2015-02-28
4262	4262	2015-02-16 20:51:44.402592	383	f	\N	5.25	2015-02-28
4263	4263	2015-02-16 20:51:44.402592	384	f	\N	5.25	2015-02-28
4264	4264	2015-02-16 20:51:44.402592	385	f	\N	5.25	2015-02-28
4265	4265	2015-02-16 20:51:44.402592	386	f	\N	5.25	2015-02-28
4266	4266	2015-02-16 20:51:44.402592	387	f	\N	5.25	2015-02-28
4267	4267	2015-02-16 20:51:44.402592	388	f	\N	5.25	2015-02-28
4268	4268	2015-02-16 20:51:44.402592	389	f	\N	5.25	2015-02-28
4269	4269	2015-02-16 20:51:44.402592	390	f	\N	5.25	2015-02-28
4270	4270	2015-02-16 20:51:44.402592	391	f	\N	5.25	2015-02-28
4271	4271	2015-02-16 20:51:44.402592	392	f	\N	5.25	2015-02-28
4272	4272	2015-02-16 20:51:44.402592	393	f	\N	5.25	2015-02-28
4273	4273	2015-02-16 20:51:44.402592	394	f	\N	5.25	2015-02-28
4274	4274	2015-02-16 20:51:44.402592	395	f	\N	5.25	2015-02-28
4275	4275	2015-02-16 20:51:44.402592	396	f	\N	5.25	2015-02-28
4276	4276	2015-02-16 20:51:44.402592	397	f	\N	5.25	2015-02-28
4277	4277	2015-02-16 20:51:44.402592	398	f	\N	5.25	2015-02-28
4278	4278	2015-02-16 20:51:44.402592	399	f	\N	5.25	2015-02-28
4279	4279	2015-02-16 20:51:44.402592	400	f	\N	5.25	2015-02-28
4280	4280	2015-02-16 20:51:44.402592	401	f	\N	5.25	2015-02-28
4281	4281	2015-02-16 20:51:44.402592	402	f	\N	5.25	2015-02-28
4282	4282	2015-02-16 20:51:44.402592	403	f	\N	5.25	2015-02-28
4283	4283	2015-02-16 20:51:44.402592	404	f	\N	5.25	2015-02-28
4284	4284	2015-02-16 20:51:44.402592	405	f	\N	5.25	2015-02-28
4285	4285	2015-02-16 20:51:44.402592	406	f	\N	5.25	2015-02-28
4286	4286	2015-02-16 20:51:44.402592	407	f	\N	5.25	2015-02-28
4287	4287	2015-02-16 20:51:44.402592	408	f	\N	5.25	2015-02-28
4288	4288	2015-02-16 20:51:44.402592	409	f	\N	5.25	2015-02-28
4289	4289	2015-02-16 20:51:44.402592	410	f	\N	5.25	2015-02-28
4290	4290	2015-02-16 20:51:44.402592	411	f	\N	5.25	2015-02-28
4291	4291	2015-02-16 20:51:44.402592	412	f	\N	5.25	2015-02-28
4292	4292	2015-02-16 20:51:44.402592	413	f	\N	5.25	2015-02-28
4293	4293	2015-02-16 20:51:44.402592	414	f	\N	5.25	2015-02-28
4294	4294	2015-02-16 20:51:44.402592	415	f	\N	5.25	2015-02-28
4295	4295	2015-02-16 20:51:44.402592	416	f	\N	5.25	2015-02-28
4296	4296	2015-02-16 20:51:44.402592	417	f	\N	5.25	2015-02-28
4297	4297	2015-02-16 20:51:44.402592	418	f	\N	5.25	2015-02-28
4298	4298	2015-02-16 20:51:44.402592	419	f	\N	5.25	2015-02-28
4299	4299	2015-02-16 20:51:44.402592	420	f	\N	5.25	2015-02-28
4300	4300	2015-02-16 20:51:44.402592	424	f	\N	5.25	2015-02-28
4301	4301	2015-02-16 20:51:44.402592	426	f	\N	5.25	2015-02-28
4302	4302	2015-02-16 20:51:44.402592	427	f	\N	5.25	2015-02-28
4303	4303	2015-02-16 20:51:44.402592	428	f	\N	5.25	2015-02-28
4304	4304	2015-02-16 20:51:44.402592	430	f	\N	5.25	2015-02-28
4305	4305	2015-02-16 20:51:44.402592	433	f	\N	5.25	2015-02-28
4306	4306	2015-02-16 20:51:44.402592	434	f	\N	5.25	2015-02-28
4307	4307	2015-02-16 20:51:44.402592	435	f	\N	5.25	2015-02-28
4308	4308	2015-02-16 20:51:44.402592	438	f	\N	5.25	2015-02-28
4309	4309	2015-02-16 20:51:44.402592	439	f	\N	5.25	2015-02-28
4310	4310	2015-02-16 20:51:44.402592	440	f	\N	5.25	2015-02-28
4311	4311	2015-02-16 20:51:44.402592	441	f	\N	5.25	2015-02-28
4312	4312	2015-02-16 20:51:44.402592	442	f	\N	5.25	2015-02-28
4313	4313	2015-02-16 20:51:44.402592	444	f	\N	5.25	2015-02-28
4314	4314	2015-02-16 20:51:44.402592	445	f	\N	5.25	2015-02-28
4315	4315	2015-02-16 20:51:44.402592	447	f	\N	5.25	2015-02-28
4316	4316	2015-02-16 20:51:44.402592	448	f	\N	5.25	2015-02-28
4317	4317	2015-02-16 20:51:44.402592	451	f	\N	5.25	2015-02-28
4318	4318	2015-02-16 20:51:44.402592	452	f	\N	5.25	2015-02-28
4319	4319	2015-02-16 20:51:44.402592	453	f	\N	5.25	2015-02-28
4320	4320	2015-02-16 20:51:44.402592	454	f	\N	5.25	2015-02-28
4321	4321	2015-02-16 20:51:44.402592	456	f	\N	5.25	2015-02-28
4322	4322	2015-02-16 20:51:44.402592	457	f	\N	5.25	2015-02-28
4323	4323	2015-02-16 20:51:44.402592	458	f	\N	5.25	2015-02-28
4324	4324	2015-02-16 20:51:44.402592	459	f	\N	5.25	2015-02-28
4325	4325	2015-02-16 20:51:44.402592	460	f	\N	5.25	2015-02-28
4326	4326	2015-02-16 20:51:44.402592	461	f	\N	5.25	2015-02-28
4327	4327	2015-02-16 20:51:44.402592	463	f	\N	5.25	2015-02-28
4328	4328	2015-02-16 20:51:44.402592	466	f	\N	5.25	2015-02-28
4329	4329	2015-02-16 20:51:44.402592	468	f	\N	5.25	2015-02-28
4330	4330	2015-02-16 20:51:44.402592	469	f	\N	5.25	2015-02-28
4331	4331	2015-02-16 20:51:44.402592	471	f	\N	5.25	2015-02-28
4332	4332	2015-02-16 20:51:44.402592	472	f	\N	5.25	2015-02-28
4333	4333	2015-02-16 20:51:44.402592	473	f	\N	5.25	2015-02-28
4334	4334	2015-02-16 20:51:44.402592	474	f	\N	5.25	2015-02-28
4335	4335	2015-02-16 20:51:44.402592	475	f	\N	5.25	2015-02-28
4336	4336	2015-02-16 20:51:44.402592	476	f	\N	5.25	2015-02-28
4337	4337	2015-02-16 20:51:44.402592	477	f	\N	5.25	2015-02-28
4338	4338	2015-02-16 20:51:44.402592	478	f	\N	5.25	2015-02-28
4339	4339	2015-02-16 20:51:44.402592	479	f	\N	5.25	2015-02-28
4340	4340	2015-02-16 20:51:44.402592	480	f	\N	5.25	2015-02-28
4341	4341	2015-02-16 20:51:44.402592	481	f	\N	5.25	2015-02-28
4342	4342	2015-02-16 20:51:44.402592	482	f	\N	5.25	2015-02-28
4343	4343	2015-02-16 20:51:44.402592	484	f	\N	5.25	2015-02-28
4344	4344	2015-02-16 20:51:44.402592	485	f	\N	5.25	2015-02-28
4345	4345	2015-02-16 20:51:44.402592	486	f	\N	5.25	2015-02-28
4346	4346	2015-02-16 20:51:44.402592	487	f	\N	5.25	2015-02-28
4347	4347	2015-02-16 20:51:44.402592	493	f	\N	5.25	2015-02-28
4348	4348	2015-02-16 20:51:44.402592	495	f	\N	5.25	2015-02-28
4349	4349	2015-02-16 20:51:44.402592	498	f	\N	5.25	2015-02-28
4350	4350	2015-02-16 20:51:44.402592	499	f	\N	5.25	2015-02-28
4351	4351	2015-02-16 20:51:44.402592	501	f	\N	5.25	2015-02-28
4352	4352	2015-02-16 20:51:44.402592	502	f	\N	5.25	2015-02-28
4353	4353	2015-02-16 20:51:44.402592	503	f	\N	5.25	2015-02-28
4354	4354	2015-02-16 20:51:44.402592	504	f	\N	5.25	2015-02-28
4355	4355	2015-02-16 20:51:44.402592	506	f	\N	5.25	2015-02-28
4356	4356	2015-02-16 20:51:44.402592	507	f	\N	5.25	2015-02-28
4357	4357	2015-02-16 20:51:44.402592	508	f	\N	5.25	2015-02-28
4358	4358	2015-02-16 20:51:44.402592	509	f	\N	5.25	2015-02-28
4359	4359	2015-02-16 20:51:44.402592	513	f	\N	5.25	2015-02-28
4360	4360	2015-02-16 20:51:44.402592	514	f	\N	5.25	2015-02-28
4361	4361	2015-02-16 20:51:44.402592	515	f	\N	5.25	2015-02-28
4362	4362	2015-02-16 20:51:44.402592	516	f	\N	5.25	2015-02-28
4363	4363	2015-02-16 20:51:44.402592	517	f	\N	5.25	2015-02-28
4364	4364	2015-02-16 20:51:44.402592	518	f	\N	5.25	2015-02-28
4365	4365	2015-02-16 20:51:44.402592	519	f	\N	5.25	2015-02-28
4366	4366	2015-02-16 20:51:44.402592	520	f	\N	5.25	2015-02-28
4367	4367	2015-02-16 20:51:44.402592	521	f	\N	5.25	2015-02-28
4368	4368	2015-02-16 20:51:44.402592	522	f	\N	5.25	2015-02-28
4369	4369	2015-02-16 20:51:44.402592	523	f	\N	5.25	2015-02-28
4370	4370	2015-02-16 20:51:44.402592	524	f	\N	5.25	2015-02-28
4371	4371	2015-02-16 20:51:44.402592	527	f	\N	5.25	2015-02-28
4372	4372	2015-02-16 20:51:44.402592	528	f	\N	5.25	2015-02-28
4373	4373	2015-02-16 20:51:44.402592	530	f	\N	5.25	2015-02-28
4374	4374	2015-02-16 20:51:44.402592	531	f	\N	5.25	2015-02-28
4375	4375	2015-02-16 20:51:44.402592	532	f	\N	5.25	2015-02-28
4376	4376	2015-02-16 20:51:44.402592	533	f	\N	5.25	2015-02-28
4377	4377	2015-02-16 20:51:44.402592	534	f	\N	5.25	2015-02-28
4378	4378	2015-02-16 20:51:44.402592	537	f	\N	5.25	2015-02-28
4379	4379	2015-02-16 20:51:44.402592	538	f	\N	5.25	2015-02-28
4380	4380	2015-02-16 20:51:44.402592	539	f	\N	5.25	2015-02-28
4381	4381	2015-02-16 20:51:44.402592	541	f	\N	5.25	2015-02-28
4382	4382	2015-02-16 20:51:44.402592	544	f	\N	5.25	2015-02-28
4383	4383	2015-02-16 20:51:44.402592	545	f	\N	5.25	2015-02-28
4384	4384	2015-02-16 20:51:44.402592	546	f	\N	5.25	2015-02-28
4385	4385	2015-02-16 20:51:44.402592	551	f	\N	5.25	2015-02-28
4386	4386	2015-02-16 20:51:44.402592	552	f	\N	5.25	2015-02-28
4387	4387	2015-02-16 20:51:44.402592	553	f	\N	5.25	2015-02-28
4388	4388	2015-02-16 20:51:44.402592	554	f	\N	5.25	2015-02-28
4389	4389	2015-02-16 20:51:44.402592	557	f	\N	5.25	2015-02-28
4390	4390	2015-02-16 20:51:44.402592	558	f	\N	5.25	2015-02-28
4391	4391	2015-02-16 20:51:44.402592	560	f	\N	5.25	2015-02-28
4392	4392	2015-02-16 20:51:44.402592	562	f	\N	5.25	2015-02-28
4393	4393	2015-02-16 20:51:44.402592	563	f	\N	5.25	2015-02-28
4394	4394	2015-02-16 20:51:44.402592	565	f	\N	5.25	2015-02-28
4395	4395	2015-02-16 20:51:44.402592	566	f	\N	5.25	2015-02-28
4396	4396	2015-02-16 20:51:44.402592	567	f	\N	5.25	2015-02-28
4397	4397	2015-02-16 20:51:44.402592	568	f	\N	5.25	2015-02-28
4398	4398	2015-02-16 20:51:44.402592	569	f	\N	5.25	2015-02-28
4399	4399	2015-02-16 20:51:44.402592	570	f	\N	5.25	2015-02-28
4400	4400	2015-02-16 20:51:44.402592	571	f	\N	5.25	2015-02-28
4401	4401	2015-02-16 20:51:44.402592	572	f	\N	5.25	2015-02-28
4402	4402	2015-02-16 20:51:44.402592	574	f	\N	5.25	2015-02-28
4403	4403	2015-02-16 20:51:44.402592	575	f	\N	5.25	2015-02-28
4404	4404	2015-02-16 20:51:44.402592	576	f	\N	5.25	2015-02-28
4405	4405	2015-02-16 20:51:44.402592	577	f	\N	5.25	2015-02-28
4406	4406	2015-02-16 20:51:44.402592	578	f	\N	5.25	2015-02-28
4407	4407	2015-02-16 20:51:44.402592	579	f	\N	5.25	2015-02-28
4408	4408	2015-02-16 20:51:44.402592	580	f	\N	5.25	2015-02-28
4409	4409	2015-02-16 20:51:44.402592	581	f	\N	5.25	2015-02-28
4410	4410	2015-02-16 20:51:44.402592	583	f	\N	5.25	2015-02-28
4411	4411	2015-02-16 20:51:44.402592	587	f	\N	5.25	2015-02-28
4412	4412	2015-02-16 20:51:44.402592	588	f	\N	5.25	2015-02-28
4413	4413	2015-02-16 20:51:44.402592	591	f	\N	5.25	2015-02-28
4414	4414	2015-02-16 20:51:44.402592	592	f	\N	5.25	2015-02-28
4415	4415	2015-02-16 20:51:44.402592	593	f	\N	5.25	2015-02-28
4416	4416	2015-02-16 20:51:44.402592	594	f	\N	5.25	2015-02-28
4417	4417	2015-02-16 20:51:44.402592	595	f	\N	5.25	2015-02-28
4418	4418	2015-02-16 20:51:44.402592	596	f	\N	5.25	2015-02-28
4419	4419	2015-02-16 20:51:44.402592	597	f	\N	5.25	2015-02-28
4420	4420	2015-02-16 20:51:44.402592	598	f	\N	5.25	2015-02-28
4421	4421	2015-02-16 20:51:44.402592	599	f	\N	5.25	2015-02-28
4422	4422	2015-02-16 20:51:44.402592	601	f	\N	5.25	2015-02-28
4423	4423	2015-02-16 20:51:44.402592	602	f	\N	5.25	2015-02-28
4424	4424	2015-02-16 20:51:44.402592	603	f	\N	5.25	2015-02-28
4425	4425	2015-02-16 20:51:44.402592	604	f	\N	5.25	2015-02-28
4426	4426	2015-02-16 20:51:44.402592	605	f	\N	5.25	2015-02-28
4427	4427	2015-02-16 20:51:44.402592	606	f	\N	5.25	2015-02-28
4428	4428	2015-02-16 20:51:44.402592	607	f	\N	5.25	2015-02-28
4429	4429	2015-02-16 20:51:44.402592	608	f	\N	5.25	2015-02-28
4430	4430	2015-02-16 20:51:44.402592	609	f	\N	5.25	2015-02-28
4431	4431	2015-02-16 20:51:44.402592	610	f	\N	5.25	2015-02-28
4432	4432	2015-02-16 20:51:44.402592	611	f	\N	5.25	2015-02-28
4433	4433	2015-02-16 20:51:44.402592	612	f	\N	5.25	2015-02-28
4434	4434	2015-02-16 20:51:44.402592	613	f	\N	5.25	2015-02-28
4435	4435	2015-02-16 20:51:44.402592	614	f	\N	5.25	2015-02-28
4436	4436	2015-02-16 20:51:44.402592	615	f	\N	5.25	2015-02-28
4437	4437	2015-02-16 20:51:44.402592	616	f	\N	5.25	2015-02-28
4438	4438	2015-02-16 20:51:44.402592	617	f	\N	5.25	2015-02-28
4439	4439	2015-02-16 20:51:44.402592	618	f	\N	5.25	2015-02-28
4440	4440	2015-02-16 20:51:44.402592	619	f	\N	5.25	2015-02-28
4441	4441	2015-02-16 20:51:44.402592	621	f	\N	5.25	2015-02-28
4442	4442	2015-02-16 20:51:44.402592	624	f	\N	5.25	2015-02-28
4443	4443	2015-02-16 20:51:44.402592	625	f	\N	5.25	2015-02-28
4444	4444	2015-02-16 20:51:44.402592	626	f	\N	5.25	2015-02-28
4445	4445	2015-02-16 20:51:44.402592	627	f	\N	5.25	2015-02-28
4446	4446	2015-02-16 20:51:44.402592	628	f	\N	5.25	2015-02-28
4447	4447	2015-02-16 20:51:44.402592	629	f	\N	5.25	2015-02-28
4448	4448	2015-02-16 20:51:44.402592	630	f	\N	5.25	2015-02-28
4449	4449	2015-02-16 20:51:44.402592	631	f	\N	5.25	2015-02-28
4450	4450	2015-02-16 20:51:44.402592	632	f	\N	5.25	2015-02-28
4451	4451	2015-02-16 20:51:44.402592	633	f	\N	5.25	2015-02-28
4452	4452	2015-02-16 20:51:44.402592	634	f	\N	5.25	2015-02-28
4453	4453	2015-02-16 20:51:44.402592	635	f	\N	5.25	2015-02-28
4454	4454	2015-02-16 20:51:44.402592	637	f	\N	5.25	2015-02-28
4455	4455	2015-02-16 20:51:44.402592	638	f	\N	5.25	2015-02-28
4456	4456	2015-02-16 20:51:44.402592	639	f	\N	5.25	2015-02-28
4457	4457	2015-02-16 20:51:44.402592	640	f	\N	5.25	2015-02-28
4458	4458	2015-02-16 20:51:44.402592	641	f	\N	5.25	2015-02-28
4459	4459	2015-02-16 20:51:44.402592	645	f	\N	5.25	2015-02-28
4460	4460	2015-02-16 20:51:44.402592	647	f	\N	5.25	2015-02-28
4461	4461	2015-02-16 20:51:44.402592	648	f	\N	5.25	2015-02-28
4462	4462	2015-02-16 20:51:44.402592	649	f	\N	5.25	2015-02-28
4463	4463	2015-02-16 20:51:44.402592	650	f	\N	5.25	2015-02-28
4464	4464	2015-02-16 20:51:44.402592	653	f	\N	5.25	2015-02-28
4465	4465	2015-02-16 20:51:44.402592	655	f	\N	5.25	2015-02-28
4466	4466	2015-02-16 20:51:44.402592	656	f	\N	5.25	2015-02-28
4467	4467	2015-02-16 20:51:44.402592	657	f	\N	5.25	2015-02-28
4468	4468	2015-02-16 20:51:44.402592	658	f	\N	5.25	2015-02-28
4469	4469	2015-02-16 20:51:44.402592	659	f	\N	5.25	2015-02-28
4470	4470	2015-02-16 20:51:44.402592	660	f	\N	5.25	2015-02-28
4471	4471	2015-02-16 20:51:44.402592	661	f	\N	5.25	2015-02-28
4472	4472	2015-02-16 20:51:44.402592	662	f	\N	5.25	2015-02-28
4473	4473	2015-02-16 20:51:44.402592	663	f	\N	5.25	2015-02-28
4474	4474	2015-02-16 20:51:44.402592	664	f	\N	5.25	2015-02-28
4475	4475	2015-02-16 20:51:44.402592	665	f	\N	5.25	2015-02-28
4476	4476	2015-02-16 20:51:44.402592	666	f	\N	5.25	2015-02-28
4477	4477	2015-02-16 20:51:44.402592	667	f	\N	5.25	2015-02-28
4478	4478	2015-02-16 20:51:44.402592	668	f	\N	5.25	2015-02-28
4479	4479	2015-02-16 20:51:44.402592	669	f	\N	5.25	2015-02-28
4480	4480	2015-02-16 20:51:44.402592	670	f	\N	5.25	2015-02-28
4481	4481	2015-02-16 20:51:44.402592	671	f	\N	5.25	2015-02-28
4482	4482	2015-02-16 20:51:44.402592	673	f	\N	5.25	2015-02-28
4483	4483	2015-02-16 20:51:44.402592	674	f	\N	5.25	2015-02-28
4484	4484	2015-02-16 20:51:44.402592	675	f	\N	5.25	2015-02-28
4485	4485	2015-02-16 20:51:44.402592	676	f	\N	5.25	2015-02-28
4486	4486	2015-02-16 20:51:44.402592	677	f	\N	5.25	2015-02-28
4487	4487	2015-02-16 20:51:44.402592	678	f	\N	5.25	2015-02-28
4488	4488	2015-02-16 20:51:44.402592	679	f	\N	5.25	2015-02-28
4489	4489	2015-02-16 20:51:44.402592	680	f	\N	5.25	2015-02-28
4490	4490	2015-02-16 20:51:44.402592	681	f	\N	5.25	2015-02-28
4491	4491	2015-02-16 20:51:44.402592	682	f	\N	5.25	2015-02-28
4492	4492	2015-02-16 20:51:44.402592	683	f	\N	5.25	2015-02-28
4493	4493	2015-02-16 20:51:44.402592	684	f	\N	5.25	2015-02-28
4494	4494	2015-02-16 20:51:44.402592	686	f	\N	5.25	2015-02-28
4495	4495	2015-02-16 20:51:44.402592	688	f	\N	5.25	2015-02-28
4496	4496	2015-02-16 20:51:44.402592	689	f	\N	5.25	2015-02-28
4497	4497	2015-02-16 20:51:44.402592	690	f	\N	5.25	2015-02-28
4498	4498	2015-02-16 20:51:44.402592	691	f	\N	5.25	2015-02-28
4499	4499	2015-02-16 20:51:44.402592	692	f	\N	5.25	2015-02-28
4500	4500	2015-02-16 20:51:44.402592	693	f	\N	5.25	2015-02-28
4501	4501	2015-02-16 20:51:44.402592	694	f	\N	5.25	2015-02-28
4502	4502	2015-02-16 20:51:44.402592	695	f	\N	5.25	2015-02-28
4503	4503	2015-02-16 20:51:44.402592	696	f	\N	5.25	2015-02-28
4504	4504	2015-02-16 20:51:44.402592	697	f	\N	5.25	2015-02-28
4505	4505	2015-02-16 20:51:44.402592	698	f	\N	5.25	2015-02-28
4506	4506	2015-02-16 20:51:44.402592	700	f	\N	5.25	2015-02-28
4507	4507	2015-02-16 20:51:44.402592	701	f	\N	5.25	2015-02-28
4508	4508	2015-02-16 20:51:44.402592	702	f	\N	5.25	2015-02-28
4509	4509	2015-02-16 20:51:44.402592	703	f	\N	5.25	2015-02-28
4510	4510	2015-02-16 20:51:44.402592	704	f	\N	5.25	2015-02-28
4511	4511	2015-02-16 20:51:44.402592	705	f	\N	5.25	2015-02-28
4512	4512	2015-02-16 20:51:44.402592	706	f	\N	5.25	2015-02-28
4513	4513	2015-02-16 20:51:44.402592	707	f	\N	5.25	2015-02-28
4514	4514	2015-02-16 20:51:44.402592	708	f	\N	5.25	2015-02-28
4515	4515	2015-02-16 20:51:44.402592	709	f	\N	5.25	2015-02-28
4516	4516	2015-02-16 20:51:44.402592	710	f	\N	5.25	2015-02-28
4517	4517	2015-02-16 20:51:44.402592	711	f	\N	5.25	2015-02-28
\.


--
-- TOC entry 2657 (class 0 OID 0)
-- Dependencies: 197
-- Name: scr_det_factura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_det_factura_id_seq', 5074, true);


--
-- TOC entry 2658 (class 0 OID 0)
-- Dependencies: 198
-- Name: scr_detalle_org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_detalle_org_id_seq', 9, true);


--
-- TOC entry 2540 (class 0 OID 17478)
-- Dependencies: 199 2590
-- Data for Name: scr_empleado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_empleado (id, "empleadoNombre", "empleadoApellido", "empleadoTelefono", "empleadoCelular", "empleadoDireccion", "empleadoDui", "empleadoIsss", "empleadoRegistro", "empleadoFechaIngreso", cargo_id, "empleadoEmail", "empleadoNit", localidad_id, usuario_id) FROM stdin;
1	Contabilidad	acrasame	99999999	99999999	direccion	99999999	99999999	2014-08-23 13:01:23.981479	2014-01-01	1	contabilidad@mail.com	99999999	8	3
\.


--
-- TOC entry 2541 (class 0 OID 17486)
-- Dependencies: 200 2590
-- Data for Name: scr_empleado_actividad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_empleado_actividad (empleado_id, actividad_id) FROM stdin;
\.


--
-- TOC entry 2659 (class 0 OID 0)
-- Dependencies: 201
-- Name: scr_empleado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_empleado_id_seq', 1, false);


--
-- TOC entry 2543 (class 0 OID 17491)
-- Dependencies: 202 2590
-- Data for Name: scr_estado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_estado (id, "nombreEstado") FROM stdin;
1	Activo
2	Inactivo
3	root
\.


--
-- TOC entry 2660 (class 0 OID 0)
-- Dependencies: 203
-- Name: scr_estado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_estado_id_seq', 1, false);


--
-- TOC entry 2661 (class 0 OID 0)
-- Dependencies: 195
-- Name: scr_factura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_factura_id_seq', 5074, true);


--
-- TOC entry 2545 (class 0 OID 17496)
-- Dependencies: 204 2590
-- Data for Name: scr_his_rep_legal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_his_rep_legal (id, his_rep_leg_nombre, his_rep_leg_apellido, his_rep_leg_telefono, his_rep_leg_celular, his_rep_leg_email, his_rep_leg_direccion, his_rep_leg_fecha_registro, representante_legal_id) FROM stdin;
\.


--
-- TOC entry 2662 (class 0 OID 0)
-- Dependencies: 205
-- Name: scr_historial_representante_legal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_historial_representante_legal_id_seq', 1, false);


--
-- TOC entry 2547 (class 0 OID 17504)
-- Dependencies: 206 2590
-- Data for Name: scr_lectura; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_lectura (id, "valorLectura", "fechaLectura", "registroLectura", socio_id, tecnico_id) FROM stdin;
2758	735	2014-10-02	2015-02-15 00:00:00	25	1
2759	746	2014-11-02	2015-02-15 00:00:00	25	1
2760	756	2014-12-02	2015-02-15 00:00:00	25	1
2761	768	2015-01-02	2015-02-15 00:00:00	25	1
2762	1023	2014-10-02	2015-02-15 00:00:00	26	1
2763	1030	2014-11-02	2015-02-15 00:00:00	26	1
2764	1037	2014-12-02	2015-02-15 00:00:00	26	1
2765	1048	2015-01-02	2015-02-15 00:00:00	26	1
2766	943	2014-10-02	2015-02-15 00:00:00	27	1
2767	951	2014-11-02	2015-02-15 00:00:00	27	1
2768	962	2014-12-02	2015-02-15 00:00:00	27	1
2769	972	2015-01-02	2015-02-15 00:00:00	27	1
2770	0	2014-10-02	2015-02-15 00:00:00	28	1
2771	0	2014-11-02	2015-02-15 00:00:00	28	1
2772	0	2014-12-02	2015-02-15 00:00:00	28	1
2773	0	2015-01-02	2015-02-15 00:00:00	28	1
2774	0	2014-10-02	2015-02-15 00:00:00	29	1
2775	0	2014-11-02	2015-02-15 00:00:00	29	1
2776	0	2014-12-02	2015-02-15 00:00:00	29	1
2777	0	2015-01-02	2015-02-15 00:00:00	29	1
2778	876	2014-10-02	2015-02-15 00:00:00	30	1
2779	884	2014-11-02	2015-02-15 00:00:00	30	1
2780	894	2014-12-02	2015-02-15 00:00:00	30	1
2781	908	2015-01-02	2015-02-15 00:00:00	30	1
2782	0	2014-10-02	2015-02-15 00:00:00	31	1
2783	0	2014-11-02	2015-02-15 00:00:00	31	1
2784	0	2014-12-02	2015-02-15 00:00:00	31	1
2785	0	2015-01-02	2015-02-15 00:00:00	31	1
2786	998	2014-10-02	2015-02-15 00:00:00	32	1
2787	1004	2014-11-02	2015-02-15 00:00:00	32	1
2788	1013	2014-12-02	2015-02-15 00:00:00	32	1
2789	1026	2015-01-02	2015-02-15 00:00:00	32	1
2790	901	2014-10-02	2015-02-15 00:00:00	33	1
2791	920	2014-11-02	2015-02-15 00:00:00	33	1
2792	943	2014-12-02	2015-02-15 00:00:00	33	1
2793	956	2015-01-02	2015-02-15 00:00:00	33	1
2794	0	2014-10-02	2015-02-15 00:00:00	34	1
2795	0	2014-11-02	2015-02-15 00:00:00	34	1
2796	0	2014-12-02	2015-02-15 00:00:00	34	1
2797	0	2015-01-02	2015-02-15 00:00:00	34	1
2798	0	2014-10-02	2015-02-15 00:00:00	35	1
2799	0	2014-11-02	2015-02-15 00:00:00	35	1
2800	0	2014-12-02	2015-02-15 00:00:00	35	1
2801	0	2015-01-02	2015-02-15 00:00:00	35	1
2802	0	2014-10-02	2015-02-15 00:00:00	36	1
2803	0	2014-11-02	2015-02-15 00:00:00	36	1
2804	0	2014-12-02	2015-02-15 00:00:00	36	1
2805	0	2015-01-02	2015-02-15 00:00:00	36	1
2806	0	2014-10-02	2015-02-15 00:00:00	37	1
2807	0	2014-11-02	2015-02-15 00:00:00	37	1
2808	0	2014-12-02	2015-02-15 00:00:00	37	1
2809	0	2015-01-02	2015-02-15 00:00:00	37	1
2810	1201	2014-10-02	2015-02-15 00:00:00	38	1
2811	1207	2014-11-02	2015-02-15 00:00:00	38	1
2812	1214	2014-12-02	2015-02-15 00:00:00	38	1
2813	1221	2015-01-02	2015-02-15 00:00:00	38	1
2814	615	2014-10-02	2015-02-15 00:00:00	39	1
2815	618	2014-11-02	2015-02-15 00:00:00	39	1
2816	632	2014-12-02	2015-02-15 00:00:00	39	1
2817	649	2015-01-02	2015-02-15 00:00:00	39	1
2818	691	2014-10-02	2015-02-15 00:00:00	40	1
2819	698	2014-11-02	2015-02-15 00:00:00	40	1
2820	705	2014-12-02	2015-02-15 00:00:00	40	1
2821	715	2015-01-02	2015-02-15 00:00:00	40	1
2822	1104	2014-10-02	2015-02-15 00:00:00	41	1
2823	1115	2014-11-02	2015-02-15 00:00:00	41	1
2824	1127	2014-12-02	2015-02-15 00:00:00	41	1
2825	1140	2015-01-02	2015-02-15 00:00:00	41	1
2826	0	2014-10-02	2015-02-15 00:00:00	42	1
2827	0	2014-11-02	2015-02-15 00:00:00	42	1
2828	0	2014-12-02	2015-02-15 00:00:00	42	1
2829	0	2015-01-02	2015-02-15 00:00:00	42	1
2830	2544	2014-10-02	2015-02-15 00:00:00	43	1
2831	2566	2014-11-02	2015-02-15 00:00:00	43	1
2832	2573	2014-12-02	2015-02-15 00:00:00	43	1
2833	2584	2015-01-02	2015-02-15 00:00:00	43	1
2834	161	2014-10-02	2015-02-15 00:00:00	44	1
2835	174	2014-11-02	2015-02-15 00:00:00	44	1
2836	184	2014-12-02	2015-02-15 00:00:00	44	1
2837	196	2015-01-02	2015-02-15 00:00:00	44	1
2838	71	2014-10-02	2015-02-15 00:00:00	45	1
2839	80	2014-11-02	2015-02-15 00:00:00	45	1
2840	93	2014-12-02	2015-02-15 00:00:00	45	1
2841	108	2015-01-02	2015-02-15 00:00:00	45	1
2842	1563	2014-10-02	2015-02-15 00:00:00	46	1
2843	1574	2014-11-02	2015-02-15 00:00:00	46	1
2844	1590	2014-12-02	2015-02-15 00:00:00	46	1
2845	1614	2015-01-02	2015-02-15 00:00:00	46	1
2846	519	2014-10-02	2015-02-15 00:00:00	47	1
2847	532	2014-11-02	2015-02-15 00:00:00	47	1
2848	545	2014-12-02	2015-02-15 00:00:00	47	1
2849	561	2015-01-02	2015-02-15 00:00:00	47	1
2850	323	2014-10-02	2015-02-15 00:00:00	48	1
2851	327	2014-11-02	2015-02-15 00:00:00	48	1
2852	336	2014-12-02	2015-02-15 00:00:00	48	1
2853	355	2015-01-02	2015-02-15 00:00:00	48	1
2854	233	2014-10-02	2015-02-15 00:00:00	49	1
2855	233	2014-11-02	2015-02-15 00:00:00	49	1
2856	233	2014-12-02	2015-02-15 00:00:00	49	1
2857	235	2015-01-02	2015-02-15 00:00:00	49	1
2858	1041	2014-10-02	2015-02-15 00:00:00	50	1
2859	1055	2014-11-02	2015-02-15 00:00:00	50	1
2860	1076	2014-12-02	2015-02-15 00:00:00	50	1
2861	1097	2015-01-02	2015-02-15 00:00:00	50	1
2862	368	2014-10-02	2015-02-15 00:00:00	51	1
2863	371	2014-11-02	2015-02-15 00:00:00	51	1
2864	379	2014-12-02	2015-02-15 00:00:00	51	1
2865	391	2015-01-02	2015-02-15 00:00:00	51	1
2866	1885	2014-10-02	2015-02-15 00:00:00	52	1
2867	1899	2014-11-02	2015-02-15 00:00:00	52	1
2868	1911	2014-12-02	2015-02-15 00:00:00	52	1
2869	1923	2015-01-02	2015-02-15 00:00:00	52	1
2870	304	2014-10-02	2015-02-15 00:00:00	53	1
2871	310	2014-11-02	2015-02-15 00:00:00	53	1
2872	317	2014-12-02	2015-02-15 00:00:00	53	1
2873	327	2015-01-02	2015-02-15 00:00:00	53	1
2874	0	2014-10-02	2015-02-15 00:00:00	54	1
2875	1	2014-11-02	2015-02-15 00:00:00	54	1
2876	5	2014-12-02	2015-02-15 00:00:00	54	1
2877	9	2015-01-02	2015-02-15 00:00:00	54	1
2878	1265	2014-10-02	2015-02-15 00:00:00	55	1
2879	1278	2014-11-02	2015-02-15 00:00:00	55	1
2880	1294	2014-12-02	2015-02-15 00:00:00	55	1
2881	1311	2015-01-02	2015-02-15 00:00:00	55	1
2882	946	2014-10-02	2015-02-15 00:00:00	56	1
2883	954	2014-11-02	2015-02-15 00:00:00	56	1
2884	962	2014-12-02	2015-02-15 00:00:00	56	1
2885	975	2015-01-02	2015-02-15 00:00:00	56	1
2886	365	2014-10-02	2015-02-15 00:00:00	57	1
2887	375	2014-11-02	2015-02-15 00:00:00	57	1
2888	383	2014-12-02	2015-02-15 00:00:00	57	1
2889	392	2015-01-02	2015-02-15 00:00:00	57	1
2890	695	2014-10-02	2015-02-15 00:00:00	58	1
2891	708	2014-11-02	2015-02-15 00:00:00	58	1
2892	724	2014-12-02	2015-02-15 00:00:00	58	1
2893	744	2015-01-02	2015-02-15 00:00:00	58	1
2894	293	2014-10-02	2015-02-15 00:00:00	59	1
2895	302	2014-11-02	2015-02-15 00:00:00	59	1
2896	312	2014-12-02	2015-02-15 00:00:00	59	1
2897	324	2015-01-02	2015-02-15 00:00:00	59	1
2898	342	2014-10-02	2015-02-15 00:00:00	60	1
2899	350	2014-11-02	2015-02-15 00:00:00	60	1
2900	359	2014-12-02	2015-02-15 00:00:00	60	1
2901	370	2015-01-02	2015-02-15 00:00:00	60	1
2902	323	2014-10-02	2015-02-15 00:00:00	61	1
2903	326	2014-11-02	2015-02-15 00:00:00	61	1
2904	327	2014-12-02	2015-02-15 00:00:00	61	1
2905	332	2015-01-02	2015-02-15 00:00:00	61	1
2906	479	2014-10-02	2015-02-15 00:00:00	62	1
2907	481	2014-11-02	2015-02-15 00:00:00	62	1
2908	485	2014-12-02	2015-02-15 00:00:00	62	1
2909	493	2015-01-02	2015-02-15 00:00:00	62	1
2910	1131	2014-10-02	2015-02-15 00:00:00	63	1
2911	1139	2014-11-02	2015-02-15 00:00:00	63	1
2912	1149	2014-12-02	2015-02-15 00:00:00	63	1
2913	1164	2015-01-02	2015-02-15 00:00:00	63	1
2914	1239	2014-10-02	2015-02-15 00:00:00	64	1
2915	1244	2014-11-02	2015-02-15 00:00:00	64	1
2916	1251	2014-12-02	2015-02-15 00:00:00	64	1
2917	1262	2015-01-02	2015-02-15 00:00:00	64	1
2918	1073	2014-10-02	2015-02-15 00:00:00	65	1
2919	1081	2014-11-02	2015-02-15 00:00:00	65	1
2920	0	2014-12-02	2015-02-15 00:00:00	65	1
2921	0	2015-01-02	2015-02-15 00:00:00	65	1
2922	0	2014-10-02	2015-02-15 00:00:00	66	1
2923	0	2014-11-02	2015-02-15 00:00:00	66	1
2924	0	2014-12-02	2015-02-15 00:00:00	66	1
2925	0	2015-01-02	2015-02-15 00:00:00	66	1
2926	357	2014-10-02	2015-02-15 00:00:00	67	1
2927	359	2014-11-02	2015-02-15 00:00:00	67	1
2928	366	2014-12-02	2015-02-15 00:00:00	67	1
2929	372	2015-01-02	2015-02-15 00:00:00	67	1
2930	102	2014-10-02	2015-02-15 00:00:00	68	1
2931	154	2014-11-02	2015-02-15 00:00:00	68	1
2932	210	2014-12-02	2015-02-15 00:00:00	68	1
2933	250	2015-01-02	2015-02-15 00:00:00	68	1
2934	0	2014-10-02	2015-02-15 00:00:00	69	1
2935	0	2014-11-02	2015-02-15 00:00:00	69	1
2936	0	2014-12-02	2015-02-15 00:00:00	69	1
2937	0	2015-01-02	2015-02-15 00:00:00	69	1
2938	288	2014-10-02	2015-02-15 00:00:00	70	1
2939	294	2014-11-02	2015-02-15 00:00:00	70	1
2940	295	2014-12-02	2015-02-15 00:00:00	70	1
2941	298	2015-01-02	2015-02-15 00:00:00	70	1
2942	417	2014-10-02	2015-02-15 00:00:00	71	1
2943	423	2014-11-02	2015-02-15 00:00:00	71	1
2944	429	2014-12-02	2015-02-15 00:00:00	71	1
2945	440	2015-01-02	2015-02-15 00:00:00	71	1
2946	62	2014-10-02	2015-02-15 00:00:00	72	1
2947	71	2014-11-02	2015-02-15 00:00:00	72	1
2948	81	2014-12-02	2015-02-15 00:00:00	72	1
2949	90	2015-01-02	2015-02-15 00:00:00	72	1
2950	1084	2014-10-02	2015-02-15 00:00:00	73	1
2951	1096	2014-11-02	2015-02-15 00:00:00	73	1
2952	1110	2014-12-02	2015-02-15 00:00:00	73	1
2953	1125	2015-01-02	2015-02-15 00:00:00	73	1
2954	658	2014-10-02	2015-02-15 00:00:00	74	1
2955	667	2014-11-02	2015-02-15 00:00:00	74	1
2956	676	2014-12-02	2015-02-15 00:00:00	74	1
2957	689	2015-01-02	2015-02-15 00:00:00	74	1
2958	858	2014-10-02	2015-02-15 00:00:00	75	1
2959	864	2014-11-02	2015-02-15 00:00:00	75	1
2960	868	2014-12-02	2015-02-15 00:00:00	75	1
2961	883	2015-01-02	2015-02-15 00:00:00	75	1
2962	617	2014-10-02	2015-02-15 00:00:00	76	1
2963	622	2014-11-02	2015-02-15 00:00:00	76	1
2964	628	2014-12-02	2015-02-15 00:00:00	76	1
2965	633	2015-01-02	2015-02-15 00:00:00	76	1
2966	105	2014-10-02	2015-02-15 00:00:00	77	1
2967	128	2014-11-02	2015-02-15 00:00:00	77	1
2968	148	2014-12-02	2015-02-15 00:00:00	77	1
2969	171	2015-01-02	2015-02-15 00:00:00	77	1
2970	447	2014-10-02	2015-02-15 00:00:00	78	1
2971	447	2014-11-02	2015-02-15 00:00:00	78	1
2972	447	2014-12-02	2015-02-15 00:00:00	78	1
2973	447	2015-01-02	2015-02-15 00:00:00	78	1
2974	867	2014-10-02	2015-02-15 00:00:00	79	1
2975	878	2014-11-02	2015-02-15 00:00:00	79	1
2976	889	2014-12-02	2015-02-15 00:00:00	79	1
2977	904	2015-01-02	2015-02-15 00:00:00	79	1
2978	275	2014-10-02	2015-02-15 00:00:00	80	1
2979	276	2014-11-02	2015-02-15 00:00:00	80	1
2980	277	2014-12-02	2015-02-15 00:00:00	80	1
2981	278	2015-01-02	2015-02-15 00:00:00	80	1
2982	0	2014-10-02	2015-02-15 00:00:00	81	1
2983	0	2014-11-02	2015-02-15 00:00:00	81	1
2984	0	2014-12-02	2015-02-15 00:00:00	81	1
2985	0	2015-01-02	2015-02-15 00:00:00	81	1
2986	1710	2014-10-02	2015-02-15 00:00:00	82	1
2987	1729	2014-11-02	2015-02-15 00:00:00	82	1
2988	1757	2014-12-02	2015-02-15 00:00:00	82	1
2989	1794	2015-01-02	2015-02-15 00:00:00	82	1
2990	0	2014-10-02	2015-02-15 00:00:00	83	1
2991	0	2014-11-02	2015-02-15 00:00:00	83	1
2992	0	2014-12-02	2015-02-15 00:00:00	83	1
2993	0	2015-01-02	2015-02-15 00:00:00	83	1
2994	0	2014-10-02	2015-02-15 00:00:00	84	1
2995	0	2014-11-02	2015-02-15 00:00:00	84	1
2996	0	2014-12-02	2015-02-15 00:00:00	84	1
2997	0	2015-01-02	2015-02-15 00:00:00	84	1
2998	434	2014-10-02	2015-02-15 00:00:00	85	1
2999	439	2014-11-02	2015-02-15 00:00:00	85	1
3000	452	2014-12-02	2015-02-15 00:00:00	85	1
3001	465	2015-01-02	2015-02-15 00:00:00	85	1
3002	1077	2014-10-02	2015-02-15 00:00:00	86	1
3003	1078	2014-11-02	2015-02-15 00:00:00	86	1
3004	1101	2014-12-02	2015-02-15 00:00:00	86	1
3005	1127	2015-01-02	2015-02-15 00:00:00	86	1
3006	288	2014-10-02	2015-02-15 00:00:00	87	1
3007	289	2014-11-02	2015-02-15 00:00:00	87	1
3008	293	2014-12-02	2015-02-15 00:00:00	87	1
3009	300	2015-01-02	2015-02-15 00:00:00	87	1
3010	1000	2014-10-02	2015-02-15 00:00:00	88	1
3011	1009	2014-11-02	2015-02-15 00:00:00	88	1
3012	1017	2014-12-02	2015-02-15 00:00:00	88	1
3013	1032	2015-01-02	2015-02-15 00:00:00	88	1
3014	0	2014-10-02	2015-02-15 00:00:00	89	1
3015	0	2014-11-02	2015-02-15 00:00:00	89	1
3016	0	2014-12-02	2015-02-15 00:00:00	89	1
3017	0	2015-01-02	2015-02-15 00:00:00	89	1
3018	0	2014-10-02	2015-02-15 00:00:00	90	1
3019	0	2014-11-02	2015-02-15 00:00:00	90	1
3020	0	2014-12-02	2015-02-15 00:00:00	90	1
3021	0	2015-01-02	2015-02-15 00:00:00	90	1
3022	390	2014-10-02	2015-02-15 00:00:00	91	1
3023	391	2014-11-02	2015-02-15 00:00:00	91	1
3024	394	2014-12-02	2015-02-15 00:00:00	91	1
3025	397	2015-01-02	2015-02-15 00:00:00	91	1
3026	1138	2014-10-02	2015-02-15 00:00:00	92	1
3027	1144	2014-11-02	2015-02-15 00:00:00	92	1
3028	1151	2014-12-02	2015-02-15 00:00:00	92	1
3029	1162	2015-01-02	2015-02-15 00:00:00	92	1
3030	958	2014-10-02	2015-02-15 00:00:00	93	1
3031	965	2014-11-02	2015-02-15 00:00:00	93	1
3032	976	2014-12-02	2015-02-15 00:00:00	93	1
3033	993	2015-01-02	2015-02-15 00:00:00	93	1
3034	819	2014-10-02	2015-02-15 00:00:00	94	1
3035	823	2014-11-02	2015-02-15 00:00:00	94	1
3036	830	2014-12-02	2015-02-15 00:00:00	94	1
3037	839	2015-01-02	2015-02-15 00:00:00	94	1
3038	878	2014-10-02	2015-02-15 00:00:00	95	1
3039	878	2014-11-02	2015-02-15 00:00:00	95	1
3040	878	2014-12-02	2015-02-15 00:00:00	95	1
3041	878	2015-01-02	2015-02-15 00:00:00	95	1
3042	605	2014-10-02	2015-02-15 00:00:00	96	1
3043	612	2014-11-02	2015-02-15 00:00:00	96	1
3044	627	2014-12-02	2015-02-15 00:00:00	96	1
3045	643	2015-01-02	2015-02-15 00:00:00	96	1
3046	511	2014-10-02	2015-02-15 00:00:00	97	1
3047	512	2014-11-02	2015-02-15 00:00:00	97	1
3048	514	2014-12-02	2015-02-15 00:00:00	97	1
3049	516	2015-01-02	2015-02-15 00:00:00	97	1
3050	1365	2014-10-02	2015-02-15 00:00:00	98	1
3051	1375	2014-11-02	2015-02-15 00:00:00	98	1
3052	1387	2014-12-02	2015-02-15 00:00:00	98	1
3053	1407	2015-01-02	2015-02-15 00:00:00	98	1
3054	403	2014-10-02	2015-02-15 00:00:00	99	1
3055	415	2014-11-02	2015-02-15 00:00:00	99	1
3056	429	2014-12-02	2015-02-15 00:00:00	99	1
3057	442	2015-01-02	2015-02-15 00:00:00	99	1
3058	1508	2014-10-02	2015-02-15 00:00:00	100	1
3059	1520	2014-11-02	2015-02-15 00:00:00	100	1
3060	1535	2014-12-02	2015-02-15 00:00:00	100	1
3061	1555	2015-01-02	2015-02-15 00:00:00	100	1
3062	411	2014-10-02	2015-02-15 00:00:00	101	1
3063	417	2014-11-02	2015-02-15 00:00:00	101	1
3064	423	2014-12-02	2015-02-15 00:00:00	101	1
3065	431	2015-01-02	2015-02-15 00:00:00	101	1
3066	972	2014-10-02	2015-02-15 00:00:00	102	1
3067	977	2014-11-02	2015-02-15 00:00:00	102	1
3068	986	2014-12-02	2015-02-15 00:00:00	102	1
3069	996	2015-01-02	2015-02-15 00:00:00	102	1
3070	525	2014-10-02	2015-02-15 00:00:00	103	1
3071	537	2014-11-02	2015-02-15 00:00:00	103	1
3072	548	2014-12-02	2015-02-15 00:00:00	103	1
3073	563	2015-01-02	2015-02-15 00:00:00	103	1
3074	138	2014-10-02	2015-02-15 00:00:00	104	1
3075	152	2014-11-02	2015-02-15 00:00:00	104	1
3076	161	2014-12-02	2015-02-15 00:00:00	104	1
3077	170	2015-01-02	2015-02-15 00:00:00	104	1
3078	671	2014-10-02	2015-02-15 00:00:00	105	1
3079	677	2014-11-02	2015-02-15 00:00:00	105	1
3080	688	2014-12-02	2015-02-15 00:00:00	105	1
3081	700	2015-01-02	2015-02-15 00:00:00	105	1
3082	53	2014-10-02	2015-02-15 00:00:00	106	1
3083	65	2014-11-02	2015-02-15 00:00:00	106	1
3084	79	2014-12-02	2015-02-15 00:00:00	106	1
3085	90	2015-01-02	2015-02-15 00:00:00	106	1
3086	73	2014-10-02	2015-02-15 00:00:00	107	1
3087	73	2014-11-02	2015-02-15 00:00:00	107	1
3088	73	2014-12-02	2015-02-15 00:00:00	107	1
3089	75	2015-01-02	2015-02-15 00:00:00	107	1
3090	612	2014-10-02	2015-02-15 00:00:00	108	1
3091	616	2014-11-02	2015-02-15 00:00:00	108	1
3092	627	2014-12-02	2015-02-15 00:00:00	108	1
3093	638	2015-01-02	2015-02-15 00:00:00	108	1
3094	0	2014-10-02	2015-02-15 00:00:00	109	1
3095	0	2014-11-02	2015-02-15 00:00:00	109	1
3096	0	2014-12-02	2015-02-15 00:00:00	109	1
3097	0	2015-01-02	2015-02-15 00:00:00	109	1
3098	1291	2014-10-02	2015-02-15 00:00:00	110	1
3099	1297	2014-11-02	2015-02-15 00:00:00	110	1
3100	1308	2014-12-02	2015-02-15 00:00:00	110	1
3101	1317	2015-01-02	2015-02-15 00:00:00	110	1
3102	1281	2014-10-02	2015-02-15 00:00:00	111	1
3103	1293	2014-11-02	2015-02-15 00:00:00	111	1
3104	1305	2014-12-02	2015-02-15 00:00:00	111	1
3105	1317	2015-01-02	2015-02-15 00:00:00	111	1
3106	646	2014-10-02	2015-02-15 00:00:00	112	1
3107	651	2014-11-02	2015-02-15 00:00:00	112	1
3108	656	2014-12-02	2015-02-15 00:00:00	112	1
3109	668	2015-01-02	2015-02-15 00:00:00	112	1
3110	0	2014-10-02	2015-02-15 00:00:00	113	1
3111	0	2014-11-02	2015-02-15 00:00:00	113	1
3112	0	2014-12-02	2015-02-15 00:00:00	113	1
3113	0	2015-01-02	2015-02-15 00:00:00	113	1
3114	2016	2014-10-02	2015-02-15 00:00:00	114	1
3115	2027	2014-11-02	2015-02-15 00:00:00	114	1
3116	2040	2014-12-02	2015-02-15 00:00:00	114	1
3117	2054	2015-01-02	2015-02-15 00:00:00	114	1
3118	18	2014-10-02	2015-02-15 00:00:00	115	1
3119	21	2014-11-02	2015-02-15 00:00:00	115	1
3120	27	2014-12-02	2015-02-15 00:00:00	115	1
3121	32	2015-01-02	2015-02-15 00:00:00	115	1
3122	923	2014-10-02	2015-02-15 00:00:00	116	1
3123	926	2014-11-02	2015-02-15 00:00:00	116	1
3124	929	2014-12-02	2015-02-15 00:00:00	116	1
3125	933	2015-01-02	2015-02-15 00:00:00	116	1
3126	536	2014-10-02	2015-02-15 00:00:00	117	1
3127	546	2014-11-02	2015-02-15 00:00:00	117	1
3128	561	2014-12-02	2015-02-15 00:00:00	117	1
3129	580	2015-01-02	2015-02-15 00:00:00	117	1
3130	900	2014-10-02	2015-02-15 00:00:00	118	1
3131	908	2014-11-02	2015-02-15 00:00:00	118	1
3132	916	2014-12-02	2015-02-15 00:00:00	118	1
3133	923	2015-01-02	2015-02-15 00:00:00	118	1
3134	107	2014-10-02	2015-02-15 00:00:00	119	1
3135	125	2014-11-02	2015-02-15 00:00:00	119	1
3136	146	2014-12-02	2015-02-15 00:00:00	119	1
3137	171	2015-01-02	2015-02-15 00:00:00	119	1
3138	832	2014-10-02	2015-02-15 00:00:00	120	1
3139	839	2014-11-02	2015-02-15 00:00:00	120	1
3140	848	2014-12-02	2015-02-15 00:00:00	120	1
3141	857	2015-01-02	2015-02-15 00:00:00	120	1
3142	1250	2014-10-02	2015-02-15 00:00:00	121	1
3143	1264	2014-11-02	2015-02-15 00:00:00	121	1
3144	1276	2014-12-02	2015-02-15 00:00:00	121	1
3145	1286	2015-01-02	2015-02-15 00:00:00	121	1
3146	100	2014-10-02	2015-02-15 00:00:00	122	1
3147	104	2014-11-02	2015-02-15 00:00:00	122	1
3148	108	2014-12-02	2015-02-15 00:00:00	122	1
3149	112	2015-01-02	2015-02-15 00:00:00	122	1
3150	868	2014-10-02	2015-02-15 00:00:00	123	1
3151	874	2014-11-02	2015-02-15 00:00:00	123	1
3152	881	2014-12-02	2015-02-15 00:00:00	123	1
3153	893	2015-01-02	2015-02-15 00:00:00	123	1
3154	1572	2014-10-02	2015-02-15 00:00:00	124	1
3155	1593	2014-11-02	2015-02-15 00:00:00	124	1
3156	1622	2014-12-02	2015-02-15 00:00:00	124	1
3157	1655	2015-01-02	2015-02-15 00:00:00	124	1
3158	632	2014-10-02	2015-02-15 00:00:00	125	1
3159	646	2014-11-02	2015-02-15 00:00:00	125	1
3160	656	2014-12-02	2015-02-15 00:00:00	125	1
3161	662	2015-01-02	2015-02-15 00:00:00	125	1
3162	0	2014-10-02	2015-02-15 00:00:00	126	1
3163	0	2014-11-02	2015-02-15 00:00:00	126	1
3164	0	2014-12-02	2015-02-15 00:00:00	126	1
3165	0	2015-01-02	2015-02-15 00:00:00	126	1
3166	0	2014-10-02	2015-02-15 00:00:00	127	1
3167	0	2014-11-02	2015-02-15 00:00:00	127	1
3168	0	2014-12-02	2015-02-15 00:00:00	127	1
3169	0	2015-01-02	2015-02-15 00:00:00	127	1
3170	418	2014-10-02	2015-02-15 00:00:00	128	1
3171	418	2014-11-02	2015-02-15 00:00:00	128	1
3172	422	2014-12-02	2015-02-15 00:00:00	128	1
3173	429	2015-01-02	2015-02-15 00:00:00	128	1
3174	0	2014-10-02	2015-02-15 00:00:00	129	1
3175	0	2014-11-02	2015-02-15 00:00:00	129	1
3176	0	2014-12-02	2015-02-15 00:00:00	129	1
3177	0	2015-01-02	2015-02-15 00:00:00	129	1
3178	340	2014-10-02	2015-02-15 00:00:00	130	1
3179	341	2014-11-02	2015-02-15 00:00:00	130	1
3180	342	2014-12-02	2015-02-15 00:00:00	130	1
3181	343	2015-01-02	2015-02-15 00:00:00	130	1
3182	214	2014-10-02	2015-02-15 00:00:00	131	1
3183	214	2014-11-02	2015-02-15 00:00:00	131	1
3184	214	2014-12-02	2015-02-15 00:00:00	131	1
3185	214	2015-01-02	2015-02-15 00:00:00	131	1
3186	101	2014-10-02	2015-02-15 00:00:00	132	1
3187	106	2014-11-02	2015-02-15 00:00:00	132	1
3188	110	2014-12-02	2015-02-15 00:00:00	132	1
3189	116	2015-01-02	2015-02-15 00:00:00	132	1
3190	0	2014-10-02	2015-02-15 00:00:00	133	1
3191	0	2014-11-02	2015-02-15 00:00:00	133	1
3192	0	2014-12-02	2015-02-15 00:00:00	133	1
3193	0	2015-01-02	2015-02-15 00:00:00	133	1
3194	0	2014-10-02	2015-02-15 00:00:00	134	1
3195	0	2014-11-02	2015-02-15 00:00:00	134	1
3196	0	2014-12-02	2015-02-15 00:00:00	134	1
3197	0	2015-01-02	2015-02-15 00:00:00	134	1
3198	0	2014-10-02	2015-02-15 00:00:00	135	1
3199	0	2014-11-02	2015-02-15 00:00:00	135	1
3200	0	2014-12-02	2015-02-15 00:00:00	135	1
3201	0	2015-01-02	2015-02-15 00:00:00	135	1
3202	0	2014-10-02	2015-02-15 00:00:00	136	1
3203	0	2014-11-02	2015-02-15 00:00:00	136	1
3204	0	2014-12-02	2015-02-15 00:00:00	136	1
3205	0	2015-01-02	2015-02-15 00:00:00	136	1
3206	1553	2014-10-02	2015-02-15 00:00:00	137	1
3207	1568	2014-11-02	2015-02-15 00:00:00	137	1
3208	1581	2014-12-02	2015-02-15 00:00:00	137	1
3209	1593	2015-01-02	2015-02-15 00:00:00	137	1
3210	579	2014-10-02	2015-02-15 00:00:00	138	1
3211	583	2014-11-02	2015-02-15 00:00:00	138	1
3212	590	2014-12-02	2015-02-15 00:00:00	138	1
3213	596	2015-01-02	2015-02-15 00:00:00	138	1
3214	1111	2014-10-02	2015-02-15 00:00:00	139	1
3215	1116	2014-11-02	2015-02-15 00:00:00	139	1
3216	1126	2014-12-02	2015-02-15 00:00:00	139	1
3217	1140	2015-01-02	2015-02-15 00:00:00	139	1
3218	0	2014-10-02	2015-02-15 00:00:00	140	1
3219	0	2014-11-02	2015-02-15 00:00:00	140	1
3220	0	2014-12-02	2015-02-15 00:00:00	140	1
3221	0	2015-01-02	2015-02-15 00:00:00	140	1
3222	0	2014-10-02	2015-02-15 00:00:00	141	1
3223	0	2014-11-02	2015-02-15 00:00:00	141	1
3224	0	2014-12-02	2015-02-15 00:00:00	141	1
3225	0	2015-01-02	2015-02-15 00:00:00	141	1
3226	562	2014-10-02	2015-02-15 00:00:00	142	1
3227	570	2014-11-02	2015-02-15 00:00:00	142	1
3228	585	2014-12-02	2015-02-15 00:00:00	142	1
3229	599	2015-01-02	2015-02-15 00:00:00	142	1
3230	138	2014-10-02	2015-02-15 00:00:00	143	1
3231	141	2014-11-02	2015-02-15 00:00:00	143	1
3232	145	2014-12-02	2015-02-15 00:00:00	143	1
3233	150	2015-01-02	2015-02-15 00:00:00	143	1
3234	1094	2014-10-02	2015-02-15 00:00:00	144	1
3235	1107	2014-11-02	2015-02-15 00:00:00	144	1
3236	1122	2014-12-02	2015-02-15 00:00:00	144	1
3237	1137	2015-01-02	2015-02-15 00:00:00	144	1
3238	29	2014-10-02	2015-02-15 00:00:00	145	1
3239	30	2014-11-02	2015-02-15 00:00:00	145	1
3240	38	2014-12-02	2015-02-15 00:00:00	145	1
3241	47	2015-01-02	2015-02-15 00:00:00	145	1
3242	623	2014-10-02	2015-02-15 00:00:00	146	1
3243	640	2014-11-02	2015-02-15 00:00:00	146	1
3244	657	2014-12-02	2015-02-15 00:00:00	146	1
3245	675	2015-01-02	2015-02-15 00:00:00	146	1
3246	674	2014-10-02	2015-02-15 00:00:00	147	1
3247	690	2014-11-02	2015-02-15 00:00:00	147	1
3248	712	2014-12-02	2015-02-15 00:00:00	147	1
3249	736	2015-01-02	2015-02-15 00:00:00	147	1
3250	1502	2014-10-02	2015-02-15 00:00:00	148	1
3251	1522	2014-11-02	2015-02-15 00:00:00	148	1
3252	1543	2014-12-02	2015-02-15 00:00:00	148	1
3253	1545	2015-01-02	2015-02-15 00:00:00	148	1
3254	0	2014-10-02	2015-02-15 00:00:00	149	1
3255	0	2014-11-02	2015-02-15 00:00:00	149	1
3256	0	2014-12-02	2015-02-15 00:00:00	149	1
3257	0	2015-01-02	2015-02-15 00:00:00	149	1
3258	0	2014-10-02	2015-02-15 00:00:00	150	1
3259	0	2014-11-02	2015-02-15 00:00:00	150	1
3260	0	2014-12-02	2015-02-15 00:00:00	150	1
3261	0	2015-01-02	2015-02-15 00:00:00	150	1
3262	1087	2014-10-02	2015-02-15 00:00:00	151	1
3263	1093	2014-11-02	2015-02-15 00:00:00	151	1
3264	1102	2014-12-02	2015-02-15 00:00:00	151	1
3265	1114	2015-01-02	2015-02-15 00:00:00	151	1
3266	0	2014-10-02	2015-02-15 00:00:00	152	1
3267	0	2014-11-02	2015-02-15 00:00:00	152	1
3268	0	2014-12-02	2015-02-15 00:00:00	152	1
3269	0	2015-01-02	2015-02-15 00:00:00	152	1
3270	88	2014-10-02	2015-02-15 00:00:00	153	1
3271	89	2014-11-02	2015-02-15 00:00:00	153	1
3272	82	2014-12-02	2015-02-15 00:00:00	153	1
3273	83	2015-01-02	2015-02-15 00:00:00	153	1
3274	785	2014-10-02	2015-02-15 00:00:00	154	1
3275	791	2014-11-02	2015-02-15 00:00:00	154	1
3276	801	2014-12-02	2015-02-15 00:00:00	154	1
3277	815	2015-01-02	2015-02-15 00:00:00	154	1
3278	740	2014-10-02	2015-02-15 00:00:00	155	1
3279	742	2014-11-02	2015-02-15 00:00:00	155	1
3280	761	2014-12-02	2015-02-15 00:00:00	155	1
3281	783	2015-01-02	2015-02-15 00:00:00	155	1
3282	24	2014-10-02	2015-02-15 00:00:00	156	1
3283	25	2014-11-02	2015-02-15 00:00:00	156	1
3284	28	2014-12-02	2015-02-15 00:00:00	156	1
3285	31	2015-01-02	2015-02-15 00:00:00	156	1
3286	0	2014-10-02	2015-02-15 00:00:00	157	1
3287	0	2014-11-02	2015-02-15 00:00:00	157	1
3288	0	2014-12-02	2015-02-15 00:00:00	157	1
3289	0	2015-01-02	2015-02-15 00:00:00	157	1
3290	0	2014-10-02	2015-02-15 00:00:00	158	1
3291	0	2014-11-02	2015-02-15 00:00:00	158	1
3292	0	2014-12-02	2015-02-15 00:00:00	158	1
3293	0	2015-01-02	2015-02-15 00:00:00	158	1
3294	21	2014-10-02	2015-02-15 00:00:00	159	1
3295	21	2014-11-02	2015-02-15 00:00:00	159	1
3296	22	2014-12-02	2015-02-15 00:00:00	159	1
3297	23	2015-01-02	2015-02-15 00:00:00	159	1
3298	888	2014-10-02	2015-02-15 00:00:00	160	1
3299	904	2014-11-02	2015-02-15 00:00:00	160	1
3300	918	2014-12-02	2015-02-15 00:00:00	160	1
3301	938	2015-01-02	2015-02-15 00:00:00	160	1
3302	781	2014-10-02	2015-02-15 00:00:00	161	1
3303	785	2014-11-02	2015-02-15 00:00:00	161	1
3304	791	2014-12-02	2015-02-15 00:00:00	161	1
3305	799	2015-01-02	2015-02-15 00:00:00	161	1
3306	361	2014-10-02	2015-02-15 00:00:00	162	1
3307	369	2014-11-02	2015-02-15 00:00:00	162	1
3308	380	2014-12-02	2015-02-15 00:00:00	162	1
3309	391	2015-01-02	2015-02-15 00:00:00	162	1
3310	0	2014-10-02	2015-02-15 00:00:00	163	1
3311	0	2014-11-02	2015-02-15 00:00:00	163	1
3312	0	2014-12-02	2015-02-15 00:00:00	163	1
3313	0	2015-01-02	2015-02-15 00:00:00	163	1
3314	0	2014-10-02	2015-02-15 00:00:00	164	1
3315	0	2014-11-02	2015-02-15 00:00:00	164	1
3316	0	2014-12-02	2015-02-15 00:00:00	164	1
3317	0	2015-01-02	2015-02-15 00:00:00	164	1
3318	827	2014-10-02	2015-02-15 00:00:00	165	1
3319	842	2014-11-02	2015-02-15 00:00:00	165	1
3320	857	2014-12-02	2015-02-15 00:00:00	165	1
3321	868	2015-01-02	2015-02-15 00:00:00	165	1
3322	0	2014-10-02	2015-02-15 00:00:00	166	1
3323	0	2014-11-02	2015-02-15 00:00:00	166	1
3324	0	2014-12-02	2015-02-15 00:00:00	166	1
3325	0	2015-01-02	2015-02-15 00:00:00	166	1
3326	0	2014-10-02	2015-02-15 00:00:00	167	1
3327	0	2014-11-02	2015-02-15 00:00:00	167	1
3328	0	2014-12-02	2015-02-15 00:00:00	167	1
3329	0	2015-01-02	2015-02-15 00:00:00	167	1
3330	0	2014-10-02	2015-02-15 00:00:00	168	1
3331	0	2014-11-02	2015-02-15 00:00:00	168	1
3332	0	2014-12-02	2015-02-15 00:00:00	168	1
3333	0	2015-01-02	2015-02-15 00:00:00	168	1
3334	181	2014-10-02	2015-02-15 00:00:00	169	1
3335	193	2014-11-02	2015-02-15 00:00:00	169	1
3336	203	2014-12-02	2015-02-15 00:00:00	169	1
3337	215	2015-01-02	2015-02-15 00:00:00	169	1
3338	99	2014-10-02	2015-02-15 00:00:00	170	1
3339	108	2014-11-02	2015-02-15 00:00:00	170	1
3340	123	2014-12-02	2015-02-15 00:00:00	170	1
3341	142	2015-01-02	2015-02-15 00:00:00	170	1
3342	243	2014-10-02	2015-02-15 00:00:00	171	1
3343	255	2014-11-02	2015-02-15 00:00:00	171	1
3344	272	2014-12-02	2015-02-15 00:00:00	171	1
3345	290	2015-01-02	2015-02-15 00:00:00	171	1
3346	119	2014-10-02	2015-02-15 00:00:00	172	1
3347	128	2014-11-02	2015-02-15 00:00:00	172	1
3348	137	2014-12-02	2015-02-15 00:00:00	172	1
3349	147	2015-01-02	2015-02-15 00:00:00	172	1
3350	1068	2014-10-02	2015-02-15 00:00:00	173	1
3351	0	2014-11-02	2015-02-15 00:00:00	173	1
3352	16	2014-12-02	2015-02-15 00:00:00	173	1
3353	28	2015-01-02	2015-02-15 00:00:00	173	1
3354	236	2014-10-02	2015-02-15 00:00:00	174	1
3355	249	2014-11-02	2015-02-15 00:00:00	174	1
3356	261	2014-12-02	2015-02-15 00:00:00	174	1
3357	274	2015-01-02	2015-02-15 00:00:00	174	1
3358	571	2014-10-02	2015-02-15 00:00:00	175	1
3359	581	2014-11-02	2015-02-15 00:00:00	175	1
3360	594	2014-12-02	2015-02-15 00:00:00	175	1
3361	608	2015-01-02	2015-02-15 00:00:00	175	1
3362	177	2014-10-02	2015-02-15 00:00:00	176	1
3363	189	2014-11-02	2015-02-15 00:00:00	176	1
3364	202	2014-12-02	2015-02-15 00:00:00	176	1
3365	217	2015-01-02	2015-02-15 00:00:00	176	1
3366	136	2014-10-02	2015-02-15 00:00:00	177	1
3367	144	2014-11-02	2015-02-15 00:00:00	177	1
3368	161	2014-12-02	2015-02-15 00:00:00	177	1
3369	180	2015-01-02	2015-02-15 00:00:00	177	1
3370	409	2014-10-02	2015-02-15 00:00:00	178	1
3371	423	2014-11-02	2015-02-15 00:00:00	178	1
3372	434	2014-12-02	2015-02-15 00:00:00	178	1
3373	446	2015-01-02	2015-02-15 00:00:00	178	1
3374	1101	2014-10-02	2015-02-15 00:00:00	179	1
3375	1101	2014-11-02	2015-02-15 00:00:00	179	1
3376	1101	2014-12-02	2015-02-15 00:00:00	179	1
3377	1101	2015-01-02	2015-02-15 00:00:00	179	1
3378	53	2014-10-02	2015-02-15 00:00:00	180	1
3379	59	2014-11-02	2015-02-15 00:00:00	180	1
3380	73	2014-12-02	2015-02-15 00:00:00	180	1
3381	85	2015-01-02	2015-02-15 00:00:00	180	1
3382	314	2014-10-02	2015-02-15 00:00:00	181	1
3383	325	2014-11-02	2015-02-15 00:00:00	181	1
3384	336	2014-12-02	2015-02-15 00:00:00	181	1
3385	346	2015-01-02	2015-02-15 00:00:00	181	1
3386	769	2014-10-02	2015-02-15 00:00:00	182	1
3387	784	2014-11-02	2015-02-15 00:00:00	182	1
3388	798	2014-12-02	2015-02-15 00:00:00	182	1
3389	816	2015-01-02	2015-02-15 00:00:00	182	1
3390	57	2014-10-02	2015-02-15 00:00:00	183	1
3391	72	2014-11-02	2015-02-15 00:00:00	183	1
3392	94	2014-12-02	2015-02-15 00:00:00	183	1
3393	117	2015-01-02	2015-02-15 00:00:00	183	1
3394	121	2014-10-02	2015-02-15 00:00:00	184	1
3395	134	2014-11-02	2015-02-15 00:00:00	184	1
3396	150	2014-12-02	2015-02-15 00:00:00	184	1
3397	170	2015-01-02	2015-02-15 00:00:00	184	1
3398	1158	2014-10-02	2015-02-15 00:00:00	185	1
3399	1169	2014-11-02	2015-02-15 00:00:00	185	1
3400	1183	2014-12-02	2015-02-15 00:00:00	185	1
3401	1201	2015-01-02	2015-02-15 00:00:00	185	1
3402	174	2014-10-02	2015-02-15 00:00:00	186	1
3403	183	2014-11-02	2015-02-15 00:00:00	186	1
3404	202	2014-12-02	2015-02-15 00:00:00	186	1
3405	224	2015-01-02	2015-02-15 00:00:00	186	1
3406	488	2014-10-02	2015-02-15 00:00:00	187	1
3407	502	2014-11-02	2015-02-15 00:00:00	187	1
3408	516	2014-12-02	2015-02-15 00:00:00	187	1
3409	530	2015-01-02	2015-02-15 00:00:00	187	1
3410	646	2014-10-02	2015-02-15 00:00:00	188	1
3411	671	2014-11-02	2015-02-15 00:00:00	188	1
3412	693	2014-12-02	2015-02-15 00:00:00	188	1
3413	720	2015-01-02	2015-02-15 00:00:00	188	1
3414	935	2014-10-02	2015-02-15 00:00:00	189	1
3415	0	2014-11-02	2015-02-15 00:00:00	189	1
3416	12	2014-12-02	2015-02-15 00:00:00	189	1
3417	26	2015-01-02	2015-02-15 00:00:00	189	1
3418	115	2014-10-02	2015-02-15 00:00:00	190	1
3419	131	2014-11-02	2015-02-15 00:00:00	190	1
3420	146	2014-12-02	2015-02-15 00:00:00	190	1
3421	160	2015-01-02	2015-02-15 00:00:00	190	1
3422	308	2014-10-02	2015-02-15 00:00:00	191	1
3423	322	2014-11-02	2015-02-15 00:00:00	191	1
3424	338	2014-12-02	2015-02-15 00:00:00	191	1
3425	356	2015-01-02	2015-02-15 00:00:00	191	1
3426	143	2014-10-02	2015-02-15 00:00:00	192	1
3427	153	2014-11-02	2015-02-15 00:00:00	192	1
3428	153	2014-12-02	2015-02-15 00:00:00	192	1
3429	155	2015-01-02	2015-02-15 00:00:00	192	1
3430	53	2014-10-02	2015-02-15 00:00:00	193	1
3431	63	2014-11-02	2015-02-15 00:00:00	193	1
3432	75	2014-12-02	2015-02-15 00:00:00	193	1
3433	91	2015-01-02	2015-02-15 00:00:00	193	1
3434	257	2014-10-02	2015-02-15 00:00:00	194	1
3435	274	2014-11-02	2015-02-15 00:00:00	194	1
3436	288	2014-12-02	2015-02-15 00:00:00	194	1
3437	301	2015-01-02	2015-02-15 00:00:00	194	1
3438	98	2014-10-02	2015-02-15 00:00:00	195	1
3439	98	2014-11-02	2015-02-15 00:00:00	195	1
3440	98	2014-12-02	2015-02-15 00:00:00	195	1
3441	98	2015-01-02	2015-02-15 00:00:00	195	1
3442	2343	2014-10-02	2015-02-15 00:00:00	196	1
3443	2357	2014-11-02	2015-02-15 00:00:00	196	1
3444	2373	2014-12-02	2015-02-15 00:00:00	196	1
3445	2393	2015-01-02	2015-02-15 00:00:00	196	1
3446	129	2014-10-02	2015-02-15 00:00:00	197	1
3447	148	2014-11-02	2015-02-15 00:00:00	197	1
3448	160	2014-12-02	2015-02-15 00:00:00	197	1
3449	185	2015-01-02	2015-02-15 00:00:00	197	1
3450	1501	2014-10-02	2015-02-15 00:00:00	198	1
3451	1513	2014-11-02	2015-02-15 00:00:00	198	1
3452	1525	2014-12-02	2015-02-15 00:00:00	198	1
3453	1540	2015-01-02	2015-02-15 00:00:00	198	1
3454	877	2014-10-02	2015-02-15 00:00:00	199	1
3455	882	2014-11-02	2015-02-15 00:00:00	199	1
3456	885	2014-12-02	2015-02-15 00:00:00	199	1
3457	888	2015-01-02	2015-02-15 00:00:00	199	1
3458	332	2014-10-02	2015-02-15 00:00:00	200	1
3459	332	2014-11-02	2015-02-15 00:00:00	200	1
3460	332	2014-12-02	2015-02-15 00:00:00	200	1
3461	337	2015-01-02	2015-02-15 00:00:00	200	1
3462	1002	2014-10-02	2015-02-15 00:00:00	201	1
3463	1011	2014-11-02	2015-02-15 00:00:00	201	1
3464	1022	2014-12-02	2015-02-15 00:00:00	201	1
3465	1034	2015-01-02	2015-02-15 00:00:00	201	1
3466	322	2014-10-02	2015-02-15 00:00:00	202	1
3467	324	2014-11-02	2015-02-15 00:00:00	202	1
3468	325	2014-12-02	2015-02-15 00:00:00	202	1
3469	332	2015-01-02	2015-02-15 00:00:00	202	1
3470	1395	2014-10-02	2015-02-15 00:00:00	203	1
3471	1408	2014-11-02	2015-02-15 00:00:00	203	1
3472	1424	2014-12-02	2015-02-15 00:00:00	203	1
3473	1443	2015-01-02	2015-02-15 00:00:00	203	1
3474	148	2014-10-02	2015-02-15 00:00:00	204	1
3475	161	2014-11-02	2015-02-15 00:00:00	204	1
3476	176	2014-12-02	2015-02-15 00:00:00	204	1
3477	190	2015-01-02	2015-02-15 00:00:00	204	1
3478	29	2014-10-02	2015-02-15 00:00:00	205	1
3479	30	2014-11-02	2015-02-15 00:00:00	205	1
3480	32	2014-12-02	2015-02-15 00:00:00	205	1
3481	34	2015-01-02	2015-02-15 00:00:00	205	1
3482	289	2014-10-02	2015-02-15 00:00:00	206	1
3483	295	2014-11-02	2015-02-15 00:00:00	206	1
3484	300	2014-12-02	2015-02-15 00:00:00	206	1
3485	302	2015-01-02	2015-02-15 00:00:00	206	1
3486	1298	2014-10-02	2015-02-15 00:00:00	207	1
3487	1306	2014-11-02	2015-02-15 00:00:00	207	1
3488	1318	2014-12-02	2015-02-15 00:00:00	207	1
3489	1334	2015-01-02	2015-02-15 00:00:00	207	1
3490	596	2014-10-02	2015-02-15 00:00:00	208	1
3491	601	2014-11-02	2015-02-15 00:00:00	208	1
3492	612	2014-12-02	2015-02-15 00:00:00	208	1
3493	624	2015-01-02	2015-02-15 00:00:00	208	1
3494	1843	2014-10-02	2015-02-15 00:00:00	209	1
3495	1856	2014-11-02	2015-02-15 00:00:00	209	1
3496	1875	2014-12-02	2015-02-15 00:00:00	209	1
3497	1896	2015-01-02	2015-02-15 00:00:00	209	1
3498	275	2014-10-02	2015-02-15 00:00:00	210	1
3499	275	2014-11-02	2015-02-15 00:00:00	210	1
3500	278	2014-12-02	2015-02-15 00:00:00	210	1
3501	282	2015-01-02	2015-02-15 00:00:00	210	1
3502	500	2014-10-02	2015-02-15 00:00:00	211	1
3503	513	2014-11-02	2015-02-15 00:00:00	211	1
3504	526	2014-12-02	2015-02-15 00:00:00	211	1
3505	540	2015-01-02	2015-02-15 00:00:00	211	1
3506	0	2014-10-02	2015-02-15 00:00:00	212	1
3507	0	2014-11-02	2015-02-15 00:00:00	212	1
3508	0	2014-12-02	2015-02-15 00:00:00	212	1
3509	0	2015-01-02	2015-02-15 00:00:00	212	1
3510	0	2014-10-02	2015-02-15 00:00:00	213	1
3511	0	2014-11-02	2015-02-15 00:00:00	213	1
3512	0	2014-12-02	2015-02-15 00:00:00	213	1
3513	0	2015-01-02	2015-02-15 00:00:00	213	1
3514	1003	2014-10-02	2015-02-15 00:00:00	214	1
3515	1010	2014-11-02	2015-02-15 00:00:00	214	1
3516	1019	2014-12-02	2015-02-15 00:00:00	214	1
3517	1027	2015-01-02	2015-02-15 00:00:00	214	1
3518	808	2014-10-02	2015-02-15 00:00:00	215	1
3519	813	2014-11-02	2015-02-15 00:00:00	215	1
3520	831	2014-12-02	2015-02-15 00:00:00	215	1
3521	847	2015-01-02	2015-02-15 00:00:00	215	1
3522	65	2014-10-02	2015-02-15 00:00:00	216	1
3523	66	2014-11-02	2015-02-15 00:00:00	216	1
3524	66	2014-12-02	2015-02-15 00:00:00	216	1
3525	66	2015-01-02	2015-02-15 00:00:00	216	1
3526	1370	2014-10-02	2015-02-15 00:00:00	217	1
3527	1377	2014-11-02	2015-02-15 00:00:00	217	1
3528	1389	2014-12-02	2015-02-15 00:00:00	217	1
3529	1400	2015-01-02	2015-02-15 00:00:00	217	1
3530	1268	2014-10-02	2015-02-15 00:00:00	218	1
3531	1278	2014-11-02	2015-02-15 00:00:00	218	1
3532	1292	2014-12-02	2015-02-15 00:00:00	218	1
3533	1304	2015-01-02	2015-02-15 00:00:00	218	1
3534	1642	2014-10-02	2015-02-15 00:00:00	219	1
3535	1651	2014-11-02	2015-02-15 00:00:00	219	1
3536	1661	2014-12-02	2015-02-15 00:00:00	219	1
3537	1674	2015-01-02	2015-02-15 00:00:00	219	1
3538	316	2014-10-02	2015-02-15 00:00:00	220	1
3539	326	2014-11-02	2015-02-15 00:00:00	220	1
3540	335	2014-12-02	2015-02-15 00:00:00	220	1
3541	345	2015-01-02	2015-02-15 00:00:00	220	1
3542	497	2014-10-02	2015-02-15 00:00:00	221	1
3543	498	2014-11-02	2015-02-15 00:00:00	221	1
3544	502	2014-12-02	2015-02-15 00:00:00	221	1
3545	504	2015-01-02	2015-02-15 00:00:00	221	1
3546	0	2014-10-02	2015-02-15 00:00:00	222	1
3547	0	2014-11-02	2015-02-15 00:00:00	222	1
3548	0	2014-12-02	2015-02-15 00:00:00	222	1
3549	0	2015-01-02	2015-02-15 00:00:00	222	1
3550	144	2014-10-02	2015-02-15 00:00:00	223	1
3551	144	2014-11-02	2015-02-15 00:00:00	223	1
3552	160	2014-12-02	2015-02-15 00:00:00	223	1
3553	174	2015-01-02	2015-02-15 00:00:00	223	1
3554	53	2014-10-02	2015-02-15 00:00:00	224	1
3555	56	2014-11-02	2015-02-15 00:00:00	224	1
3556	60	2014-12-02	2015-02-15 00:00:00	224	1
3557	70	2015-01-02	2015-02-15 00:00:00	224	1
3558	0	2014-10-02	2015-02-15 00:00:00	225	1
3559	0	2014-11-02	2015-02-15 00:00:00	225	1
3560	0	2014-12-02	2015-02-15 00:00:00	225	1
3561	0	2015-01-02	2015-02-15 00:00:00	225	1
3562	707	2014-10-02	2015-02-15 00:00:00	226	1
3563	707	2014-11-02	2015-02-15 00:00:00	226	1
3564	707	2014-12-02	2015-02-15 00:00:00	226	1
3565	708	2015-01-02	2015-02-15 00:00:00	226	1
3566	1004	2014-10-02	2015-02-15 00:00:00	227	1
3567	1006	2014-11-02	2015-02-15 00:00:00	227	1
3568	1013	2014-12-02	2015-02-15 00:00:00	227	1
3569	1020	2015-01-02	2015-02-15 00:00:00	227	1
3570	750	2014-10-02	2015-02-15 00:00:00	228	1
3571	753	2014-11-02	2015-02-15 00:00:00	228	1
3572	758	2014-12-02	2015-02-15 00:00:00	228	1
3573	761	2015-01-02	2015-02-15 00:00:00	228	1
3574	952	2014-10-02	2015-02-15 00:00:00	229	1
3575	960	2014-11-02	2015-02-15 00:00:00	229	1
3576	968	2014-12-02	2015-02-15 00:00:00	229	1
3577	982	2015-01-02	2015-02-15 00:00:00	229	1
3578	457	2014-10-02	2015-02-15 00:00:00	230	1
3579	459	2014-11-02	2015-02-15 00:00:00	230	1
3580	467	2014-12-02	2015-02-15 00:00:00	230	1
3581	469	2015-01-02	2015-02-15 00:00:00	230	1
3582	197	2014-10-02	2015-02-15 00:00:00	231	1
3583	199	2014-11-02	2015-02-15 00:00:00	231	1
3584	205	2014-12-02	2015-02-15 00:00:00	231	1
3585	216	2015-01-02	2015-02-15 00:00:00	231	1
3586	707	2014-10-02	2015-02-15 00:00:00	232	1
3587	712	2014-11-02	2015-02-15 00:00:00	232	1
3588	717	2014-12-02	2015-02-15 00:00:00	232	1
3589	723	2015-01-02	2015-02-15 00:00:00	232	1
3590	1235	2014-10-02	2015-02-15 00:00:00	233	1
3591	1248	2014-11-02	2015-02-15 00:00:00	233	1
3592	1273	2014-12-02	2015-02-15 00:00:00	233	1
3593	1293	2015-01-02	2015-02-15 00:00:00	233	1
3594	574	2014-10-02	2015-02-15 00:00:00	234	1
3595	578	2014-11-02	2015-02-15 00:00:00	234	1
3596	582	2014-12-02	2015-02-15 00:00:00	234	1
3597	585	2015-01-02	2015-02-15 00:00:00	234	1
3598	0	2014-10-02	2015-02-15 00:00:00	235	1
3599	0	2014-11-02	2015-02-15 00:00:00	235	1
3600	0	2014-12-02	2015-02-15 00:00:00	235	1
3601	0	2015-01-02	2015-02-15 00:00:00	235	1
3602	434	2014-10-02	2015-02-15 00:00:00	236	1
3603	440	2014-11-02	2015-02-15 00:00:00	236	1
3604	448	2014-12-02	2015-02-15 00:00:00	236	1
3605	455	2015-01-02	2015-02-15 00:00:00	236	1
3606	931	2014-10-02	2015-02-15 00:00:00	237	1
3607	939	2014-11-02	2015-02-15 00:00:00	237	1
3608	949	2014-12-02	2015-02-15 00:00:00	237	1
3609	955	2015-01-02	2015-02-15 00:00:00	237	1
3610	511	2014-10-02	2015-02-15 00:00:00	238	1
3611	514	2014-11-02	2015-02-15 00:00:00	238	1
3612	519	2014-12-02	2015-02-15 00:00:00	238	1
3613	522	2015-01-02	2015-02-15 00:00:00	238	1
3614	713	2014-10-02	2015-02-15 00:00:00	239	1
3615	717	2014-11-02	2015-02-15 00:00:00	239	1
3616	723	2014-12-02	2015-02-15 00:00:00	239	1
3617	728	2015-01-02	2015-02-15 00:00:00	239	1
3618	877	2014-10-02	2015-02-15 00:00:00	240	1
3619	880	2014-11-02	2015-02-15 00:00:00	240	1
3620	885	2014-12-02	2015-02-15 00:00:00	240	1
3621	892	2015-01-02	2015-02-15 00:00:00	240	1
3622	0	2014-10-02	2015-02-15 00:00:00	241	1
3623	0	2014-11-02	2015-02-15 00:00:00	241	1
3624	0	2014-12-02	2015-02-15 00:00:00	241	1
3625	0	2015-01-02	2015-02-15 00:00:00	241	1
3626	1199	2014-10-02	2015-02-15 00:00:00	242	1
3627	1208	2014-11-02	2015-02-15 00:00:00	242	1
3628	1215	2014-12-02	2015-02-15 00:00:00	242	1
3629	1223	2015-01-02	2015-02-15 00:00:00	242	1
3630	808	2014-10-02	2015-02-15 00:00:00	243	1
3631	809	2014-11-02	2015-02-15 00:00:00	243	1
3632	812	2014-12-02	2015-02-15 00:00:00	243	1
3633	816	2015-01-02	2015-02-15 00:00:00	243	1
3634	916	2014-10-02	2015-02-15 00:00:00	244	1
3635	920	2014-11-02	2015-02-15 00:00:00	244	1
3636	923	2014-12-02	2015-02-15 00:00:00	244	1
3637	928	2015-01-02	2015-02-15 00:00:00	244	1
3638	804	2014-10-02	2015-02-15 00:00:00	245	1
3639	811	2014-11-02	2015-02-15 00:00:00	245	1
3640	817	2014-12-02	2015-02-15 00:00:00	245	1
3641	826	2015-01-02	2015-02-15 00:00:00	245	1
3642	1013	2014-10-02	2015-02-15 00:00:00	246	1
3643	1019	2014-11-02	2015-02-15 00:00:00	246	1
3644	1026	2014-12-02	2015-02-15 00:00:00	246	1
3645	1033	2015-01-02	2015-02-15 00:00:00	246	1
3646	378	2014-10-02	2015-02-15 00:00:00	247	1
3647	383	2014-11-02	2015-02-15 00:00:00	247	1
3648	392	2014-12-02	2015-02-15 00:00:00	247	1
3649	399	2015-01-02	2015-02-15 00:00:00	247	1
3650	1327	2014-10-02	2015-02-15 00:00:00	248	1
3651	1333	2014-11-02	2015-02-15 00:00:00	248	1
3652	1342	2014-12-02	2015-02-15 00:00:00	248	1
3653	1354	2015-01-02	2015-02-15 00:00:00	248	1
3654	660	2014-10-02	2015-02-15 00:00:00	249	1
3655	661	2014-11-02	2015-02-15 00:00:00	249	1
3656	662	2014-12-02	2015-02-15 00:00:00	249	1
3657	682	2015-01-02	2015-02-15 00:00:00	249	1
3658	1464	2014-10-02	2015-02-15 00:00:00	250	1
3659	1474	2014-11-02	2015-02-15 00:00:00	250	1
3660	1484	2014-12-02	2015-02-15 00:00:00	250	1
3661	1499	2015-01-02	2015-02-15 00:00:00	250	1
3662	0	2014-10-02	2015-02-15 00:00:00	251	1
3663	0	2014-11-02	2015-02-15 00:00:00	251	1
3664	0	2014-12-02	2015-02-15 00:00:00	251	1
3665	0	2015-01-02	2015-02-15 00:00:00	251	1
3666	1063	2014-10-02	2015-02-15 00:00:00	252	1
3667	1064	2014-11-02	2015-02-15 00:00:00	252	1
3668	1064	2014-12-02	2015-02-15 00:00:00	252	1
3669	1075	2015-01-02	2015-02-15 00:00:00	252	1
3670	190	2014-10-02	2015-02-15 00:00:00	253	1
3671	195	2014-11-02	2015-02-15 00:00:00	253	1
3672	203	2014-12-02	2015-02-15 00:00:00	253	1
3673	214	2015-01-02	2015-02-15 00:00:00	253	1
3674	0	2014-10-02	2015-02-15 00:00:00	254	1
3675	0	2014-11-02	2015-02-15 00:00:00	254	1
3676	0	2014-12-02	2015-02-15 00:00:00	254	1
3677	0	2015-01-02	2015-02-15 00:00:00	254	1
3678	1354	2014-10-02	2015-02-15 00:00:00	255	1
3679	1357	2014-11-02	2015-02-15 00:00:00	255	1
3680	1372	2014-12-02	2015-02-15 00:00:00	255	1
3681	1388	2015-01-02	2015-02-15 00:00:00	255	1
3682	747	2014-10-02	2015-02-15 00:00:00	256	1
3683	752	2014-11-02	2015-02-15 00:00:00	256	1
3684	758	2014-12-02	2015-02-15 00:00:00	256	1
3685	768	2015-01-02	2015-02-15 00:00:00	256	1
3686	699	2014-10-02	2015-02-15 00:00:00	257	1
3687	707	2014-11-02	2015-02-15 00:00:00	257	1
3688	715	2014-12-02	2015-02-15 00:00:00	257	1
3689	717	2015-01-02	2015-02-15 00:00:00	257	1
3690	1609	2014-10-02	2015-02-15 00:00:00	258	1
3691	1625	2014-11-02	2015-02-15 00:00:00	258	1
3692	1647	2014-12-02	2015-02-15 00:00:00	258	1
3693	1674	2015-01-02	2015-02-15 00:00:00	258	1
3694	731	2014-10-02	2015-02-15 00:00:00	259	1
3695	733	2014-11-02	2015-02-15 00:00:00	259	1
3696	735	2014-12-02	2015-02-15 00:00:00	259	1
3697	737	2015-01-02	2015-02-15 00:00:00	259	1
3698	403	2014-10-02	2015-02-15 00:00:00	260	1
3699	404	2014-11-02	2015-02-15 00:00:00	260	1
3700	413	2014-12-02	2015-02-15 00:00:00	260	1
3701	413	2015-01-02	2015-02-15 00:00:00	260	1
3702	1400	2014-10-02	2015-02-15 00:00:00	261	1
3703	1414	2014-11-02	2015-02-15 00:00:00	261	1
3704	1420	2014-12-02	2015-02-15 00:00:00	261	1
3705	1429	2015-01-02	2015-02-15 00:00:00	261	1
3706	1308	2014-10-02	2015-02-15 00:00:00	262	1
3707	1320	2014-11-02	2015-02-15 00:00:00	262	1
3708	1336	2014-12-02	2015-02-15 00:00:00	262	1
3709	1351	2015-01-02	2015-02-15 00:00:00	262	1
3710	995	2014-10-02	2015-02-15 00:00:00	263	1
3711	1007	2014-11-02	2015-02-15 00:00:00	263	1
3712	1024	2014-12-02	2015-02-15 00:00:00	263	1
3713	1041	2015-01-02	2015-02-15 00:00:00	263	1
3714	533	2014-10-02	2015-02-15 00:00:00	264	1
3715	538	2014-11-02	2015-02-15 00:00:00	264	1
3716	544	2014-12-02	2015-02-15 00:00:00	264	1
3717	554	2015-01-02	2015-02-15 00:00:00	264	1
3718	1522	2014-10-02	2015-02-15 00:00:00	265	1
3719	1538	2014-11-02	2015-02-15 00:00:00	265	1
3720	1548	2014-12-02	2015-02-15 00:00:00	265	1
3721	1561	2015-01-02	2015-02-15 00:00:00	265	1
3722	333	2014-10-02	2015-02-15 00:00:00	266	1
3723	334	2014-11-02	2015-02-15 00:00:00	266	1
3724	336	2014-12-02	2015-02-15 00:00:00	266	1
3725	339	2015-01-02	2015-02-15 00:00:00	266	1
3726	1277	2014-10-02	2015-02-15 00:00:00	267	1
3727	1288	2014-11-02	2015-02-15 00:00:00	267	1
3728	1303	2014-12-02	2015-02-15 00:00:00	267	1
3729	1321	2015-01-02	2015-02-15 00:00:00	267	1
3730	1127	2014-10-02	2015-02-15 00:00:00	268	1
3731	1136	2014-11-02	2015-02-15 00:00:00	268	1
3732	1143	2014-12-02	2015-02-15 00:00:00	268	1
3733	1152	2015-01-02	2015-02-15 00:00:00	268	1
3734	51	2014-10-02	2015-02-15 00:00:00	269	1
3735	64	2014-11-02	2015-02-15 00:00:00	269	1
3736	67	2014-12-02	2015-02-15 00:00:00	269	1
3737	80	2015-01-02	2015-02-15 00:00:00	269	1
3738	0	2014-10-02	2015-02-15 00:00:00	270	1
3739	0	2014-11-02	2015-02-15 00:00:00	270	1
3740	0	2014-12-02	2015-02-15 00:00:00	270	1
3741	0	2015-01-02	2015-02-15 00:00:00	270	1
3742	6	2014-10-02	2015-02-15 00:00:00	271	1
3743	6	2014-11-02	2015-02-15 00:00:00	271	1
3744	6	2014-12-02	2015-02-15 00:00:00	271	1
3745	6	2015-01-02	2015-02-15 00:00:00	271	1
3746	887	2014-10-02	2015-02-15 00:00:00	272	1
3747	900	2014-11-02	2015-02-15 00:00:00	272	1
3748	907	2014-12-02	2015-02-15 00:00:00	272	1
3749	918	2015-01-02	2015-02-15 00:00:00	272	1
3750	622	2014-10-02	2015-02-15 00:00:00	273	1
3751	628	2014-11-02	2015-02-15 00:00:00	273	1
3752	642	2014-12-02	2015-02-15 00:00:00	273	1
3753	649	2015-01-02	2015-02-15 00:00:00	273	1
3754	533	2014-10-02	2015-02-15 00:00:00	274	1
3755	534	2014-11-02	2015-02-15 00:00:00	274	1
3756	536	2014-12-02	2015-02-15 00:00:00	274	1
3757	537	2015-01-02	2015-02-15 00:00:00	274	1
3758	1075	2014-10-02	2015-02-15 00:00:00	275	1
3759	1082	2014-11-02	2015-02-15 00:00:00	275	1
3760	1095	2014-12-02	2015-02-15 00:00:00	275	1
3761	1106	2015-01-02	2015-02-15 00:00:00	275	1
3762	515	2014-10-02	2015-02-15 00:00:00	276	1
3763	516	2014-11-02	2015-02-15 00:00:00	276	1
3764	517	2014-12-02	2015-02-15 00:00:00	276	1
3765	519	2015-01-02	2015-02-15 00:00:00	276	1
3766	0	2014-10-02	2015-02-15 00:00:00	277	1
3767	0	2014-11-02	2015-02-15 00:00:00	277	1
3768	0	2014-12-02	2015-02-15 00:00:00	277	1
3769	0	2015-01-02	2015-02-15 00:00:00	277	1
3770	318	2014-10-02	2015-02-15 00:00:00	278	1
3771	324	2014-11-02	2015-02-15 00:00:00	278	1
3772	333	2014-12-02	2015-02-15 00:00:00	278	1
3773	344	2015-01-02	2015-02-15 00:00:00	278	1
3774	1615	2014-10-02	2015-02-15 00:00:00	279	1
3775	1616	2014-11-02	2015-02-15 00:00:00	279	1
3776	1616	2014-12-02	2015-02-15 00:00:00	279	1
3777	1622	2015-01-02	2015-02-15 00:00:00	279	1
3778	386	2014-10-02	2015-02-15 00:00:00	280	1
3779	387	2014-11-02	2015-02-15 00:00:00	280	1
3780	391	2014-12-02	2015-02-15 00:00:00	280	1
3781	399	2015-01-02	2015-02-15 00:00:00	280	1
3782	758	2014-10-02	2015-02-15 00:00:00	281	1
3783	762	2014-11-02	2015-02-15 00:00:00	281	1
3784	765	2014-12-02	2015-02-15 00:00:00	281	1
3785	770	2015-01-02	2015-02-15 00:00:00	281	1
3786	668	2014-10-02	2015-02-15 00:00:00	282	1
3787	675	2014-11-02	2015-02-15 00:00:00	282	1
3788	682	2014-12-02	2015-02-15 00:00:00	282	1
3789	691	2015-01-02	2015-02-15 00:00:00	282	1
3790	639	2014-10-02	2015-02-15 00:00:00	283	1
3791	639	2014-11-02	2015-02-15 00:00:00	283	1
3792	639	2014-12-02	2015-02-15 00:00:00	283	1
3793	639	2015-01-02	2015-02-15 00:00:00	283	1
3794	7	2014-10-02	2015-02-15 00:00:00	284	1
3795	15	2014-11-02	2015-02-15 00:00:00	284	1
3796	30	2014-12-02	2015-02-15 00:00:00	284	1
3797	38	2015-01-02	2015-02-15 00:00:00	284	1
3798	0	2014-10-02	2015-02-15 00:00:00	285	1
3799	0	2014-11-02	2015-02-15 00:00:00	285	1
3800	0	2014-12-02	2015-02-15 00:00:00	285	1
3801	0	2015-01-02	2015-02-15 00:00:00	285	1
3802	1224	2014-10-02	2015-02-15 00:00:00	286	1
3803	1238	2014-11-02	2015-02-15 00:00:00	286	1
3804	1249	2014-12-02	2015-02-15 00:00:00	286	1
3805	1280	2015-01-02	2015-02-15 00:00:00	286	1
3806	461	2014-10-02	2015-02-15 00:00:00	287	1
3807	461	2014-11-02	2015-02-15 00:00:00	287	1
3808	465	2014-12-02	2015-02-15 00:00:00	287	1
3809	470	2015-01-02	2015-02-15 00:00:00	287	1
3810	1007	2014-10-02	2015-02-15 00:00:00	288	1
3811	1011	2014-11-02	2015-02-15 00:00:00	288	1
3812	1017	2014-12-02	2015-02-15 00:00:00	288	1
3813	1024	2015-01-02	2015-02-15 00:00:00	288	1
3814	0	2014-10-02	2015-02-15 00:00:00	289	1
3815	0	2014-11-02	2015-02-15 00:00:00	289	1
3816	0	2014-12-02	2015-02-15 00:00:00	289	1
3817	0	2015-01-02	2015-02-15 00:00:00	289	1
3818	172	2014-10-02	2015-02-15 00:00:00	290	1
3819	176	2014-11-02	2015-02-15 00:00:00	290	1
3820	179	2014-12-02	2015-02-15 00:00:00	290	1
3821	183	2015-01-02	2015-02-15 00:00:00	290	1
3822	696	2014-10-02	2015-02-15 00:00:00	291	1
3823	706	2014-11-02	2015-02-15 00:00:00	291	1
3824	714	2014-12-02	2015-02-15 00:00:00	291	1
3825	730	2015-01-02	2015-02-15 00:00:00	291	1
3826	831	2014-10-02	2015-02-15 00:00:00	292	1
3827	837	2014-11-02	2015-02-15 00:00:00	292	1
3828	845	2014-12-02	2015-02-15 00:00:00	292	1
3829	854	2015-01-02	2015-02-15 00:00:00	292	1
3830	1086	2014-10-02	2015-02-15 00:00:00	293	1
3831	1092	2014-11-02	2015-02-15 00:00:00	293	1
3832	1097	2014-12-02	2015-02-15 00:00:00	293	1
3833	1105	2015-01-02	2015-02-15 00:00:00	293	1
3834	0	2014-10-02	2015-02-15 00:00:00	294	1
3835	0	2014-11-02	2015-02-15 00:00:00	294	1
3836	0	2014-12-02	2015-02-15 00:00:00	294	1
3837	0	2015-01-02	2015-02-15 00:00:00	294	1
3838	318	2014-10-02	2015-02-15 00:00:00	295	1
3839	320	2014-11-02	2015-02-15 00:00:00	295	1
3840	322	2014-12-02	2015-02-15 00:00:00	295	1
3841	332	2015-01-02	2015-02-15 00:00:00	295	1
3842	0	2014-10-02	2015-02-15 00:00:00	296	1
3843	0	2014-11-02	2015-02-15 00:00:00	296	1
3844	0	2014-12-02	2015-02-15 00:00:00	296	1
3845	0	2015-01-02	2015-02-15 00:00:00	296	1
3846	0	2014-10-02	2015-02-15 00:00:00	297	1
3847	0	2014-11-02	2015-02-15 00:00:00	297	1
3848	0	2014-12-02	2015-02-15 00:00:00	297	1
3849	0	2015-01-02	2015-02-15 00:00:00	297	1
3850	0	2014-10-02	2015-02-15 00:00:00	298	1
3851	0	2014-11-02	2015-02-15 00:00:00	298	1
3852	0	2014-12-02	2015-02-15 00:00:00	298	1
3853	0	2015-01-02	2015-02-15 00:00:00	298	1
3854	0	2014-10-02	2015-02-15 00:00:00	299	1
3855	0	2014-11-02	2015-02-15 00:00:00	299	1
3856	0	2014-12-02	2015-02-15 00:00:00	299	1
3857	0	2015-01-02	2015-02-15 00:00:00	299	1
3858	0	2014-10-02	2015-02-15 00:00:00	300	1
3859	0	2014-11-02	2015-02-15 00:00:00	300	1
3860	0	2014-12-02	2015-02-15 00:00:00	300	1
3861	0	2015-01-02	2015-02-15 00:00:00	300	1
3862	0	2014-10-02	2015-02-15 00:00:00	301	1
3863	0	2014-11-02	2015-02-15 00:00:00	301	1
3864	0	2014-12-02	2015-02-15 00:00:00	301	1
3865	0	2015-01-02	2015-02-15 00:00:00	301	1
3866	0	2014-10-02	2015-02-15 00:00:00	302	1
3867	0	2014-11-02	2015-02-15 00:00:00	302	1
3868	0	2014-12-02	2015-02-15 00:00:00	302	1
3869	0	2015-01-02	2015-02-15 00:00:00	302	1
3870	0	2014-10-02	2015-02-15 00:00:00	303	1
3871	0	2014-11-02	2015-02-15 00:00:00	303	1
3872	0	2014-12-02	2015-02-15 00:00:00	303	1
3873	0	2015-01-02	2015-02-15 00:00:00	303	1
3874	0	2014-10-02	2015-02-15 00:00:00	304	1
3875	0	2014-11-02	2015-02-15 00:00:00	304	1
3876	0	2014-12-02	2015-02-15 00:00:00	304	1
3877	0	2015-01-02	2015-02-15 00:00:00	304	1
3878	0	2014-10-02	2015-02-15 00:00:00	305	1
3879	0	2014-11-02	2015-02-15 00:00:00	305	1
3880	0	2014-12-02	2015-02-15 00:00:00	305	1
3881	0	2015-01-02	2015-02-15 00:00:00	305	1
3882	0	2014-10-02	2015-02-15 00:00:00	306	1
3883	0	2014-11-02	2015-02-15 00:00:00	306	1
3884	0	2014-12-02	2015-02-15 00:00:00	306	1
3885	0	2015-01-02	2015-02-15 00:00:00	306	1
3886	0	2014-10-02	2015-02-15 00:00:00	307	1
3887	0	2014-11-02	2015-02-15 00:00:00	307	1
3888	0	2014-12-02	2015-02-15 00:00:00	307	1
3889	0	2015-01-02	2015-02-15 00:00:00	307	1
3890	0	2014-10-02	2015-02-15 00:00:00	308	1
3891	0	2014-11-02	2015-02-15 00:00:00	308	1
3892	0	2014-12-02	2015-02-15 00:00:00	308	1
3893	0	2015-01-02	2015-02-15 00:00:00	308	1
3894	260	2014-10-02	2015-02-15 00:00:00	309	1
3895	267	2014-11-02	2015-02-15 00:00:00	309	1
3896	277	2014-12-02	2015-02-15 00:00:00	309	1
3897	288	2015-01-02	2015-02-15 00:00:00	309	1
3898	24	2014-10-02	2015-02-15 00:00:00	310	1
3899	25	2014-11-02	2015-02-15 00:00:00	310	1
3900	26	2014-12-02	2015-02-15 00:00:00	310	1
3901	28	2015-01-02	2015-02-15 00:00:00	310	1
3902	192	2014-10-02	2015-02-15 00:00:00	311	1
3903	192	2014-11-02	2015-02-15 00:00:00	311	1
3904	192	2014-12-02	2015-02-15 00:00:00	311	1
3905	193	2015-01-02	2015-02-15 00:00:00	311	1
3906	983	2014-10-02	2015-02-15 00:00:00	312	1
3907	987	2014-11-02	2015-02-15 00:00:00	312	1
3908	993	2014-12-02	2015-02-15 00:00:00	312	1
3909	1000	2015-01-02	2015-02-15 00:00:00	312	1
3910	1618	2014-10-02	2015-02-15 00:00:00	313	1
3911	1629	2014-11-02	2015-02-15 00:00:00	313	1
3912	1641	2014-12-02	2015-02-15 00:00:00	313	1
3913	1654	2015-01-02	2015-02-15 00:00:00	313	1
3914	903	2014-10-02	2015-02-15 00:00:00	314	1
3915	909	2014-11-02	2015-02-15 00:00:00	314	1
3916	916	2014-12-02	2015-02-15 00:00:00	314	1
3917	925	2015-01-02	2015-02-15 00:00:00	314	1
3918	849	2014-10-02	2015-02-15 00:00:00	315	1
3919	855	2014-11-02	2015-02-15 00:00:00	315	1
3920	860	2014-12-02	2015-02-15 00:00:00	315	1
3921	870	2015-01-02	2015-02-15 00:00:00	315	1
3922	0	2014-10-02	2015-02-15 00:00:00	316	1
3923	0	2014-11-02	2015-02-15 00:00:00	316	1
3924	0	2014-12-02	2015-02-15 00:00:00	316	1
3925	0	2015-01-02	2015-02-15 00:00:00	316	1
3926	700	2014-10-02	2015-02-15 00:00:00	317	1
3927	700	2014-11-02	2015-02-15 00:00:00	317	1
3928	700	2014-12-02	2015-02-15 00:00:00	317	1
3929	701	2015-01-02	2015-02-15 00:00:00	317	1
3930	741	2014-10-02	2015-02-15 00:00:00	318	1
3931	743	2014-11-02	2015-02-15 00:00:00	318	1
3932	745	2014-12-02	2015-02-15 00:00:00	318	1
3933	745	2015-01-02	2015-02-15 00:00:00	318	1
3934	0	2014-10-02	2015-02-15 00:00:00	319	1
3935	0	2014-11-02	2015-02-15 00:00:00	319	1
3936	0	2014-12-02	2015-02-15 00:00:00	319	1
3937	0	2015-01-02	2015-02-15 00:00:00	319	1
3938	1432	2014-10-02	2015-02-15 00:00:00	320	1
3939	1443	2014-11-02	2015-02-15 00:00:00	320	1
3940	1451	2014-12-02	2015-02-15 00:00:00	320	1
3941	1460	2015-01-02	2015-02-15 00:00:00	320	1
3942	1103	2014-10-02	2015-02-15 00:00:00	321	1
3943	1104	2014-11-02	2015-02-15 00:00:00	321	1
3944	1105	2014-12-02	2015-02-15 00:00:00	321	1
3945	1107	2015-01-02	2015-02-15 00:00:00	321	1
3946	1307	2014-10-02	2015-02-15 00:00:00	322	1
3947	1312	2014-11-02	2015-02-15 00:00:00	322	1
3948	1317	2014-12-02	2015-02-15 00:00:00	322	1
3949	1326	2015-01-02	2015-02-15 00:00:00	322	1
3950	470	2014-10-02	2015-02-15 00:00:00	323	1
3951	477	2014-11-02	2015-02-15 00:00:00	323	1
3952	478	2014-12-02	2015-02-15 00:00:00	323	1
3953	481	2015-01-02	2015-02-15 00:00:00	323	1
3954	743	2014-10-02	2015-02-15 00:00:00	324	1
3955	746	2014-11-02	2015-02-15 00:00:00	324	1
3956	753	2014-12-02	2015-02-15 00:00:00	324	1
3957	759	2015-01-02	2015-02-15 00:00:00	324	1
3958	1134	2014-10-02	2015-02-15 00:00:00	325	1
3959	1146	2014-11-02	2015-02-15 00:00:00	325	1
3960	1155	2014-12-02	2015-02-15 00:00:00	325	1
3961	1166	2015-01-02	2015-02-15 00:00:00	325	1
3962	1388	2014-10-02	2015-02-15 00:00:00	326	1
3963	1397	2014-11-02	2015-02-15 00:00:00	326	1
3964	1408	2014-12-02	2015-02-15 00:00:00	326	1
3965	1418	2015-01-02	2015-02-15 00:00:00	326	1
3966	65	2014-10-02	2015-02-15 00:00:00	327	1
3967	71	2014-11-02	2015-02-15 00:00:00	327	1
3968	82	2014-12-02	2015-02-15 00:00:00	327	1
3969	90	2015-01-02	2015-02-15 00:00:00	327	1
3970	777	2014-10-02	2015-02-15 00:00:00	328	1
3971	786	2014-11-02	2015-02-15 00:00:00	328	1
3972	798	2014-12-02	2015-02-15 00:00:00	328	1
3973	805	2015-01-02	2015-02-15 00:00:00	328	1
3974	964	2014-10-02	2015-02-15 00:00:00	329	1
3975	965	2014-11-02	2015-02-15 00:00:00	329	1
3976	967	2014-12-02	2015-02-15 00:00:00	329	1
3977	967	2015-01-02	2015-02-15 00:00:00	329	1
3978	462	2014-10-02	2015-02-15 00:00:00	330	1
3979	472	2014-11-02	2015-02-15 00:00:00	330	1
3980	482	2014-12-02	2015-02-15 00:00:00	330	1
3981	496	2015-01-02	2015-02-15 00:00:00	330	1
3982	1022	2014-10-02	2015-02-15 00:00:00	331	1
3983	1034	2014-11-02	2015-02-15 00:00:00	331	1
3984	1045	2014-12-02	2015-02-15 00:00:00	331	1
3985	1058	2015-01-02	2015-02-15 00:00:00	331	1
3986	523	2014-10-02	2015-02-15 00:00:00	332	1
3987	529	2014-11-02	2015-02-15 00:00:00	332	1
3988	530	2014-12-02	2015-02-15 00:00:00	332	1
3989	530	2015-01-02	2015-02-15 00:00:00	332	1
3990	796	2014-10-02	2015-02-15 00:00:00	333	1
3991	799	2014-11-02	2015-02-15 00:00:00	333	1
3992	802	2014-12-02	2015-02-15 00:00:00	333	1
3993	807	2015-01-02	2015-02-15 00:00:00	333	1
3994	1058	2014-10-02	2015-02-15 00:00:00	334	1
3995	1065	2014-11-02	2015-02-15 00:00:00	334	1
3996	1073	2014-12-02	2015-02-15 00:00:00	334	1
3997	1082	2015-01-02	2015-02-15 00:00:00	334	1
3998	1124	2014-10-02	2015-02-15 00:00:00	335	1
3999	1136	2014-11-02	2015-02-15 00:00:00	335	1
4000	1147	2014-12-02	2015-02-15 00:00:00	335	1
4001	1158	2015-01-02	2015-02-15 00:00:00	335	1
4002	281	2014-10-02	2015-02-15 00:00:00	336	1
4003	290	2014-11-02	2015-02-15 00:00:00	336	1
4004	295	2014-12-02	2015-02-15 00:00:00	336	1
4005	302	2015-01-02	2015-02-15 00:00:00	336	1
4006	1006	2014-10-02	2015-02-15 00:00:00	337	1
4007	1009	2014-11-02	2015-02-15 00:00:00	337	1
4008	1013	2014-12-02	2015-02-15 00:00:00	337	1
4009	1014	2015-01-02	2015-02-15 00:00:00	337	1
4010	0	2014-10-02	2015-02-15 00:00:00	338	1
4011	0	2014-11-02	2015-02-15 00:00:00	338	1
4012	0	2014-12-02	2015-02-15 00:00:00	338	1
4013	0	2015-01-02	2015-02-15 00:00:00	338	1
4014	0	2014-10-02	2015-02-15 00:00:00	339	1
4015	0	2014-11-02	2015-02-15 00:00:00	339	1
4016	0	2014-12-02	2015-02-15 00:00:00	339	1
4017	0	2015-01-02	2015-02-15 00:00:00	339	1
4018	1594	2014-10-02	2015-02-15 00:00:00	340	1
4019	1604	2014-11-02	2015-02-15 00:00:00	340	1
4020	1612	2014-12-02	2015-02-15 00:00:00	340	1
4021	1625	2015-01-02	2015-02-15 00:00:00	340	1
4022	1139	2014-10-02	2015-02-15 00:00:00	341	1
4023	1146	2014-11-02	2015-02-15 00:00:00	341	1
4024	1154	2014-12-02	2015-02-15 00:00:00	341	1
4025	1159	2015-01-02	2015-02-15 00:00:00	341	1
4026	571	2014-10-02	2015-02-15 00:00:00	342	1
4027	573	2014-11-02	2015-02-15 00:00:00	342	1
4028	576	2014-12-02	2015-02-15 00:00:00	342	1
4029	581	2015-01-02	2015-02-15 00:00:00	342	1
4030	439	2014-10-02	2015-02-15 00:00:00	343	1
4031	441	2014-11-02	2015-02-15 00:00:00	343	1
4032	444	2014-12-02	2015-02-15 00:00:00	343	1
4033	452	2015-01-02	2015-02-15 00:00:00	343	1
4034	1041	2014-10-02	2015-02-15 00:00:00	344	1
4035	1044	2014-11-02	2015-02-15 00:00:00	344	1
4036	1048	2014-12-02	2015-02-15 00:00:00	344	1
4037	1063	2015-01-02	2015-02-15 00:00:00	344	1
4038	464	2014-10-02	2015-02-15 00:00:00	345	1
4039	469	2014-11-02	2015-02-15 00:00:00	345	1
4040	472	2014-12-02	2015-02-15 00:00:00	345	1
4041	476	2015-01-02	2015-02-15 00:00:00	345	1
4042	754	2014-10-02	2015-02-15 00:00:00	346	1
4043	757	2014-11-02	2015-02-15 00:00:00	346	1
4044	760	2014-12-02	2015-02-15 00:00:00	346	1
4045	767	2015-01-02	2015-02-15 00:00:00	346	1
4046	565	2014-10-02	2015-02-15 00:00:00	347	1
4047	578	2014-11-02	2015-02-15 00:00:00	347	1
4048	589	2014-12-02	2015-02-15 00:00:00	347	1
4049	599	2015-01-02	2015-02-15 00:00:00	347	1
4050	980	2014-10-02	2015-02-15 00:00:00	348	1
4051	986	2014-11-02	2015-02-15 00:00:00	348	1
4052	996	2014-12-02	2015-02-15 00:00:00	348	1
4053	1012	2015-01-02	2015-02-15 00:00:00	348	1
4054	379	2014-10-02	2015-02-15 00:00:00	349	1
4055	379	2014-11-02	2015-02-15 00:00:00	349	1
4056	380	2014-12-02	2015-02-15 00:00:00	349	1
4057	380	2015-01-02	2015-02-15 00:00:00	349	1
4058	870	2014-10-02	2015-02-15 00:00:00	350	1
4059	878	2014-11-02	2015-02-15 00:00:00	350	1
4060	886	2014-12-02	2015-02-15 00:00:00	350	1
4061	894	2015-01-02	2015-02-15 00:00:00	350	1
4062	121	2014-10-02	2015-02-15 00:00:00	351	1
4063	125	2014-11-02	2015-02-15 00:00:00	351	1
4064	126	2014-12-02	2015-02-15 00:00:00	351	1
4065	129	2015-01-02	2015-02-15 00:00:00	351	1
4066	0	2014-10-02	2015-02-15 00:00:00	352	1
4067	0	2014-11-02	2015-02-15 00:00:00	352	1
4068	0	2014-12-02	2015-02-15 00:00:00	352	1
4069	0	2015-01-02	2015-02-15 00:00:00	352	1
4070	1616	2014-10-02	2015-02-15 00:00:00	353	1
4071	1626	2014-11-02	2015-02-15 00:00:00	353	1
4072	1637	2014-12-02	2015-02-15 00:00:00	353	1
4073	1651	2015-01-02	2015-02-15 00:00:00	353	1
4074	424	2014-10-02	2015-02-15 00:00:00	354	1
4075	438	2014-11-02	2015-02-15 00:00:00	354	1
4076	453	2014-12-02	2015-02-15 00:00:00	354	1
4077	470	2015-01-02	2015-02-15 00:00:00	354	1
4078	702	2014-10-02	2015-02-15 00:00:00	355	1
4079	703	2014-11-02	2015-02-15 00:00:00	355	1
4080	706	2014-12-02	2015-02-15 00:00:00	355	1
4081	713	2015-01-02	2015-02-15 00:00:00	355	1
4082	3015	2014-10-02	2015-02-15 00:00:00	356	1
4083	3055	2014-11-02	2015-02-15 00:00:00	356	1
4084	3129	2014-12-02	2015-02-15 00:00:00	356	1
4085	3211	2015-01-02	2015-02-15 00:00:00	356	1
4086	574	2014-10-02	2015-02-15 00:00:00	357	1
4087	579	2014-11-02	2015-02-15 00:00:00	357	1
4088	582	2014-12-02	2015-02-15 00:00:00	357	1
4089	589	2015-01-02	2015-02-15 00:00:00	357	1
4090	438	2014-10-02	2015-02-15 00:00:00	358	1
4091	438	2014-11-02	2015-02-15 00:00:00	358	1
4092	439	2014-12-02	2015-02-15 00:00:00	358	1
4093	439	2015-01-02	2015-02-15 00:00:00	358	1
4094	0	2014-10-02	2015-02-15 00:00:00	359	1
4095	0	2014-11-02	2015-02-15 00:00:00	359	1
4096	0	2014-12-02	2015-02-15 00:00:00	359	1
4097	0	2015-01-02	2015-02-15 00:00:00	359	1
4098	31	2014-10-02	2015-02-15 00:00:00	360	1
4099	31	2014-11-02	2015-02-15 00:00:00	360	1
4100	31	2014-12-02	2015-02-15 00:00:00	360	1
4101	31	2015-01-02	2015-02-15 00:00:00	360	1
4102	306	2014-10-02	2015-02-15 00:00:00	361	1
4103	322	2014-11-02	2015-02-15 00:00:00	361	1
4104	344	2014-12-02	2015-02-15 00:00:00	361	1
4105	367	2015-01-02	2015-02-15 00:00:00	361	1
4106	219	2014-10-02	2015-02-15 00:00:00	362	1
4107	231	2014-11-02	2015-02-15 00:00:00	362	1
4108	244	2014-12-02	2015-02-15 00:00:00	362	1
4109	257	2015-01-02	2015-02-15 00:00:00	362	1
4110	200	2014-10-02	2015-02-15 00:00:00	363	1
4111	214	2014-11-02	2015-02-15 00:00:00	363	1
4112	228	2014-12-02	2015-02-15 00:00:00	363	1
4113	245	2015-01-02	2015-02-15 00:00:00	363	1
4114	576	2014-10-02	2015-02-15 00:00:00	364	1
4115	576	2014-11-02	2015-02-15 00:00:00	364	1
4116	576	2014-12-02	2015-02-15 00:00:00	364	1
4117	596	2015-01-02	2015-02-15 00:00:00	364	1
4118	487	2014-10-02	2015-02-15 00:00:00	365	1
4119	491	2014-11-02	2015-02-15 00:00:00	365	1
4120	496	2014-12-02	2015-02-15 00:00:00	365	1
4121	501	2015-01-02	2015-02-15 00:00:00	365	1
4122	52	2014-10-02	2015-02-15 00:00:00	366	1
4123	54	2014-11-02	2015-02-15 00:00:00	366	1
4124	61	2014-12-02	2015-02-15 00:00:00	366	1
4125	68	2015-01-02	2015-02-15 00:00:00	366	1
4126	138	2014-10-02	2015-02-15 00:00:00	367	1
4127	148	2014-11-02	2015-02-15 00:00:00	367	1
4128	156	2014-12-02	2015-02-15 00:00:00	367	1
4129	166	2015-01-02	2015-02-15 00:00:00	367	1
4130	224	2014-10-02	2015-02-15 00:00:00	368	1
4131	236	2014-11-02	2015-02-15 00:00:00	368	1
4132	248	2014-12-02	2015-02-15 00:00:00	368	1
4133	261	2015-01-02	2015-02-15 00:00:00	368	1
4134	165	2014-10-02	2015-02-15 00:00:00	369	1
4135	172	2014-11-02	2015-02-15 00:00:00	369	1
4136	180	2014-12-02	2015-02-15 00:00:00	369	1
4137	192	2015-01-02	2015-02-15 00:00:00	369	1
4138	217	2014-10-02	2015-02-15 00:00:00	370	1
4139	231	2014-11-02	2015-02-15 00:00:00	370	1
4140	246	2014-12-02	2015-02-15 00:00:00	370	1
4141	266	2015-01-02	2015-02-15 00:00:00	370	1
4142	204	2014-10-02	2015-02-15 00:00:00	371	1
4143	217	2014-11-02	2015-02-15 00:00:00	371	1
4144	229	2014-12-02	2015-02-15 00:00:00	371	1
4145	242	2015-01-02	2015-02-15 00:00:00	371	1
4146	192	2014-10-02	2015-02-15 00:00:00	372	1
4147	204	2014-11-02	2015-02-15 00:00:00	372	1
4148	217	2014-12-02	2015-02-15 00:00:00	372	1
4149	234	2015-01-02	2015-02-15 00:00:00	372	1
4150	486	2014-10-02	2015-02-15 00:00:00	373	1
4151	509	2014-11-02	2015-02-15 00:00:00	373	1
4152	538	2014-12-02	2015-02-15 00:00:00	373	1
4153	568	2015-01-02	2015-02-15 00:00:00	373	1
4154	157	2014-10-02	2015-02-15 00:00:00	374	1
4155	169	2014-11-02	2015-02-15 00:00:00	374	1
4156	182	2014-12-02	2015-02-15 00:00:00	374	1
4157	295	2015-01-02	2015-02-15 00:00:00	374	1
4158	894	2014-10-02	2015-02-15 00:00:00	375	1
4159	903	2014-11-02	2015-02-15 00:00:00	375	1
4160	915	2014-12-02	2015-02-15 00:00:00	375	1
4161	928	2015-01-02	2015-02-15 00:00:00	375	1
4162	203	2014-10-02	2015-02-15 00:00:00	377	1
4163	217	2014-11-02	2015-02-15 00:00:00	377	1
4164	238	2014-12-02	2015-02-15 00:00:00	377	1
4165	265	2015-01-02	2015-02-15 00:00:00	377	1
4166	284	2014-10-02	2015-02-15 00:00:00	378	1
4167	302	2014-11-02	2015-02-15 00:00:00	378	1
4168	324	2014-12-02	2015-02-15 00:00:00	378	1
4169	345	2015-01-02	2015-02-15 00:00:00	378	1
4170	390	2014-10-02	2015-02-15 00:00:00	379	1
4171	413	2014-11-02	2015-02-15 00:00:00	379	1
4172	444	2014-12-02	2015-02-15 00:00:00	379	1
4173	470	2015-01-02	2015-02-15 00:00:00	379	1
4174	86	2014-10-02	2015-02-15 00:00:00	380	1
4175	98	2014-11-02	2015-02-15 00:00:00	380	1
4176	101	2014-12-02	2015-02-15 00:00:00	380	1
4177	102	2015-01-02	2015-02-15 00:00:00	380	1
4178	381	2014-10-02	2015-02-15 00:00:00	381	1
4179	404	2014-11-02	2015-02-15 00:00:00	381	1
4180	433	2014-12-02	2015-02-15 00:00:00	381	1
4181	460	2015-01-02	2015-02-15 00:00:00	381	1
4182	417	2014-10-02	2015-02-15 00:00:00	382	1
4183	434	2014-11-02	2015-02-15 00:00:00	382	1
4184	459	2014-12-02	2015-02-15 00:00:00	382	1
4185	486	2015-01-02	2015-02-15 00:00:00	382	1
4186	303	2014-10-02	2015-02-15 00:00:00	383	1
4187	320	2014-11-02	2015-02-15 00:00:00	383	1
4188	339	2014-12-02	2015-02-15 00:00:00	383	1
4189	364	2015-01-02	2015-02-15 00:00:00	383	1
4190	117	2014-10-02	2015-02-15 00:00:00	384	1
4191	123	2014-11-02	2015-02-15 00:00:00	384	1
4192	133	2014-12-02	2015-02-15 00:00:00	384	1
4193	142	2015-01-02	2015-02-15 00:00:00	384	1
4194	326	2014-10-02	2015-02-15 00:00:00	385	1
4195	347	2014-11-02	2015-02-15 00:00:00	385	1
4196	367	2014-12-02	2015-02-15 00:00:00	385	1
4197	394	2015-01-02	2015-02-15 00:00:00	385	1
4198	219	2014-10-02	2015-02-15 00:00:00	386	1
4199	230	2014-11-02	2015-02-15 00:00:00	386	1
4200	242	2014-12-02	2015-02-15 00:00:00	386	1
4201	254	2015-01-02	2015-02-15 00:00:00	386	1
4202	175	2014-10-02	2015-02-15 00:00:00	387	1
4203	190	2014-11-02	2015-02-15 00:00:00	387	1
4204	202	2014-12-02	2015-02-15 00:00:00	387	1
4205	225	2015-01-02	2015-02-15 00:00:00	387	1
4206	28	2014-10-02	2015-02-15 00:00:00	388	1
4207	31	2014-11-02	2015-02-15 00:00:00	388	1
4208	34	2014-12-02	2015-02-15 00:00:00	388	1
4209	37	2015-01-02	2015-02-15 00:00:00	388	1
4210	340	2014-10-02	2015-02-15 00:00:00	389	1
4211	365	2014-11-02	2015-02-15 00:00:00	389	1
4212	391	2014-12-02	2015-02-15 00:00:00	389	1
4213	421	2015-01-02	2015-02-15 00:00:00	389	1
4214	706	2014-10-02	2015-02-15 00:00:00	390	1
4215	713	2014-11-02	2015-02-15 00:00:00	390	1
4216	723	2014-12-02	2015-02-15 00:00:00	390	1
4217	734	2015-01-02	2015-02-15 00:00:00	390	1
4218	105	2014-10-02	2015-02-15 00:00:00	391	1
4219	117	2014-11-02	2015-02-15 00:00:00	391	1
4220	132	2014-12-02	2015-02-15 00:00:00	391	1
4221	147	2015-01-02	2015-02-15 00:00:00	391	1
4222	369	2014-10-02	2015-02-15 00:00:00	392	1
4223	382	2014-11-02	2015-02-15 00:00:00	392	1
4224	397	2014-12-02	2015-02-15 00:00:00	392	1
4225	415	2015-01-02	2015-02-15 00:00:00	392	1
4226	354	2014-10-02	2015-02-15 00:00:00	393	1
4227	366	2014-11-02	2015-02-15 00:00:00	393	1
4228	382	2014-12-02	2015-02-15 00:00:00	393	1
4229	396	2015-01-02	2015-02-15 00:00:00	393	1
4230	305	2014-10-02	2015-02-15 00:00:00	394	1
4231	318	2014-11-02	2015-02-15 00:00:00	394	1
4232	335	2014-12-02	2015-02-15 00:00:00	394	1
4233	353	2015-01-02	2015-02-15 00:00:00	394	1
4234	270	2014-10-02	2015-02-15 00:00:00	395	1
4235	279	2014-11-02	2015-02-15 00:00:00	395	1
4236	287	2014-12-02	2015-02-15 00:00:00	395	1
4237	296	2015-01-02	2015-02-15 00:00:00	395	1
4238	501	2014-10-02	2015-02-15 00:00:00	396	1
4239	515	2014-11-02	2015-02-15 00:00:00	396	1
4240	538	2014-12-02	2015-02-15 00:00:00	396	1
4241	557	2015-01-02	2015-02-15 00:00:00	396	1
4242	150	2014-10-02	2015-02-15 00:00:00	397	1
4243	159	2014-11-02	2015-02-15 00:00:00	397	1
4244	169	2014-12-02	2015-02-15 00:00:00	397	1
4245	183	2015-01-02	2015-02-15 00:00:00	397	1
4246	187	2014-10-02	2015-02-15 00:00:00	398	1
4247	202	2014-11-02	2015-02-15 00:00:00	398	1
4248	217	2014-12-02	2015-02-15 00:00:00	398	1
4249	235	2015-01-02	2015-02-15 00:00:00	398	1
4250	291	2014-10-02	2015-02-15 00:00:00	399	1
4251	303	2014-11-02	2015-02-15 00:00:00	399	1
4252	317	2014-12-02	2015-02-15 00:00:00	399	1
4253	332	2015-01-02	2015-02-15 00:00:00	399	1
4254	217	2014-10-02	2015-02-15 00:00:00	400	1
4255	225	2014-11-02	2015-02-15 00:00:00	400	1
4256	233	2014-12-02	2015-02-15 00:00:00	400	1
4257	243	2015-01-02	2015-02-15 00:00:00	400	1
4258	203	2014-10-02	2015-02-15 00:00:00	401	1
4259	218	2014-11-02	2015-02-15 00:00:00	401	1
4260	240	2014-12-02	2015-02-15 00:00:00	401	1
4261	264	2015-01-02	2015-02-15 00:00:00	401	1
4262	200	2014-10-02	2015-02-15 00:00:00	402	1
4263	213	2014-11-02	2015-02-15 00:00:00	402	1
4264	229	2014-12-02	2015-02-15 00:00:00	402	1
4265	247	2015-01-02	2015-02-15 00:00:00	402	1
4266	545	2014-10-02	2015-02-15 00:00:00	403	1
4267	574	2014-11-02	2015-02-15 00:00:00	403	1
4268	610	2014-12-02	2015-02-15 00:00:00	403	1
4269	643	2015-01-02	2015-02-15 00:00:00	403	1
4270	365	2014-10-02	2015-02-15 00:00:00	404	1
4271	367	2014-11-02	2015-02-15 00:00:00	404	1
4272	369	2014-12-02	2015-02-15 00:00:00	404	1
4273	372	2015-01-02	2015-02-15 00:00:00	404	1
4274	192	2014-10-02	2015-02-15 00:00:00	405	1
4275	204	2014-11-02	2015-02-15 00:00:00	405	1
4276	220	2014-12-02	2015-02-15 00:00:00	405	1
4277	234	2015-01-02	2015-02-15 00:00:00	405	1
4278	210	2014-10-02	2015-02-15 00:00:00	406	1
4279	225	2014-11-02	2015-02-15 00:00:00	406	1
4280	239	2014-12-02	2015-02-15 00:00:00	406	1
4281	256	2015-01-02	2015-02-15 00:00:00	406	1
4282	188	2014-10-02	2015-02-15 00:00:00	407	1
4283	201	2014-11-02	2015-02-15 00:00:00	407	1
4284	215	2014-12-02	2015-02-15 00:00:00	407	1
4285	232	2015-01-02	2015-02-15 00:00:00	407	1
4286	71	2014-10-02	2015-02-15 00:00:00	408	1
4287	77	2014-11-02	2015-02-15 00:00:00	408	1
4288	88	2014-12-02	2015-02-15 00:00:00	408	1
4289	102	2015-01-02	2015-02-15 00:00:00	408	1
4290	139	2014-10-02	2015-02-15 00:00:00	409	1
4291	145	2014-11-02	2015-02-15 00:00:00	409	1
4292	156	2014-12-02	2015-02-15 00:00:00	409	1
4293	167	2015-01-02	2015-02-15 00:00:00	409	1
4294	258	2014-10-02	2015-02-15 00:00:00	410	1
4295	271	2014-11-02	2015-02-15 00:00:00	410	1
4296	285	2014-12-02	2015-02-15 00:00:00	410	1
4297	302	2015-01-02	2015-02-15 00:00:00	410	1
4298	206	2014-10-02	2015-02-15 00:00:00	411	1
4299	219	2014-11-02	2015-02-15 00:00:00	411	1
4300	236	2014-12-02	2015-02-15 00:00:00	411	1
4301	258	2015-01-02	2015-02-15 00:00:00	411	1
4302	301	2014-10-02	2015-02-15 00:00:00	412	1
4303	314	2014-11-02	2015-02-15 00:00:00	412	1
4304	327	2014-12-02	2015-02-15 00:00:00	412	1
4305	342	2015-01-02	2015-02-15 00:00:00	412	1
4306	577	2014-10-02	2015-02-15 00:00:00	413	1
4307	607	2014-11-02	2015-02-15 00:00:00	413	1
4308	641	2014-12-02	2015-02-15 00:00:00	413	1
4309	676	2015-01-02	2015-02-15 00:00:00	413	1
4310	147	2014-10-02	2015-02-15 00:00:00	414	1
4311	158	2014-11-02	2015-02-15 00:00:00	414	1
4312	169	2014-12-02	2015-02-15 00:00:00	414	1
4313	183	2015-01-02	2015-02-15 00:00:00	414	1
4314	432	2014-10-02	2015-02-15 00:00:00	415	1
4315	454	2014-11-02	2015-02-15 00:00:00	415	1
4316	472	2014-12-02	2015-02-15 00:00:00	415	1
4317	488	2015-01-02	2015-02-15 00:00:00	415	1
4318	200	2014-10-02	2015-02-15 00:00:00	416	1
4319	215	2014-11-02	2015-02-15 00:00:00	416	1
4320	229	2014-12-02	2015-02-15 00:00:00	416	1
4321	250	2015-01-02	2015-02-15 00:00:00	416	1
4322	133	2014-10-02	2015-02-15 00:00:00	417	1
4323	143	2014-11-02	2015-02-15 00:00:00	417	1
4324	152	2014-12-02	2015-02-15 00:00:00	417	1
4325	164	2015-01-02	2015-02-15 00:00:00	417	1
4326	105	2014-10-02	2015-02-15 00:00:00	418	1
4327	111	2014-11-02	2015-02-15 00:00:00	418	1
4328	118	2014-12-02	2015-02-15 00:00:00	418	1
4329	124	2015-01-02	2015-02-15 00:00:00	418	1
4330	415	2014-10-02	2015-02-15 00:00:00	419	1
4331	429	2014-11-02	2015-02-15 00:00:00	419	1
4332	447	2014-12-02	2015-02-15 00:00:00	419	1
4333	465	2015-01-02	2015-02-15 00:00:00	419	1
4334	120	2014-10-02	2015-02-15 00:00:00	420	1
4335	128	2014-11-02	2015-02-15 00:00:00	420	1
4336	134	2014-12-02	2015-02-15 00:00:00	420	1
4337	140	2015-01-02	2015-02-15 00:00:00	420	1
4338	0	2014-10-02	2015-02-15 00:00:00	421	1
4339	0	2014-11-02	2015-02-15 00:00:00	421	1
4340	0	2014-12-02	2015-02-15 00:00:00	421	1
4341	0	2015-01-02	2015-02-15 00:00:00	421	1
4342	0	2014-10-02	2015-02-15 00:00:00	422	1
4343	0	2014-11-02	2015-02-15 00:00:00	422	1
4344	0	2014-12-02	2015-02-15 00:00:00	422	1
4345	0	2015-01-02	2015-02-15 00:00:00	422	1
4346	0	2014-10-02	2015-02-15 00:00:00	423	1
4347	0	2014-11-02	2015-02-15 00:00:00	423	1
4348	0	2014-12-02	2015-02-15 00:00:00	423	1
4349	0	2015-01-02	2015-02-15 00:00:00	423	1
4350	604	2014-10-02	2015-02-15 00:00:00	424	1
4351	627	2014-11-02	2015-02-15 00:00:00	424	1
4352	644	2014-12-02	2015-02-15 00:00:00	424	1
4353	659	2015-01-02	2015-02-15 00:00:00	424	1
4354	0	2014-10-02	2015-02-15 00:00:00	425	1
4355	0	2014-11-02	2015-02-15 00:00:00	425	1
4356	0	2014-12-02	2015-02-15 00:00:00	425	1
4357	0	2015-01-02	2015-02-15 00:00:00	425	1
4358	1197	2014-10-02	2015-02-15 00:00:00	426	1
4359	1207	2014-11-02	2015-02-15 00:00:00	426	1
4360	1217	2014-12-02	2015-02-15 00:00:00	426	1
4361	1230	2015-01-02	2015-02-15 00:00:00	426	1
4362	395	2014-10-02	2015-02-15 00:00:00	427	1
4363	399	2014-11-02	2015-02-15 00:00:00	427	1
4364	407	2014-12-02	2015-02-15 00:00:00	427	1
4365	415	2015-01-02	2015-02-15 00:00:00	427	1
4366	1773	2014-10-02	2015-02-15 00:00:00	428	1
4367	1787	2014-11-02	2015-02-15 00:00:00	428	1
4368	1790	2014-12-02	2015-02-15 00:00:00	428	1
4369	1802	2015-01-02	2015-02-15 00:00:00	428	1
4370	0	2014-10-02	2015-02-15 00:00:00	429	1
4371	0	2014-11-02	2015-02-15 00:00:00	429	1
4372	0	2014-12-02	2015-02-15 00:00:00	429	1
4373	0	2015-01-02	2015-02-15 00:00:00	429	1
4374	611	2014-10-02	2015-02-15 00:00:00	430	1
4375	628	2014-11-02	2015-02-15 00:00:00	430	1
4376	649	2014-12-02	2015-02-15 00:00:00	430	1
4377	674	2015-01-02	2015-02-15 00:00:00	430	1
4378	0	2014-10-02	2015-02-15 00:00:00	431	1
4379	0	2014-11-02	2015-02-15 00:00:00	431	1
4380	0	2014-12-02	2015-02-15 00:00:00	431	1
4381	0	2015-01-02	2015-02-15 00:00:00	431	1
4382	0	2014-10-02	2015-02-15 00:00:00	432	1
4383	0	2014-11-02	2015-02-15 00:00:00	432	1
4384	0	2014-12-02	2015-02-15 00:00:00	432	1
4385	0	2015-01-02	2015-02-15 00:00:00	432	1
4386	1809	2014-10-02	2015-02-15 00:00:00	433	1
4387	1830	2014-11-02	2015-02-15 00:00:00	433	1
4388	1851	2014-12-02	2015-02-15 00:00:00	433	1
4389	1871	2015-01-02	2015-02-15 00:00:00	433	1
4390	1026	2014-10-02	2015-02-15 00:00:00	434	1
4391	1029	2014-11-02	2015-02-15 00:00:00	434	1
4392	1032	2014-12-02	2015-02-15 00:00:00	434	1
4393	1039	2015-01-02	2015-02-15 00:00:00	434	1
4394	508	2014-10-02	2015-02-15 00:00:00	435	1
4395	508	2014-11-02	2015-02-15 00:00:00	435	1
4396	511	2014-12-02	2015-02-15 00:00:00	435	1
4397	511	2015-01-02	2015-02-15 00:00:00	435	1
4398	0	2014-10-02	2015-02-15 00:00:00	436	1
4399	0	2014-11-02	2015-02-15 00:00:00	436	1
4400	0	2014-12-02	2015-02-15 00:00:00	436	1
4401	0	2015-01-02	2015-02-15 00:00:00	436	1
4402	0	2014-10-02	2015-02-15 00:00:00	437	1
4403	0	2014-11-02	2015-02-15 00:00:00	437	1
4404	0	2014-12-02	2015-02-15 00:00:00	437	1
4405	0	2015-01-02	2015-02-15 00:00:00	437	1
4406	2406	2014-10-02	2015-02-15 00:00:00	438	1
4407	2425	2014-11-02	2015-02-15 00:00:00	438	1
4408	2445	2014-12-02	2015-02-15 00:00:00	438	1
4409	2465	2015-01-02	2015-02-15 00:00:00	438	1
4410	279	2014-10-02	2015-02-15 00:00:00	439	1
4411	288	2014-11-02	2015-02-15 00:00:00	439	1
4412	302	2014-12-02	2015-02-15 00:00:00	439	1
4413	316	2015-01-02	2015-02-15 00:00:00	439	1
4414	0	2014-10-02	2015-02-15 00:00:00	440	1
4415	0	2014-11-02	2015-02-15 00:00:00	440	1
4416	0	2014-12-02	2015-02-15 00:00:00	440	1
4417	0	2015-01-02	2015-02-15 00:00:00	440	1
4418	401	2014-10-02	2015-02-15 00:00:00	441	1
4419	401	2014-11-02	2015-02-15 00:00:00	441	1
4420	401	2014-12-02	2015-02-15 00:00:00	441	1
4421	401	2015-01-02	2015-02-15 00:00:00	441	1
4422	2801	2014-10-02	2015-02-15 00:00:00	442	1
4423	2836	2014-11-02	2015-02-15 00:00:00	442	1
4424	2875	2014-12-02	2015-02-15 00:00:00	442	1
4425	2908	2015-01-02	2015-02-15 00:00:00	442	1
4426	0	2014-10-02	2015-02-15 00:00:00	443	1
4427	0	2014-11-02	2015-02-15 00:00:00	443	1
4428	0	2014-12-02	2015-02-15 00:00:00	443	1
4429	0	2015-01-02	2015-02-15 00:00:00	443	1
4430	915	2014-10-02	2015-02-15 00:00:00	444	1
4431	924	2014-11-02	2015-02-15 00:00:00	444	1
4432	935	2014-12-02	2015-02-15 00:00:00	444	1
4433	950	2015-01-02	2015-02-15 00:00:00	444	1
4434	317	2014-10-02	2015-02-15 00:00:00	445	1
4435	322	2014-11-02	2015-02-15 00:00:00	445	1
4436	331	2014-12-02	2015-02-15 00:00:00	445	1
4437	340	2015-01-02	2015-02-15 00:00:00	445	1
4438	0	2014-10-02	2015-02-15 00:00:00	446	1
4439	0	2014-11-02	2015-02-15 00:00:00	446	1
4440	0	2014-12-02	2015-02-15 00:00:00	446	1
4441	0	2015-01-02	2015-02-15 00:00:00	446	1
4442	1266	2014-10-02	2015-02-15 00:00:00	447	1
4443	1270	2014-11-02	2015-02-15 00:00:00	447	1
4444	1278	2014-12-02	2015-02-15 00:00:00	447	1
4445	1288	2015-01-02	2015-02-15 00:00:00	447	1
4446	1787	2014-10-02	2015-02-15 00:00:00	448	1
4447	1805	2014-11-02	2015-02-15 00:00:00	448	1
4448	1825	2014-12-02	2015-02-15 00:00:00	448	1
4449	1838	2015-01-02	2015-02-15 00:00:00	448	1
4450	0	2014-10-02	2015-02-15 00:00:00	449	1
4451	0	2014-11-02	2015-02-15 00:00:00	449	1
4452	0	2014-12-02	2015-02-15 00:00:00	449	1
4453	0	2015-01-02	2015-02-15 00:00:00	449	1
4454	0	2014-10-02	2015-02-15 00:00:00	450	1
4455	0	2014-11-02	2015-02-15 00:00:00	450	1
4456	0	2014-12-02	2015-02-15 00:00:00	450	1
4457	0	2015-01-02	2015-02-15 00:00:00	450	1
4458	242	2014-10-02	2015-02-15 00:00:00	451	1
4459	253	2014-11-02	2015-02-15 00:00:00	451	1
4460	266	2014-12-02	2015-02-15 00:00:00	451	1
4461	278	2015-01-02	2015-02-15 00:00:00	451	1
4462	1127	2014-10-02	2015-02-15 00:00:00	452	1
4463	1136	2014-11-02	2015-02-15 00:00:00	452	1
4464	1146	2014-12-02	2015-02-15 00:00:00	452	1
4465	1155	2015-01-02	2015-02-15 00:00:00	452	1
4466	2147	2014-10-02	2015-02-15 00:00:00	453	1
4467	2164	2014-11-02	2015-02-15 00:00:00	453	1
4468	2185	2014-12-02	2015-02-15 00:00:00	453	1
4469	2210	2015-01-02	2015-02-15 00:00:00	453	1
4470	1879	2014-10-02	2015-02-15 00:00:00	454	1
4471	1897	2014-11-02	2015-02-15 00:00:00	454	1
4472	1908	2014-12-02	2015-02-15 00:00:00	454	1
4473	1923	2015-01-02	2015-02-15 00:00:00	454	1
4474	0	2014-10-02	2015-02-15 00:00:00	455	1
4475	0	2014-11-02	2015-02-15 00:00:00	455	1
4476	0	2014-12-02	2015-02-15 00:00:00	455	1
4477	0	2015-01-02	2015-02-15 00:00:00	455	1
4478	617	2014-10-02	2015-02-15 00:00:00	456	1
4479	623	2014-11-02	2015-02-15 00:00:00	456	1
4480	632	2014-12-02	2015-02-15 00:00:00	456	1
4481	640	2015-01-02	2015-02-15 00:00:00	456	1
4482	1529	2014-10-02	2015-02-15 00:00:00	457	1
4483	1547	2014-11-02	2015-02-15 00:00:00	457	1
4484	1570	2014-12-02	2015-02-15 00:00:00	457	1
4485	1592	2015-01-02	2015-02-15 00:00:00	457	1
4486	1767	2014-10-02	2015-02-15 00:00:00	458	1
4487	1793	2014-11-02	2015-02-15 00:00:00	458	1
4488	1813	2014-12-02	2015-02-15 00:00:00	458	1
4489	1833	2015-01-02	2015-02-15 00:00:00	458	1
4490	425	2014-10-02	2015-02-15 00:00:00	459	1
4491	435	2014-11-02	2015-02-15 00:00:00	459	1
4492	440	2014-12-02	2015-02-15 00:00:00	459	1
4493	469	2015-01-02	2015-02-15 00:00:00	459	1
4494	161	2014-10-02	2015-02-15 00:00:00	460	1
4495	161	2014-11-02	2015-02-15 00:00:00	460	1
4496	162	2014-12-02	2015-02-15 00:00:00	460	1
4497	165	2015-01-02	2015-02-15 00:00:00	460	1
4498	1039	2014-10-02	2015-02-15 00:00:00	461	1
4499	1057	2014-11-02	2015-02-15 00:00:00	461	1
4500	1069	2014-12-02	2015-02-15 00:00:00	461	1
4501	1088	2015-01-02	2015-02-15 00:00:00	461	1
4502	0	2014-10-02	2015-02-15 00:00:00	462	1
4503	0	2014-11-02	2015-02-15 00:00:00	462	1
4504	0	2014-12-02	2015-02-15 00:00:00	462	1
4505	0	2015-01-02	2015-02-15 00:00:00	462	1
4506	560	2014-10-02	2015-02-15 00:00:00	463	1
4507	560	2014-11-02	2015-02-15 00:00:00	463	1
4508	567	2014-12-02	2015-02-15 00:00:00	463	1
4509	591	2015-01-02	2015-02-15 00:00:00	463	1
4510	0	2014-10-02	2015-02-15 00:00:00	464	1
4511	0	2014-11-02	2015-02-15 00:00:00	464	1
4512	0	2014-12-02	2015-02-15 00:00:00	464	1
4513	0	2015-01-02	2015-02-15 00:00:00	464	1
4514	0	2014-10-02	2015-02-15 00:00:00	465	1
4515	0	2014-11-02	2015-02-15 00:00:00	465	1
4516	0	2014-12-02	2015-02-15 00:00:00	465	1
4517	0	2015-01-02	2015-02-15 00:00:00	465	1
4518	266	2014-10-02	2015-02-15 00:00:00	466	1
4519	267	2014-11-02	2015-02-15 00:00:00	466	1
4520	272	2014-12-02	2015-02-15 00:00:00	466	1
4521	273	2015-01-02	2015-02-15 00:00:00	466	1
4522	0	2014-10-02	2015-02-15 00:00:00	467	1
4523	0	2014-11-02	2015-02-15 00:00:00	467	1
4524	0	2014-12-02	2015-02-15 00:00:00	467	1
4525	0	2015-01-02	2015-02-15 00:00:00	467	1
4526	53	2014-10-02	2015-02-15 00:00:00	468	1
4527	53	2014-11-02	2015-02-15 00:00:00	468	1
4528	53	2014-12-02	2015-02-15 00:00:00	468	1
4529	54	2015-01-02	2015-02-15 00:00:00	468	1
4530	168	2014-10-02	2015-02-15 00:00:00	469	1
4531	174	2014-11-02	2015-02-15 00:00:00	469	1
4532	182	2014-12-02	2015-02-15 00:00:00	469	1
4533	188	2015-01-02	2015-02-15 00:00:00	469	1
4534	0	2014-10-02	2015-02-15 00:00:00	470	1
4535	0	2014-11-02	2015-02-15 00:00:00	470	1
4536	0	2014-12-02	2015-02-15 00:00:00	470	1
4537	0	2015-01-02	2015-02-15 00:00:00	470	1
4538	672	2014-10-02	2015-02-15 00:00:00	471	1
4539	685	2014-11-02	2015-02-15 00:00:00	471	1
4540	697	2014-12-02	2015-02-15 00:00:00	471	1
4541	713	2015-01-02	2015-02-15 00:00:00	471	1
4542	740	2014-10-02	2015-02-15 00:00:00	472	1
4543	748	2014-11-02	2015-02-15 00:00:00	472	1
4544	757	2014-12-02	2015-02-15 00:00:00	472	1
4545	767	2015-01-02	2015-02-15 00:00:00	472	1
4546	1681	2014-10-02	2015-02-15 00:00:00	473	1
4547	1697	2014-11-02	2015-02-15 00:00:00	473	1
4548	1718	2014-12-02	2015-02-15 00:00:00	473	1
4549	1744	2015-01-02	2015-02-15 00:00:00	473	1
4550	134	2014-10-02	2015-02-15 00:00:00	474	1
4551	144	2014-11-02	2015-02-15 00:00:00	474	1
4552	155	2014-12-02	2015-02-15 00:00:00	474	1
4553	167	2015-01-02	2015-02-15 00:00:00	474	1
4554	80	2014-10-02	2015-02-15 00:00:00	475	1
4555	87	2014-11-02	2015-02-15 00:00:00	475	1
4556	99	2014-12-02	2015-02-15 00:00:00	475	1
4557	112	2015-01-02	2015-02-15 00:00:00	475	1
4558	191	2014-10-02	2015-02-15 00:00:00	476	1
4559	191	2014-11-02	2015-02-15 00:00:00	476	1
4560	191	2014-12-02	2015-02-15 00:00:00	476	1
4561	191	2015-01-02	2015-02-15 00:00:00	476	1
4562	570	2014-10-02	2015-02-15 00:00:00	477	1
4563	587	2014-11-02	2015-02-15 00:00:00	477	1
4564	609	2014-12-02	2015-02-15 00:00:00	477	1
4565	634	2015-01-02	2015-02-15 00:00:00	477	1
4566	590	2014-10-02	2015-02-15 00:00:00	478	1
4567	598	2014-11-02	2015-02-15 00:00:00	478	1
4568	607	2014-12-02	2015-02-15 00:00:00	478	1
4569	615	2015-01-02	2015-02-15 00:00:00	478	1
4570	1579	2014-10-02	2015-02-15 00:00:00	479	1
4571	1596	2014-11-02	2015-02-15 00:00:00	479	1
4572	1614	2014-12-02	2015-02-15 00:00:00	479	1
4573	1633	2015-01-02	2015-02-15 00:00:00	479	1
4574	1681	2014-10-02	2015-02-15 00:00:00	480	1
4575	1689	2014-11-02	2015-02-15 00:00:00	480	1
4576	1699	2014-12-02	2015-02-15 00:00:00	480	1
4577	1708	2015-01-02	2015-02-15 00:00:00	480	1
4578	789	2014-10-02	2015-02-15 00:00:00	481	1
4579	815	2014-11-02	2015-02-15 00:00:00	481	1
4580	841	2014-12-02	2015-02-15 00:00:00	481	1
4581	865	2015-01-02	2015-02-15 00:00:00	481	1
4582	937	2014-10-02	2015-02-15 00:00:00	482	1
4583	949	2014-11-02	2015-02-15 00:00:00	482	1
4584	961	2014-12-02	2015-02-15 00:00:00	482	1
4585	973	2015-01-02	2015-02-15 00:00:00	482	1
4586	0	2014-10-02	2015-02-15 00:00:00	483	1
4587	0	2014-11-02	2015-02-15 00:00:00	483	1
4588	0	2014-12-02	2015-02-15 00:00:00	483	1
4589	0	2015-01-02	2015-02-15 00:00:00	483	1
4590	1839	2014-10-02	2015-02-15 00:00:00	484	1
4591	1851	2014-11-02	2015-02-15 00:00:00	484	1
4592	1863	2014-12-02	2015-02-15 00:00:00	484	1
4593	1875	2015-01-02	2015-02-15 00:00:00	484	1
4594	534	2014-10-02	2015-02-15 00:00:00	485	1
4595	538	2014-11-02	2015-02-15 00:00:00	485	1
4596	545	2014-12-02	2015-02-15 00:00:00	485	1
4597	549	2015-01-02	2015-02-15 00:00:00	485	1
4598	524	2014-10-02	2015-02-15 00:00:00	486	1
4599	529	2014-11-02	2015-02-15 00:00:00	486	1
4600	535	2014-12-02	2015-02-15 00:00:00	486	1
4601	540	2015-01-02	2015-02-15 00:00:00	486	1
4602	222	2014-10-02	2015-02-15 00:00:00	487	1
4603	224	2014-11-02	2015-02-15 00:00:00	487	1
4604	226	2014-12-02	2015-02-15 00:00:00	487	1
4605	229	2015-01-02	2015-02-15 00:00:00	487	1
4606	0	2014-10-02	2015-02-15 00:00:00	489	1
4607	0	2014-11-02	2015-02-15 00:00:00	489	1
4608	0	2014-12-02	2015-02-15 00:00:00	489	1
4609	0	2015-01-02	2015-02-15 00:00:00	489	1
4610	0	2014-10-02	2015-02-15 00:00:00	490	1
4611	0	2014-11-02	2015-02-15 00:00:00	490	1
4612	0	2014-12-02	2015-02-15 00:00:00	490	1
4613	0	2015-01-02	2015-02-15 00:00:00	490	1
4614	0	2014-10-02	2015-02-15 00:00:00	491	1
4615	0	2014-11-02	2015-02-15 00:00:00	491	1
4616	0	2014-12-02	2015-02-15 00:00:00	491	1
4617	0	2015-01-02	2015-02-15 00:00:00	491	1
4618	1010	2014-10-02	2015-02-15 00:00:00	493	1
4619	1024	2014-11-02	2015-02-15 00:00:00	493	1
4620	1032	2014-12-02	2015-02-15 00:00:00	493	1
4621	1045	2015-01-02	2015-02-15 00:00:00	493	1
4622	0	2014-10-02	2015-02-15 00:00:00	494	1
4623	0	2014-11-02	2015-02-15 00:00:00	494	1
4624	0	2014-12-02	2015-02-15 00:00:00	494	1
4625	0	2015-01-02	2015-02-15 00:00:00	494	1
4626	746	2014-10-02	2015-02-15 00:00:00	495	1
4627	759	2014-11-02	2015-02-15 00:00:00	495	1
4628	773	2014-12-02	2015-02-15 00:00:00	495	1
4629	787	2015-01-02	2015-02-15 00:00:00	495	1
4630	0	2014-10-02	2015-02-15 00:00:00	496	1
4631	0	2014-11-02	2015-02-15 00:00:00	496	1
4632	0	2014-12-02	2015-02-15 00:00:00	496	1
4633	0	2015-01-02	2015-02-15 00:00:00	496	1
4634	349	2014-10-02	2015-02-15 00:00:00	498	1
4635	349	2014-11-02	2015-02-15 00:00:00	498	1
4636	353	2014-12-02	2015-02-15 00:00:00	498	1
4637	353	2015-01-02	2015-02-15 00:00:00	498	1
4638	652	2014-10-02	2015-02-15 00:00:00	499	1
4639	652	2014-11-02	2015-02-15 00:00:00	499	1
4640	652	2014-12-02	2015-02-15 00:00:00	499	1
4641	652	2015-01-02	2015-02-15 00:00:00	499	1
4642	0	2014-10-02	2015-02-15 00:00:00	500	1
4643	0	2014-11-02	2015-02-15 00:00:00	500	1
4644	0	2014-12-02	2015-02-15 00:00:00	500	1
4645	0	2015-01-02	2015-02-15 00:00:00	500	1
4646	452	2014-10-02	2015-02-15 00:00:00	501	1
4647	461	2014-11-02	2015-02-15 00:00:00	501	1
4648	473	2014-12-02	2015-02-15 00:00:00	501	1
4649	486	2015-01-02	2015-02-15 00:00:00	501	1
4650	1891	2014-10-02	2015-02-15 00:00:00	502	1
4651	1909	2014-11-02	2015-02-15 00:00:00	502	1
4652	1931	2014-12-02	2015-02-15 00:00:00	502	1
4653	1947	2015-01-02	2015-02-15 00:00:00	502	1
4654	337	2014-10-02	2015-02-15 00:00:00	503	1
4655	348	2014-11-02	2015-02-15 00:00:00	503	1
4656	360	2014-12-02	2015-02-15 00:00:00	503	1
4657	371	2015-01-02	2015-02-15 00:00:00	503	1
4658	1384	2014-10-02	2015-02-15 00:00:00	504	1
4659	1399	2014-11-02	2015-02-15 00:00:00	504	1
4660	1415	2014-12-02	2015-02-15 00:00:00	504	1
4661	1415	2015-01-02	2015-02-15 00:00:00	504	1
4662	0	2014-10-02	2015-02-15 00:00:00	505	1
4663	0	2014-11-02	2015-02-15 00:00:00	505	1
4664	0	2014-12-02	2015-02-15 00:00:00	505	1
4665	0	2015-01-02	2015-02-15 00:00:00	505	1
4666	899	2014-10-02	2015-02-15 00:00:00	506	1
4667	907	2014-11-02	2015-02-15 00:00:00	506	1
4668	914	2014-12-02	2015-02-15 00:00:00	506	1
4669	925	2015-01-02	2015-02-15 00:00:00	506	1
4670	1135	2014-10-02	2015-02-15 00:00:00	507	1
4671	1143	2014-11-02	2015-02-15 00:00:00	507	1
4672	1153	2014-12-02	2015-02-15 00:00:00	507	1
4673	1163	2015-01-02	2015-02-15 00:00:00	507	1
4674	478	2014-10-02	2015-02-15 00:00:00	508	1
4675	487	2014-11-02	2015-02-15 00:00:00	508	1
4676	496	2014-12-02	2015-02-15 00:00:00	508	1
4677	504	2015-01-02	2015-02-15 00:00:00	508	1
4678	922	2014-10-02	2015-02-15 00:00:00	509	1
4679	931	2014-11-02	2015-02-15 00:00:00	509	1
4680	939	2014-12-02	2015-02-15 00:00:00	509	1
4681	947	2015-01-02	2015-02-15 00:00:00	509	1
4682	0	2014-10-02	2015-02-15 00:00:00	510	1
4683	0	2014-11-02	2015-02-15 00:00:00	510	1
4684	0	2014-12-02	2015-02-15 00:00:00	510	1
4685	0	2015-01-02	2015-02-15 00:00:00	510	1
4686	0	2014-10-02	2015-02-15 00:00:00	511	1
4687	0	2014-11-02	2015-02-15 00:00:00	511	1
4688	0	2014-12-02	2015-02-15 00:00:00	511	1
4689	0	2015-01-02	2015-02-15 00:00:00	511	1
4690	31	2014-10-02	2015-02-15 00:00:00	512	1
4691	31	2014-11-02	2015-02-15 00:00:00	512	1
4692	32	2014-12-02	2015-02-15 00:00:00	512	1
4693	34	2015-01-02	2015-02-15 00:00:00	512	1
4694	99	2014-10-02	2015-02-15 00:00:00	513	1
4695	110	2014-11-02	2015-02-15 00:00:00	513	1
4696	121	2014-12-02	2015-02-15 00:00:00	513	1
4697	135	2015-01-02	2015-02-15 00:00:00	513	1
4698	585	2014-10-02	2015-02-15 00:00:00	514	1
4699	592	2014-11-02	2015-02-15 00:00:00	514	1
4700	598	2014-12-02	2015-02-15 00:00:00	514	1
4701	604	2015-01-02	2015-02-15 00:00:00	514	1
4702	817	2014-10-02	2015-02-15 00:00:00	515	1
4703	823	2014-11-02	2015-02-15 00:00:00	515	1
4704	828	2014-12-02	2015-02-15 00:00:00	515	1
4705	834	2015-01-02	2015-02-15 00:00:00	515	1
4706	674	2014-10-02	2015-02-15 00:00:00	516	1
4707	683	2014-11-02	2015-02-15 00:00:00	516	1
4708	694	2014-12-02	2015-02-15 00:00:00	516	1
4709	704	2015-01-02	2015-02-15 00:00:00	516	1
4710	234	2014-10-02	2015-02-15 00:00:00	517	1
4711	238	2014-11-02	2015-02-15 00:00:00	517	1
4712	241	2014-12-02	2015-02-15 00:00:00	517	1
4713	244	2015-01-02	2015-02-15 00:00:00	517	1
4714	942	2014-10-02	2015-02-15 00:00:00	518	1
4715	948	2014-11-02	2015-02-15 00:00:00	518	1
4716	957	2014-12-02	2015-02-15 00:00:00	518	1
4717	968	2015-01-02	2015-02-15 00:00:00	518	1
4718	121	2014-10-02	2015-02-15 00:00:00	519	1
4719	121	2014-11-02	2015-02-15 00:00:00	519	1
4720	121	2014-12-02	2015-02-15 00:00:00	519	1
4721	121	2015-01-02	2015-02-15 00:00:00	519	1
4722	1786	2014-10-02	2015-02-15 00:00:00	520	1
4723	1795	2014-11-02	2015-02-15 00:00:00	520	1
4724	1807	2014-12-02	2015-02-15 00:00:00	520	1
4725	1819	2015-01-02	2015-02-15 00:00:00	520	1
4726	326	2014-10-02	2015-02-15 00:00:00	521	1
4727	336	2014-11-02	2015-02-15 00:00:00	521	1
4728	348	2014-12-02	2015-02-15 00:00:00	521	1
4729	365	2015-01-02	2015-02-15 00:00:00	521	1
4730	632	2014-10-02	2015-02-15 00:00:00	522	1
4731	640	2014-11-02	2015-02-15 00:00:00	522	1
4732	650	2014-12-02	2015-02-15 00:00:00	522	1
4733	658	2015-01-02	2015-02-15 00:00:00	522	1
4734	1460	2014-10-02	2015-02-15 00:00:00	523	1
4735	1470	2014-11-02	2015-02-15 00:00:00	523	1
4736	1486	2014-12-02	2015-02-15 00:00:00	523	1
4737	1500	2015-01-02	2015-02-15 00:00:00	523	1
4738	1172	2014-10-02	2015-02-15 00:00:00	524	1
4739	1177	2014-11-02	2015-02-15 00:00:00	524	1
4740	1186	2014-12-02	2015-02-15 00:00:00	524	1
4741	1194	2015-01-02	2015-02-15 00:00:00	524	1
4742	0	2014-10-02	2015-02-15 00:00:00	525	1
4743	0	2014-11-02	2015-02-15 00:00:00	525	1
4744	0	2014-12-02	2015-02-15 00:00:00	525	1
4745	0	2015-01-02	2015-02-15 00:00:00	525	1
4746	0	2014-10-02	2015-02-15 00:00:00	526	1
4747	0	2014-11-02	2015-02-15 00:00:00	526	1
4748	0	2014-12-02	2015-02-15 00:00:00	526	1
4749	0	2015-01-02	2015-02-15 00:00:00	526	1
4750	1072	2014-10-02	2015-02-15 00:00:00	527	1
4751	1082	2014-11-02	2015-02-15 00:00:00	527	1
4752	1090	2014-12-02	2015-02-15 00:00:00	527	1
4753	1100	2015-01-02	2015-02-15 00:00:00	527	1
4754	99	2014-10-02	2015-02-15 00:00:00	528	1
4755	99	2014-11-02	2015-02-15 00:00:00	528	1
4756	100	2014-12-02	2015-02-15 00:00:00	528	1
4757	103	2015-01-02	2015-02-15 00:00:00	528	1
4758	0	2014-10-02	2015-02-15 00:00:00	529	1
4759	0	2014-11-02	2015-02-15 00:00:00	529	1
4760	0	2014-12-02	2015-02-15 00:00:00	529	1
4761	0	2015-01-02	2015-02-15 00:00:00	529	1
4762	221	2014-10-02	2015-02-15 00:00:00	530	1
4763	222	2014-11-02	2015-02-15 00:00:00	530	1
4764	222	2014-12-02	2015-02-15 00:00:00	530	1
4765	222	2015-01-02	2015-02-15 00:00:00	530	1
4766	541	2014-10-02	2015-02-15 00:00:00	531	1
4767	547	2014-11-02	2015-02-15 00:00:00	531	1
4768	552	2014-12-02	2015-02-15 00:00:00	531	1
4769	557	2015-01-02	2015-02-15 00:00:00	531	1
4770	1163	2014-10-02	2015-02-15 00:00:00	532	1
4771	1174	2014-11-02	2015-02-15 00:00:00	532	1
4772	1184	2014-12-02	2015-02-15 00:00:00	532	1
4773	1195	2015-01-02	2015-02-15 00:00:00	532	1
4774	267	2014-10-02	2015-02-15 00:00:00	533	1
4775	272	2014-11-02	2015-02-15 00:00:00	533	1
4776	278	2014-12-02	2015-02-15 00:00:00	533	1
4777	283	2015-01-02	2015-02-15 00:00:00	533	1
4778	662	2014-10-02	2015-02-15 00:00:00	534	1
4779	663	2014-11-02	2015-02-15 00:00:00	534	1
4780	663	2014-12-02	2015-02-15 00:00:00	534	1
4781	663	2015-01-02	2015-02-15 00:00:00	534	1
4782	0	2014-10-02	2015-02-15 00:00:00	536	1
4783	0	2014-11-02	2015-02-15 00:00:00	536	1
4784	0	2014-12-02	2015-02-15 00:00:00	536	1
4785	0	2015-01-02	2015-02-15 00:00:00	536	1
4786	1044	2014-10-02	2015-02-15 00:00:00	537	1
4787	1051	2014-11-02	2015-02-15 00:00:00	537	1
4788	1059	2014-12-02	2015-02-15 00:00:00	537	1
4789	1071	2015-01-02	2015-02-15 00:00:00	537	1
4790	622	2014-10-02	2015-02-15 00:00:00	538	1
4791	626	2014-11-02	2015-02-15 00:00:00	538	1
4792	636	2014-12-02	2015-02-15 00:00:00	538	1
4793	644	2015-01-02	2015-02-15 00:00:00	538	1
4794	1144	2014-10-02	2015-02-15 00:00:00	539	1
4795	1155	2014-11-02	2015-02-15 00:00:00	539	1
4796	1169	2014-12-02	2015-02-15 00:00:00	539	1
4797	1186	2015-01-02	2015-02-15 00:00:00	539	1
4798	0	2014-10-02	2015-02-15 00:00:00	540	1
4799	0	2014-11-02	2015-02-15 00:00:00	540	1
4800	0	2014-12-02	2015-02-15 00:00:00	540	1
4801	0	2015-01-02	2015-02-15 00:00:00	540	1
4802	944	2014-10-02	2015-02-15 00:00:00	541	1
4803	952	2014-11-02	2015-02-15 00:00:00	541	1
4804	970	2014-12-02	2015-02-15 00:00:00	541	1
4805	991	2015-01-02	2015-02-15 00:00:00	541	1
4806	358	2014-10-02	2015-02-15 00:00:00	542	1
4807	365	2014-11-02	2015-02-15 00:00:00	542	1
4808	371	2014-12-02	2015-02-15 00:00:00	542	1
4809	377	2015-01-02	2015-02-15 00:00:00	542	1
4810	0	2014-10-02	2015-02-15 00:00:00	543	1
4811	0	2014-11-02	2015-02-15 00:00:00	543	1
4812	0	2014-12-02	2015-02-15 00:00:00	543	1
4813	0	2015-01-02	2015-02-15 00:00:00	543	1
4814	246	2014-10-02	2015-02-15 00:00:00	544	1
4815	246	2014-11-02	2015-02-15 00:00:00	544	1
4816	246	2014-12-02	2015-02-15 00:00:00	544	1
4817	246	2015-01-02	2015-02-15 00:00:00	544	1
4818	938	2014-10-02	2015-02-15 00:00:00	545	1
4819	941	2014-11-02	2015-02-15 00:00:00	545	1
4820	946	2014-12-02	2015-02-15 00:00:00	545	1
4821	955	2015-01-02	2015-02-15 00:00:00	545	1
4822	24	2014-10-02	2015-02-15 00:00:00	546	1
4823	33	2014-11-02	2015-02-15 00:00:00	546	1
4824	44	2014-12-02	2015-02-15 00:00:00	546	1
4825	53	2015-01-02	2015-02-15 00:00:00	546	1
4826	0	2014-10-02	2015-02-15 00:00:00	547	1
4827	0	2014-11-02	2015-02-15 00:00:00	547	1
4828	0	2014-12-02	2015-02-15 00:00:00	547	1
4829	0	2015-01-02	2015-02-15 00:00:00	547	1
4830	0	2014-10-02	2015-02-15 00:00:00	548	1
4831	0	2014-11-02	2015-02-15 00:00:00	548	1
4832	0	2014-12-02	2015-02-15 00:00:00	548	1
4833	0	2015-01-02	2015-02-15 00:00:00	548	1
4834	0	2014-10-02	2015-02-15 00:00:00	549	1
4835	0	2014-11-02	2015-02-15 00:00:00	549	1
4836	0	2014-12-02	2015-02-15 00:00:00	549	1
4837	0	2015-01-02	2015-02-15 00:00:00	549	1
4838	0	2014-10-02	2015-02-15 00:00:00	550	1
4839	0	2014-11-02	2015-02-15 00:00:00	550	1
4840	0	2014-12-02	2015-02-15 00:00:00	550	1
4841	0	2015-01-02	2015-02-15 00:00:00	550	1
4842	95	2014-10-02	2015-02-15 00:00:00	551	1
4843	95	2014-11-02	2015-02-15 00:00:00	551	1
4844	96	2014-12-02	2015-02-15 00:00:00	551	1
4845	98	2015-01-02	2015-02-15 00:00:00	551	1
4846	32	2014-10-02	2015-02-15 00:00:00	552	1
4847	32	2014-11-02	2015-02-15 00:00:00	552	1
4848	32	2014-12-02	2015-02-15 00:00:00	552	1
4849	32	2015-01-02	2015-02-15 00:00:00	552	1
4850	823	2014-10-02	2015-02-15 00:00:00	553	1
4851	857	2014-11-02	2015-02-15 00:00:00	553	1
4852	863	2014-12-02	2015-02-15 00:00:00	553	1
4853	867	2015-01-02	2015-02-15 00:00:00	553	1
4854	81	2014-10-02	2015-02-15 00:00:00	554	1
4855	81	2014-11-02	2015-02-15 00:00:00	554	1
4856	81	2014-12-02	2015-02-15 00:00:00	554	1
4857	81	2015-01-02	2015-02-15 00:00:00	554	1
4858	0	2014-10-02	2015-02-15 00:00:00	555	1
4859	0	2014-11-02	2015-02-15 00:00:00	555	1
4860	0	2014-12-02	2015-02-15 00:00:00	555	1
4861	0	2015-01-02	2015-02-15 00:00:00	555	1
4862	0	2014-10-02	2015-02-15 00:00:00	556	1
4863	0	2014-11-02	2015-02-15 00:00:00	556	1
4864	0	2014-12-02	2015-02-15 00:00:00	556	1
4865	0	2015-01-02	2015-02-15 00:00:00	556	1
4866	0	2014-10-02	2015-02-15 00:00:00	557	1
4867	0	2014-11-02	2015-02-15 00:00:00	557	1
4868	0	2014-12-02	2015-02-15 00:00:00	557	1
4869	0	2015-01-02	2015-02-15 00:00:00	557	1
4870	377	2014-10-02	2015-02-15 00:00:00	558	1
4871	378	2014-11-02	2015-02-15 00:00:00	558	1
4872	381	2014-12-02	2015-02-15 00:00:00	558	1
4873	384	2015-01-02	2015-02-15 00:00:00	558	1
4874	0	2014-10-02	2015-02-15 00:00:00	559	1
4875	0	2014-11-02	2015-02-15 00:00:00	559	1
4876	0	2014-12-02	2015-02-15 00:00:00	559	1
4877	0	2015-01-02	2015-02-15 00:00:00	559	1
4878	39	2014-10-02	2015-02-15 00:00:00	560	1
4879	39	2014-11-02	2015-02-15 00:00:00	560	1
4880	39	2014-12-02	2015-02-15 00:00:00	560	1
4881	39	2015-01-02	2015-02-15 00:00:00	560	1
4882	0	2014-10-02	2015-02-15 00:00:00	561	1
4883	0	2014-11-02	2015-02-15 00:00:00	561	1
4884	0	2014-12-02	2015-02-15 00:00:00	561	1
4885	0	2015-01-02	2015-02-15 00:00:00	561	1
4886	744	2014-10-02	2015-02-15 00:00:00	562	1
4887	748	2014-11-02	2015-02-15 00:00:00	562	1
4888	753	2014-12-02	2015-02-15 00:00:00	562	1
4889	761	2015-01-02	2015-02-15 00:00:00	562	1
4890	152	2014-10-02	2015-02-15 00:00:00	563	1
4891	157	2014-11-02	2015-02-15 00:00:00	563	1
4892	162	2014-12-02	2015-02-15 00:00:00	563	1
4893	170	2015-01-02	2015-02-15 00:00:00	563	1
4894	0	2014-10-02	2015-02-15 00:00:00	564	1
4895	0	2014-11-02	2015-02-15 00:00:00	564	1
4896	0	2014-12-02	2015-02-15 00:00:00	564	1
4897	0	2015-01-02	2015-02-15 00:00:00	564	1
4898	1426	2014-10-02	2015-02-15 00:00:00	565	1
4899	1438	2014-11-02	2015-02-15 00:00:00	565	1
4900	1450	2014-12-02	2015-02-15 00:00:00	565	1
4901	1464	2015-01-02	2015-02-15 00:00:00	565	1
4902	1039	2014-10-02	2015-02-15 00:00:00	566	1
4903	1050	2014-11-02	2015-02-15 00:00:00	566	1
4904	1060	2014-12-02	2015-02-15 00:00:00	566	1
4905	1070	2015-01-02	2015-02-15 00:00:00	566	1
4906	807	2014-10-02	2015-02-15 00:00:00	567	1
4907	807	2014-11-02	2015-02-15 00:00:00	567	1
4908	807	2014-12-02	2015-02-15 00:00:00	567	1
4909	807	2015-01-02	2015-02-15 00:00:00	567	1
4910	1153	2014-10-02	2015-02-15 00:00:00	568	1
4911	1162	2014-11-02	2015-02-15 00:00:00	568	1
4912	1173	2014-12-02	2015-02-15 00:00:00	568	1
4913	1183	2015-01-02	2015-02-15 00:00:00	568	1
4914	1507	2014-10-02	2015-02-15 00:00:00	569	1
4915	1518	2014-11-02	2015-02-15 00:00:00	569	1
4916	1531	2014-12-02	2015-02-15 00:00:00	569	1
4917	1547	2015-01-02	2015-02-15 00:00:00	569	1
4918	1658	2014-10-02	2015-02-15 00:00:00	570	1
4919	1684	2014-11-02	2015-02-15 00:00:00	570	1
4920	1707	2014-12-02	2015-02-15 00:00:00	570	1
4921	1739	2015-01-02	2015-02-15 00:00:00	570	1
4922	55	2014-10-02	2015-02-15 00:00:00	571	1
4923	55	2014-11-02	2015-02-15 00:00:00	571	1
4924	55	2014-12-02	2015-02-15 00:00:00	571	1
4925	55	2015-01-02	2015-02-15 00:00:00	571	1
4926	723	2014-10-02	2015-02-15 00:00:00	572	1
4927	735	2014-11-02	2015-02-15 00:00:00	572	1
4928	745	2014-12-02	2015-02-15 00:00:00	572	1
4929	758	2015-01-02	2015-02-15 00:00:00	572	1
4930	0	2014-10-02	2015-02-15 00:00:00	573	1
4931	0	2014-11-02	2015-02-15 00:00:00	573	1
4932	0	2014-12-02	2015-02-15 00:00:00	573	1
4933	0	2015-01-02	2015-02-15 00:00:00	573	1
4934	1430	2014-10-02	2015-02-15 00:00:00	574	1
4935	1437	2014-11-02	2015-02-15 00:00:00	574	1
4936	1446	2014-12-02	2015-02-15 00:00:00	574	1
4937	1457	2015-01-02	2015-02-15 00:00:00	574	1
4938	1924	2014-10-02	2015-02-15 00:00:00	575	1
4939	1935	2014-11-02	2015-02-15 00:00:00	575	1
4940	1950	2014-12-02	2015-02-15 00:00:00	575	1
4941	1967	2015-01-02	2015-02-15 00:00:00	575	1
4942	1336	2014-10-02	2015-02-15 00:00:00	576	1
4943	1346	2014-11-02	2015-02-15 00:00:00	576	1
4944	1356	2014-12-02	2015-02-15 00:00:00	576	1
4945	1368	2015-01-02	2015-02-15 00:00:00	576	1
4946	1196	2014-10-02	2015-02-15 00:00:00	577	1
4947	1208	2014-11-02	2015-02-15 00:00:00	577	1
4948	1219	2014-12-02	2015-02-15 00:00:00	577	1
4949	1230	2015-01-02	2015-02-15 00:00:00	577	1
4950	68	2014-10-02	2015-02-15 00:00:00	578	1
4951	72	2014-11-02	2015-02-15 00:00:00	578	1
4952	78	2014-12-02	2015-02-15 00:00:00	578	1
4953	99	2015-01-02	2015-02-15 00:00:00	578	1
4954	1280	2014-10-02	2015-02-15 00:00:00	579	1
4955	1284	2014-11-02	2015-02-15 00:00:00	579	1
4956	1288	2014-12-02	2015-02-15 00:00:00	579	1
4957	1295	2015-01-02	2015-02-15 00:00:00	579	1
4958	2656	2014-10-02	2015-02-15 00:00:00	580	1
4959	2672	2014-11-02	2015-02-15 00:00:00	580	1
4960	2691	2014-12-02	2015-02-15 00:00:00	580	1
4961	2717	2015-01-02	2015-02-15 00:00:00	580	1
4962	1372	2014-10-02	2015-02-15 00:00:00	581	1
4963	1384	2014-11-02	2015-02-15 00:00:00	581	1
4964	1397	2014-12-02	2015-02-15 00:00:00	581	1
4965	1412	2015-01-02	2015-02-15 00:00:00	581	1
4966	0	2014-10-02	2015-02-15 00:00:00	582	1
4967	0	2014-11-02	2015-02-15 00:00:00	582	1
4968	0	2014-12-02	2015-02-15 00:00:00	582	1
4969	0	2015-01-02	2015-02-15 00:00:00	582	1
4970	1426	2014-10-02	2015-02-15 00:00:00	583	1
4971	1432	2014-11-02	2015-02-15 00:00:00	583	1
4972	1437	2014-12-02	2015-02-15 00:00:00	583	1
4973	1445	2015-01-02	2015-02-15 00:00:00	583	1
4974	0	2014-10-02	2015-02-15 00:00:00	584	1
4975	0	2014-11-02	2015-02-15 00:00:00	584	1
4976	0	2014-12-02	2015-02-15 00:00:00	584	1
4977	0	2015-01-02	2015-02-15 00:00:00	584	1
4978	0	2014-10-02	2015-02-15 00:00:00	585	1
4979	0	2014-11-02	2015-02-15 00:00:00	585	1
4980	0	2014-12-02	2015-02-15 00:00:00	585	1
4981	0	2015-01-02	2015-02-15 00:00:00	585	1
4982	0	2014-10-02	2015-02-15 00:00:00	586	1
4983	0	2014-11-02	2015-02-15 00:00:00	586	1
4984	0	2014-12-02	2015-02-15 00:00:00	586	1
4985	0	2015-01-02	2015-02-15 00:00:00	586	1
4986	1556	2014-10-02	2015-02-15 00:00:00	587	1
4987	1556	2014-11-02	2015-02-15 00:00:00	587	1
4988	1556	2014-12-02	2015-02-15 00:00:00	587	1
4989	1557	2015-01-02	2015-02-15 00:00:00	587	1
4990	1071	2014-10-02	2015-02-15 00:00:00	588	1
4991	1078	2014-11-02	2015-02-15 00:00:00	588	1
4992	1087	2014-12-02	2015-02-15 00:00:00	588	1
4993	1099	2015-01-02	2015-02-15 00:00:00	588	1
4994	0	2014-10-02	2015-02-15 00:00:00	589	1
4995	0	2014-11-02	2015-02-15 00:00:00	589	1
4996	0	2014-12-02	2015-02-15 00:00:00	589	1
4997	0	2015-01-02	2015-02-15 00:00:00	589	1
4998	0	2014-10-02	2015-02-15 00:00:00	590	1
4999	0	2014-11-02	2015-02-15 00:00:00	590	1
5000	0	2014-12-02	2015-02-15 00:00:00	590	1
5001	0	2015-01-02	2015-02-15 00:00:00	590	1
5002	786	2014-10-02	2015-02-15 00:00:00	591	1
5003	786	2014-11-02	2015-02-15 00:00:00	591	1
5004	787	2014-12-02	2015-02-15 00:00:00	591	1
5005	789	2015-01-02	2015-02-15 00:00:00	591	1
5006	861	2014-10-02	2015-02-15 00:00:00	592	1
5007	861	2014-11-02	2015-02-15 00:00:00	592	1
5008	861	2014-12-02	2015-02-15 00:00:00	592	1
5009	861	2015-01-02	2015-02-15 00:00:00	592	1
5010	2085	2014-10-02	2015-02-15 00:00:00	593	1
5011	2099	2014-11-02	2015-02-15 00:00:00	593	1
5012	2115	2014-12-02	2015-02-15 00:00:00	593	1
5013	2136	2015-01-02	2015-02-15 00:00:00	593	1
5014	942	2014-10-02	2015-02-15 00:00:00	594	1
5015	947	2014-11-02	2015-02-15 00:00:00	594	1
5016	953	2014-12-02	2015-02-15 00:00:00	594	1
5017	960	2015-01-02	2015-02-15 00:00:00	594	1
5018	283	2014-10-02	2015-02-15 00:00:00	595	1
5019	285	2014-11-02	2015-02-15 00:00:00	595	1
5020	290	2014-12-02	2015-02-15 00:00:00	595	1
5021	295	2015-01-02	2015-02-15 00:00:00	595	1
5022	91	2014-10-02	2015-02-15 00:00:00	596	1
5023	92	2014-11-02	2015-02-15 00:00:00	596	1
5024	99	2014-12-02	2015-02-15 00:00:00	596	1
5025	105	2015-01-02	2015-02-15 00:00:00	596	1
5026	339	2014-10-02	2015-02-15 00:00:00	597	1
5027	340	2014-11-02	2015-02-15 00:00:00	597	1
5028	340	2014-12-02	2015-02-15 00:00:00	597	1
5029	342	2015-01-02	2015-02-15 00:00:00	597	1
5030	21	2014-10-02	2015-02-15 00:00:00	598	1
5031	22	2014-11-02	2015-02-15 00:00:00	598	1
5032	23	2014-12-02	2015-02-15 00:00:00	598	1
5033	23	2015-01-02	2015-02-15 00:00:00	598	1
5034	1327	2014-10-02	2015-02-15 00:00:00	599	1
5035	1338	2014-11-02	2015-02-15 00:00:00	599	1
5036	1350	2014-12-02	2015-02-15 00:00:00	599	1
5037	1363	2015-01-02	2015-02-15 00:00:00	599	1
5038	0	2014-10-02	2015-02-15 00:00:00	600	1
5039	0	2014-11-02	2015-02-15 00:00:00	600	1
5040	0	2014-12-02	2015-02-15 00:00:00	600	1
5041	0	2015-01-02	2015-02-15 00:00:00	600	1
5042	1084	2014-10-02	2015-02-15 00:00:00	601	1
5043	1094	2014-11-02	2015-02-15 00:00:00	601	1
5044	1107	2014-12-02	2015-02-15 00:00:00	601	1
5045	1118	2015-01-02	2015-02-15 00:00:00	601	1
5046	987	2014-10-02	2015-02-15 00:00:00	602	1
5047	1001	2014-11-02	2015-02-15 00:00:00	602	1
5048	1015	2014-12-02	2015-02-15 00:00:00	602	1
5049	1028	2015-01-02	2015-02-15 00:00:00	602	1
5050	1322	2014-10-02	2015-02-15 00:00:00	603	1
5051	1331	2014-11-02	2015-02-15 00:00:00	603	1
5052	1344	2014-12-02	2015-02-15 00:00:00	603	1
5053	1356	2015-01-02	2015-02-15 00:00:00	603	1
5054	1431	2014-10-02	2015-02-15 00:00:00	604	1
5055	1441	2014-11-02	2015-02-15 00:00:00	604	1
5056	1443	2014-12-02	2015-02-15 00:00:00	604	1
5057	1468	2015-01-02	2015-02-15 00:00:00	604	1
5058	891	2014-10-02	2015-02-15 00:00:00	605	1
5059	909	2014-11-02	2015-02-15 00:00:00	605	1
5060	929	2014-12-02	2015-02-15 00:00:00	605	1
5061	955	2015-01-02	2015-02-15 00:00:00	605	1
5062	2264	2014-10-02	2015-02-15 00:00:00	606	1
5063	2285	2014-11-02	2015-02-15 00:00:00	606	1
5064	2306	2014-12-02	2015-02-15 00:00:00	606	1
5065	2330	2015-01-02	2015-02-15 00:00:00	606	1
5066	1172	2014-10-02	2015-02-15 00:00:00	607	1
5067	1181	2014-11-02	2015-02-15 00:00:00	607	1
5068	1192	2014-12-02	2015-02-15 00:00:00	607	1
5069	1205	2015-01-02	2015-02-15 00:00:00	607	1
5070	184	2014-10-02	2015-02-15 00:00:00	608	1
5071	197	2014-11-02	2015-02-15 00:00:00	608	1
5072	210	2014-12-02	2015-02-15 00:00:00	608	1
5073	223	2015-01-02	2015-02-15 00:00:00	608	1
5074	1486	2014-10-02	2015-02-15 00:00:00	609	1
5075	1499	2014-11-02	2015-02-15 00:00:00	609	1
5076	1518	2014-12-02	2015-02-15 00:00:00	609	1
5077	1536	2015-01-02	2015-02-15 00:00:00	609	1
5078	142	2014-10-02	2015-02-15 00:00:00	610	1
5079	142	2014-11-02	2015-02-15 00:00:00	610	1
5080	142	2014-12-02	2015-02-15 00:00:00	610	1
5081	143	2015-01-02	2015-02-15 00:00:00	610	1
5082	532	2014-10-02	2015-02-15 00:00:00	611	1
5083	548	2014-11-02	2015-02-15 00:00:00	611	1
5084	568	2014-12-02	2015-02-15 00:00:00	611	1
5085	586	2015-01-02	2015-02-15 00:00:00	611	1
5086	235	2014-10-02	2015-02-15 00:00:00	612	1
5087	238	2014-11-02	2015-02-15 00:00:00	612	1
5088	240	2014-12-02	2015-02-15 00:00:00	612	1
5089	246	2015-01-02	2015-02-15 00:00:00	612	1
5320	167	2014-12-02	2015-02-15 00:00:00	670	1
5090	2149	2014-10-02	2015-02-15 00:00:00	613	1
5091	2172	2014-11-02	2015-02-15 00:00:00	613	1
5092	2194	2014-12-02	2015-02-15 00:00:00	613	1
5093	2220	2015-01-02	2015-02-15 00:00:00	613	1
5094	2497	2014-10-02	2015-02-15 00:00:00	614	1
5095	2517	2014-11-02	2015-02-15 00:00:00	614	1
5096	2530	2014-12-02	2015-02-15 00:00:00	614	1
5097	2547	2015-01-02	2015-02-15 00:00:00	614	1
5098	1707	2014-10-02	2015-02-15 00:00:00	615	1
5099	1724	2014-11-02	2015-02-15 00:00:00	615	1
5100	1743	2014-12-02	2015-02-15 00:00:00	615	1
5101	1770	2015-01-02	2015-02-15 00:00:00	615	1
5102	1937	2014-10-02	2015-02-15 00:00:00	616	1
5103	1947	2014-11-02	2015-02-15 00:00:00	616	1
5104	1958	2014-12-02	2015-02-15 00:00:00	616	1
5105	1971	2015-01-02	2015-02-15 00:00:00	616	1
5106	1258	2014-10-02	2015-02-15 00:00:00	617	1
5107	1267	2014-11-02	2015-02-15 00:00:00	617	1
5108	1276	2014-12-02	2015-02-15 00:00:00	617	1
5109	1288	2015-01-02	2015-02-15 00:00:00	617	1
5110	1251	2014-10-02	2015-02-15 00:00:00	618	1
5111	1256	2014-11-02	2015-02-15 00:00:00	618	1
5112	1261	2014-12-02	2015-02-15 00:00:00	618	1
5113	1269	2015-01-02	2015-02-15 00:00:00	618	1
5114	2002	2014-10-02	2015-02-15 00:00:00	619	1
5115	2022	2014-11-02	2015-02-15 00:00:00	619	1
5116	2042	2014-12-02	2015-02-15 00:00:00	619	1
5117	2068	2015-01-02	2015-02-15 00:00:00	619	1
5118	0	2014-10-02	2015-02-15 00:00:00	620	1
5119	0	2014-11-02	2015-02-15 00:00:00	620	1
5120	0	2014-12-02	2015-02-15 00:00:00	620	1
5121	0	2015-01-02	2015-02-15 00:00:00	620	1
5122	944	2014-10-02	2015-02-15 00:00:00	621	1
5123	957	2014-11-02	2015-02-15 00:00:00	621	1
5124	971	2014-12-02	2015-02-15 00:00:00	621	1
5125	986	2015-01-02	2015-02-15 00:00:00	621	1
5126	0	2014-10-02	2015-02-15 00:00:00	622	1
5127	0	2014-11-02	2015-02-15 00:00:00	622	1
5128	0	2014-12-02	2015-02-15 00:00:00	622	1
5129	0	2015-01-02	2015-02-15 00:00:00	622	1
5130	0	2014-10-02	2015-02-15 00:00:00	623	1
5131	0	2014-11-02	2015-02-15 00:00:00	623	1
5132	0	2014-12-02	2015-02-15 00:00:00	623	1
5133	0	2015-01-02	2015-02-15 00:00:00	623	1
5134	1691	2014-10-02	2015-02-15 00:00:00	624	1
5135	1706	2014-11-02	2015-02-15 00:00:00	624	1
5136	1725	2014-12-02	2015-02-15 00:00:00	624	1
5137	1746	2015-01-02	2015-02-15 00:00:00	624	1
5138	1586	2014-10-02	2015-02-15 00:00:00	625	1
5139	1589	2014-11-02	2015-02-15 00:00:00	625	1
5140	1594	2014-12-02	2015-02-15 00:00:00	625	1
5141	1603	2015-01-02	2015-02-15 00:00:00	625	1
5142	904	2014-10-02	2015-02-15 00:00:00	626	1
5143	915	2014-11-02	2015-02-15 00:00:00	626	1
5144	924	2014-12-02	2015-02-15 00:00:00	626	1
5145	934	2015-01-02	2015-02-15 00:00:00	626	1
5146	1400	2014-10-02	2015-02-15 00:00:00	627	1
5147	1407	2014-11-02	2015-02-15 00:00:00	627	1
5148	1416	2014-12-02	2015-02-15 00:00:00	627	1
5149	1429	2015-01-02	2015-02-15 00:00:00	627	1
5150	1706	2014-10-02	2015-02-15 00:00:00	628	1
5151	1701	2014-11-02	2015-02-15 00:00:00	628	1
5152	1707	2014-12-02	2015-02-15 00:00:00	628	1
5153	1708	2015-01-02	2015-02-15 00:00:00	628	1
5154	883	2014-10-02	2015-02-15 00:00:00	629	1
5155	893	2014-11-02	2015-02-15 00:00:00	629	1
5156	906	2014-12-02	2015-02-15 00:00:00	629	1
5157	919	2015-01-02	2015-02-15 00:00:00	629	1
5158	1731	2014-10-02	2015-02-15 00:00:00	630	1
5159	1739	2014-11-02	2015-02-15 00:00:00	630	1
5160	1751	2014-12-02	2015-02-15 00:00:00	630	1
5161	1759	2015-01-02	2015-02-15 00:00:00	630	1
5162	1211	2014-10-02	2015-02-15 00:00:00	631	1
5163	1214	2014-11-02	2015-02-15 00:00:00	631	1
5164	1221	2014-12-02	2015-02-15 00:00:00	631	1
5165	1230	2015-01-02	2015-02-15 00:00:00	631	1
5166	1301	2014-10-02	2015-02-15 00:00:00	632	1
5167	1323	2014-11-02	2015-02-15 00:00:00	632	1
5168	1346	2014-12-02	2015-02-15 00:00:00	632	1
5169	1371	2015-01-02	2015-02-15 00:00:00	632	1
5170	1602	2014-10-02	2015-02-15 00:00:00	633	1
5171	1613	2014-11-02	2015-02-15 00:00:00	633	1
5172	1627	2014-12-02	2015-02-15 00:00:00	633	1
5173	1641	2015-01-02	2015-02-15 00:00:00	633	1
5174	564	2014-10-02	2015-02-15 00:00:00	634	1
5175	582	2014-11-02	2015-02-15 00:00:00	634	1
5176	595	2014-12-02	2015-02-15 00:00:00	634	1
5177	615	2015-01-02	2015-02-15 00:00:00	634	1
5178	1535	2014-10-02	2015-02-15 00:00:00	635	1
5179	1544	2014-11-02	2015-02-15 00:00:00	635	1
5180	1556	2014-12-02	2015-02-15 00:00:00	635	1
5181	1577	2015-01-02	2015-02-15 00:00:00	635	1
5182	0	2014-10-02	2015-02-15 00:00:00	636	1
5183	0	2014-11-02	2015-02-15 00:00:00	636	1
5184	0	2014-12-02	2015-02-15 00:00:00	636	1
5185	0	2015-01-02	2015-02-15 00:00:00	636	1
5186	72	2014-10-02	2015-02-15 00:00:00	637	1
5187	79	2014-11-02	2015-02-15 00:00:00	637	1
5188	90	2014-12-02	2015-02-15 00:00:00	637	1
5189	100	2015-01-02	2015-02-15 00:00:00	637	1
5190	1535	2014-10-02	2015-02-15 00:00:00	638	1
5191	1548	2014-11-02	2015-02-15 00:00:00	638	1
5192	1561	2014-12-02	2015-02-15 00:00:00	638	1
5193	1578	2015-01-02	2015-02-15 00:00:00	638	1
5194	637	2014-10-02	2015-02-15 00:00:00	639	1
5195	649	2014-11-02	2015-02-15 00:00:00	639	1
5196	661	2014-12-02	2015-02-15 00:00:00	639	1
5197	676	2015-01-02	2015-02-15 00:00:00	639	1
5198	82	2014-10-02	2015-02-15 00:00:00	640	1
5199	82	2014-11-02	2015-02-15 00:00:00	640	1
5200	82	2014-12-02	2015-02-15 00:00:00	640	1
5201	82	2015-01-02	2015-02-15 00:00:00	640	1
5202	1213	2014-10-02	2015-02-15 00:00:00	641	1
5203	1226	2014-11-02	2015-02-15 00:00:00	641	1
5204	1239	2014-12-02	2015-02-15 00:00:00	641	1
5205	1256	2015-01-02	2015-02-15 00:00:00	641	1
5206	0	2014-10-02	2015-02-15 00:00:00	642	1
5207	0	2014-11-02	2015-02-15 00:00:00	642	1
5208	0	2014-12-02	2015-02-15 00:00:00	642	1
5209	0	2015-01-02	2015-02-15 00:00:00	642	1
5210	0	2014-10-02	2015-02-15 00:00:00	643	1
5211	0	2014-11-02	2015-02-15 00:00:00	643	1
5212	0	2014-12-02	2015-02-15 00:00:00	643	1
5213	0	2015-01-02	2015-02-15 00:00:00	643	1
5214	0	2014-10-02	2015-02-15 00:00:00	644	1
5215	0	2014-11-02	2015-02-15 00:00:00	644	1
5216	0	2014-12-02	2015-02-15 00:00:00	644	1
5217	0	2015-01-02	2015-02-15 00:00:00	644	1
5218	759	2014-10-02	2015-02-15 00:00:00	645	1
5219	759	2014-11-02	2015-02-15 00:00:00	645	1
5220	759	2014-12-02	2015-02-15 00:00:00	645	1
5221	759	2015-01-02	2015-02-15 00:00:00	645	1
5222	0	2014-10-02	2015-02-15 00:00:00	646	1
5223	0	2014-11-02	2015-02-15 00:00:00	646	1
5224	0	2014-12-02	2015-02-15 00:00:00	646	1
5225	0	2015-01-02	2015-02-15 00:00:00	646	1
5226	376	2014-10-02	2015-02-15 00:00:00	647	1
5227	402	2014-11-02	2015-02-15 00:00:00	647	1
5228	430	2014-12-02	2015-02-15 00:00:00	647	1
5229	470	2015-01-02	2015-02-15 00:00:00	647	1
5230	756	2014-10-02	2015-02-15 00:00:00	648	1
5231	756	2014-11-02	2015-02-15 00:00:00	648	1
5232	756	2014-12-02	2015-02-15 00:00:00	648	1
5233	756	2015-01-02	2015-02-15 00:00:00	648	1
5234	1067	2014-10-02	2015-02-15 00:00:00	649	1
5235	1067	2014-11-02	2015-02-15 00:00:00	649	1
5236	1067	2014-12-02	2015-02-15 00:00:00	649	1
5237	1067	2015-01-02	2015-02-15 00:00:00	649	1
5238	1573	2014-10-02	2015-02-15 00:00:00	650	1
5239	1585	2014-11-02	2015-02-15 00:00:00	650	1
5240	1597	2014-12-02	2015-02-15 00:00:00	650	1
5241	1615	2015-01-02	2015-02-15 00:00:00	650	1
5242	0	2014-10-02	2015-02-15 00:00:00	651	1
5243	0	2014-11-02	2015-02-15 00:00:00	651	1
5244	0	2014-12-02	2015-02-15 00:00:00	651	1
5245	0	2015-01-02	2015-02-15 00:00:00	651	1
5246	0	2014-10-02	2015-02-15 00:00:00	652	1
5247	0	2014-11-02	2015-02-15 00:00:00	652	1
5248	0	2014-12-02	2015-02-15 00:00:00	652	1
5249	0	2015-01-02	2015-02-15 00:00:00	652	1
5250	637	2014-10-02	2015-02-15 00:00:00	653	1
5251	637	2014-11-02	2015-02-15 00:00:00	653	1
5252	637	2014-12-02	2015-02-15 00:00:00	653	1
5253	638	2015-01-02	2015-02-15 00:00:00	653	1
5254	0	2014-10-02	2015-02-15 00:00:00	654	1
5255	0	2014-11-02	2015-02-15 00:00:00	654	1
5256	0	2014-12-02	2015-02-15 00:00:00	654	1
5257	0	2015-01-02	2015-02-15 00:00:00	654	1
5258	288	2014-10-02	2015-02-15 00:00:00	655	1
5259	294	2014-11-02	2015-02-15 00:00:00	655	1
5260	300	2014-12-02	2015-02-15 00:00:00	655	1
5261	308	2015-01-02	2015-02-15 00:00:00	655	1
5262	456	2014-10-02	2015-02-15 00:00:00	656	1
5263	480	2014-11-02	2015-02-15 00:00:00	656	1
5264	501	2014-12-02	2015-02-15 00:00:00	656	1
5265	527	2015-01-02	2015-02-15 00:00:00	656	1
5266	210	2014-10-02	2015-02-15 00:00:00	657	1
5267	215	2014-11-02	2015-02-15 00:00:00	657	1
5268	221	2014-12-02	2015-02-15 00:00:00	657	1
5269	236	2015-01-02	2015-02-15 00:00:00	657	1
5270	958	2014-10-02	2015-02-15 00:00:00	658	1
5271	962	2014-11-02	2015-02-15 00:00:00	658	1
5272	971	2014-12-02	2015-02-15 00:00:00	658	1
5273	979	2015-01-02	2015-02-15 00:00:00	658	1
5274	96	2014-10-02	2015-02-15 00:00:00	659	1
5275	97	2014-11-02	2015-02-15 00:00:00	659	1
5276	98	2014-12-02	2015-02-15 00:00:00	659	1
5277	101	2015-01-02	2015-02-15 00:00:00	659	1
5278	144	2014-10-02	2015-02-15 00:00:00	660	1
5279	148	2014-11-02	2015-02-15 00:00:00	660	1
5280	150	2014-12-02	2015-02-15 00:00:00	660	1
5281	154	2015-01-02	2015-02-15 00:00:00	660	1
5282	212	2014-10-02	2015-02-15 00:00:00	661	1
5283	225	2014-11-02	2015-02-15 00:00:00	661	1
5284	240	2014-12-02	2015-02-15 00:00:00	661	1
5285	253	2015-01-02	2015-02-15 00:00:00	661	1
5286	143	2014-10-02	2015-02-15 00:00:00	662	1
5287	151	2014-11-02	2015-02-15 00:00:00	662	1
5288	159	2014-12-02	2015-02-15 00:00:00	662	1
5289	169	2015-01-02	2015-02-15 00:00:00	662	1
5290	176	2014-10-02	2015-02-15 00:00:00	663	1
5291	184	2014-11-02	2015-02-15 00:00:00	663	1
5292	192	2014-12-02	2015-02-15 00:00:00	663	1
5293	202	2015-01-02	2015-02-15 00:00:00	663	1
5294	258	2014-10-02	2015-02-15 00:00:00	664	1
5295	266	2014-11-02	2015-02-15 00:00:00	664	1
5296	277	2014-12-02	2015-02-15 00:00:00	664	1
5297	290	2015-01-02	2015-02-15 00:00:00	664	1
5298	20	2014-10-02	2015-02-15 00:00:00	665	1
5299	39	2014-11-02	2015-02-15 00:00:00	665	1
5300	61	2014-12-02	2015-02-15 00:00:00	665	1
5301	83	2015-01-02	2015-02-15 00:00:00	665	1
5302	177	2014-10-02	2015-02-15 00:00:00	666	1
5303	183	2014-11-02	2015-02-15 00:00:00	666	1
5304	188	2014-12-02	2015-02-15 00:00:00	666	1
5305	197	2015-01-02	2015-02-15 00:00:00	666	1
5306	174	2014-10-02	2015-02-15 00:00:00	667	1
5307	177	2014-11-02	2015-02-15 00:00:00	667	1
5308	179	2014-12-02	2015-02-15 00:00:00	667	1
5309	181	2015-01-02	2015-02-15 00:00:00	667	1
5310	111	2014-10-02	2015-02-15 00:00:00	668	1
5311	115	2014-11-02	2015-02-15 00:00:00	668	1
5312	121	2014-12-02	2015-02-15 00:00:00	668	1
5313	128	2015-01-02	2015-02-15 00:00:00	668	1
5314	265	2014-10-02	2015-02-15 00:00:00	669	1
5315	285	2014-11-02	2015-02-15 00:00:00	669	1
5316	307	2014-12-02	2015-02-15 00:00:00	669	1
5317	330	2015-01-02	2015-02-15 00:00:00	669	1
5318	144	2014-10-02	2015-02-15 00:00:00	670	1
5319	156	2014-11-02	2015-02-15 00:00:00	670	1
5321	173	2015-01-02	2015-02-15 00:00:00	670	1
5322	86	2014-10-02	2015-02-15 00:00:00	671	1
5323	86	2014-11-02	2015-02-15 00:00:00	671	1
5324	86	2014-12-02	2015-02-15 00:00:00	671	1
5325	91	2015-01-02	2015-02-15 00:00:00	671	1
5326	0	2014-10-02	2015-02-15 00:00:00	672	1
5327	0	2014-11-02	2015-02-15 00:00:00	672	1
5328	0	2014-12-02	2015-02-15 00:00:00	672	1
5329	0	2015-01-02	2015-02-15 00:00:00	672	1
5330	236	2014-10-02	2015-02-15 00:00:00	673	1
5331	249	2014-11-02	2015-02-15 00:00:00	673	1
5332	262	2014-12-02	2015-02-15 00:00:00	673	1
5333	276	2015-01-02	2015-02-15 00:00:00	673	1
5334	139	2014-10-02	2015-02-15 00:00:00	674	1
5335	146	2014-11-02	2015-02-15 00:00:00	674	1
5336	154	2014-12-02	2015-02-15 00:00:00	674	1
5337	161	2015-01-02	2015-02-15 00:00:00	674	1
5338	192	2014-10-02	2015-02-15 00:00:00	675	1
5339	202	2014-11-02	2015-02-15 00:00:00	675	1
5340	211	2014-12-02	2015-02-15 00:00:00	675	1
5341	221	2015-01-02	2015-02-15 00:00:00	675	1
5342	307	2014-10-02	2015-02-15 00:00:00	676	1
5343	329	2014-11-02	2015-02-15 00:00:00	676	1
5344	350	2014-12-02	2015-02-15 00:00:00	676	1
5345	372	2015-01-02	2015-02-15 00:00:00	676	1
5346	344	2014-10-02	2015-02-15 00:00:00	677	1
5347	361	2014-11-02	2015-02-15 00:00:00	677	1
5348	382	2014-12-02	2015-02-15 00:00:00	677	1
5349	407	2015-01-02	2015-02-15 00:00:00	677	1
5350	18	2014-10-02	2015-02-15 00:00:00	678	1
5351	18	2014-11-02	2015-02-15 00:00:00	678	1
5352	18	2014-12-02	2015-02-15 00:00:00	678	1
5353	18	2015-01-02	2015-02-15 00:00:00	678	1
5354	93	2014-10-02	2015-02-15 00:00:00	679	1
5355	95	2014-11-02	2015-02-15 00:00:00	679	1
5356	95	2014-12-02	2015-02-15 00:00:00	679	1
5357	97	2015-01-02	2015-02-15 00:00:00	679	1
5358	48	2014-10-02	2015-02-15 00:00:00	680	1
5359	50	2014-11-02	2015-02-15 00:00:00	680	1
5360	53	2014-12-02	2015-02-15 00:00:00	680	1
5361	57	2015-01-02	2015-02-15 00:00:00	680	1
5362	151	2014-10-02	2015-02-15 00:00:00	681	1
5363	161	2014-11-02	2015-02-15 00:00:00	681	1
5364	172	2014-12-02	2015-02-15 00:00:00	681	1
5365	184	2015-01-02	2015-02-15 00:00:00	681	1
5366	267	2014-10-02	2015-02-15 00:00:00	682	1
5367	278	2014-11-02	2015-02-15 00:00:00	682	1
5368	297	2014-12-02	2015-02-15 00:00:00	682	1
5369	326	2015-01-02	2015-02-15 00:00:00	682	1
5370	185	2014-10-02	2015-02-15 00:00:00	683	1
5371	207	2014-11-02	2015-02-15 00:00:00	683	1
5372	226	2014-12-02	2015-02-15 00:00:00	683	1
5373	246	2015-01-02	2015-02-15 00:00:00	683	1
5374	60	2014-10-02	2015-02-15 00:00:00	684	1
5375	69	2014-11-02	2015-02-15 00:00:00	684	1
5376	87	2014-12-02	2015-02-15 00:00:00	684	1
5377	103	2015-01-02	2015-02-15 00:00:00	684	1
5378	0	2014-10-02	2015-02-15 00:00:00	685	1
5379	0	2014-11-02	2015-02-15 00:00:00	685	1
5380	0	2014-12-02	2015-02-15 00:00:00	685	1
5381	0	2015-01-02	2015-02-15 00:00:00	685	1
5382	0	2014-10-02	2015-02-15 00:00:00	686	1
5383	0	2014-11-02	2015-02-15 00:00:00	686	1
5384	0	2014-12-02	2015-02-15 00:00:00	686	1
5385	6	2015-01-02	2015-02-15 00:00:00	686	1
5386	0	2014-10-02	2015-02-15 00:00:00	687	1
5387	0	2014-11-02	2015-02-15 00:00:00	687	1
5388	0	2014-12-02	2015-02-15 00:00:00	687	1
5389	0	2015-01-02	2015-02-15 00:00:00	687	1
5390	46	2014-10-02	2015-02-15 00:00:00	688	1
5391	53	2014-11-02	2015-02-15 00:00:00	688	1
5392	60	2014-12-02	2015-02-15 00:00:00	688	1
5393	68	2015-01-02	2015-02-15 00:00:00	688	1
5394	93	2014-10-02	2015-02-15 00:00:00	689	1
5395	102	2014-11-02	2015-02-15 00:00:00	689	1
5396	115	2014-12-02	2015-02-15 00:00:00	689	1
5397	125	2015-01-02	2015-02-15 00:00:00	689	1
5398	44	2014-10-02	2015-02-15 00:00:00	690	1
5399	54	2014-11-02	2015-02-15 00:00:00	690	1
5400	64	2014-12-02	2015-02-15 00:00:00	690	1
5401	76	2015-01-02	2015-02-15 00:00:00	690	1
5402	84	2014-10-02	2015-02-15 00:00:00	691	1
5403	93	2014-11-02	2015-02-15 00:00:00	691	1
5404	107	2014-12-02	2015-02-15 00:00:00	691	1
5405	123	2015-01-02	2015-02-15 00:00:00	691	1
5406	18	2014-10-02	2015-02-15 00:00:00	692	1
5407	18	2014-11-02	2015-02-15 00:00:00	692	1
5408	18	2014-12-02	2015-02-15 00:00:00	692	1
5409	18	2015-01-02	2015-02-15 00:00:00	692	1
5410	81	2014-10-02	2015-02-15 00:00:00	693	1
5411	92	2014-11-02	2015-02-15 00:00:00	693	1
5412	107	2014-12-02	2015-02-15 00:00:00	693	1
5413	121	2015-01-02	2015-02-15 00:00:00	693	1
5414	63	2014-10-02	2015-02-15 00:00:00	694	1
5415	66	2014-11-02	2015-02-15 00:00:00	694	1
5416	69	2014-12-02	2015-02-15 00:00:00	694	1
5417	72	2015-01-02	2015-02-15 00:00:00	694	1
5418	109	2014-10-02	2015-02-15 00:00:00	695	1
5419	120	2014-11-02	2015-02-15 00:00:00	695	1
5420	133	2014-12-02	2015-02-15 00:00:00	695	1
5421	147	2015-01-02	2015-02-15 00:00:00	695	1
5422	104	2014-10-02	2015-02-15 00:00:00	696	1
5423	116	2014-11-02	2015-02-15 00:00:00	696	1
5424	134	2014-12-02	2015-02-15 00:00:00	696	1
5425	151	2015-01-02	2015-02-15 00:00:00	696	1
5426	87	2014-10-02	2015-02-15 00:00:00	697	1
5427	98	2014-11-02	2015-02-15 00:00:00	697	1
5428	111	2014-12-02	2015-02-15 00:00:00	697	1
5429	122	2015-01-02	2015-02-15 00:00:00	697	1
5430	10	2014-10-02	2015-02-15 00:00:00	698	1
5431	10	2014-11-02	2015-02-15 00:00:00	698	1
5432	10	2014-12-02	2015-02-15 00:00:00	698	1
5433	10	2015-01-02	2015-02-15 00:00:00	698	1
5434	0	2014-10-02	2015-02-15 00:00:00	699	1
5435	0	2014-11-02	2015-02-15 00:00:00	699	1
5436	0	2014-12-02	2015-02-15 00:00:00	699	1
5437	0	2015-01-02	2015-02-15 00:00:00	699	1
5438	64	2014-10-02	2015-02-15 00:00:00	700	1
5439	73	2014-11-02	2015-02-15 00:00:00	700	1
5440	83	2014-12-02	2015-02-15 00:00:00	700	1
5441	92	2015-01-02	2015-02-15 00:00:00	700	1
5442	77	2014-10-02	2015-02-15 00:00:00	701	1
5443	94	2014-11-02	2015-02-15 00:00:00	701	1
5444	107	2014-12-02	2015-02-15 00:00:00	701	1
5445	118	2015-01-02	2015-02-15 00:00:00	701	1
5446	43	2014-10-02	2015-02-15 00:00:00	702	1
5447	47	2014-11-02	2015-02-15 00:00:00	702	1
5448	53	2014-12-02	2015-02-15 00:00:00	702	1
5449	61	2015-01-02	2015-02-15 00:00:00	702	1
5450	29	2014-10-02	2015-02-15 00:00:00	703	1
5451	29	2014-11-02	2015-02-15 00:00:00	703	1
5452	32	2014-12-02	2015-02-15 00:00:00	703	1
5453	33	2015-01-02	2015-02-15 00:00:00	703	1
5454	81	2014-10-02	2015-02-15 00:00:00	704	1
5455	93	2014-11-02	2015-02-15 00:00:00	704	1
5456	107	2014-12-02	2015-02-15 00:00:00	704	1
5457	133	2015-01-02	2015-02-15 00:00:00	704	1
5458	17	2014-10-02	2015-02-15 00:00:00	705	1
5459	19	2014-11-02	2015-02-15 00:00:00	705	1
5460	21	2014-12-02	2015-02-15 00:00:00	705	1
5461	22	2015-01-02	2015-02-15 00:00:00	705	1
5462	62	2014-10-02	2015-02-15 00:00:00	706	1
5463	73	2014-11-02	2015-02-15 00:00:00	706	1
5464	81	2014-12-02	2015-02-15 00:00:00	706	1
5465	90	2015-01-02	2015-02-15 00:00:00	706	1
5466	16	2014-10-02	2015-02-15 00:00:00	707	1
5467	19	2014-11-02	2015-02-15 00:00:00	707	1
5468	23	2014-12-02	2015-02-15 00:00:00	707	1
5469	27	2015-01-02	2015-02-15 00:00:00	707	1
5470	11	2014-10-02	2015-02-15 00:00:00	708	1
5471	18	2014-11-02	2015-02-15 00:00:00	708	1
5472	27	2014-12-02	2015-02-15 00:00:00	708	1
5473	38	2015-01-02	2015-02-15 00:00:00	708	1
5474	0	2014-10-02	2015-02-15 00:00:00	709	1
5475	0	2014-11-02	2015-02-15 00:00:00	709	1
5476	0	2014-12-02	2015-02-15 00:00:00	709	1
5477	9	2015-01-02	2015-02-15 00:00:00	709	1
5478	0	2014-10-02	2015-02-15 00:00:00	710	1
5479	0	2014-11-02	2015-02-15 00:00:00	710	1
5480	0	2014-12-02	2015-02-15 00:00:00	710	1
5481	18	2015-01-02	2015-02-15 00:00:00	710	1
5482	0	2014-10-02	2015-02-15 00:00:00	711	1
5483	0	2014-11-02	2015-02-15 00:00:00	711	1
5484	0	2014-12-02	2015-02-15 00:00:00	711	1
5485	5	2015-01-02	2015-02-15 00:00:00	711	1
5486	0	2014-10-02	2015-02-15 00:00:00	712	1
5487	0	2014-11-02	2015-02-15 00:00:00	712	1
5488	0	2014-12-02	2015-02-15 00:00:00	712	1
5489	1	2015-01-02	2015-02-15 00:00:00	712	1
5490	0	2014-10-02	2015-02-15 00:00:00	713	1
5491	0	2014-11-02	2015-02-15 00:00:00	713	1
5492	0	2014-12-02	2015-02-15 00:00:00	713	1
5493	6	2015-01-02	2015-02-15 00:00:00	713	1
5494	0	2014-10-02	2015-02-15 00:00:00	714	1
5495	450	2014-11-02	2015-02-15 00:00:00	714	1
5496	452	2014-12-02	2015-02-15 00:00:00	714	1
5497	458	2015-01-02	2015-02-15 00:00:00	714	1
\.


--
-- TOC entry 2663 (class 0 OID 0)
-- Dependencies: 207
-- Name: scr_lectura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_lectura_id_seq', 5497, true);


--
-- TOC entry 2664 (class 0 OID 0)
-- Dependencies: 209
-- Name: scr_lin_estrateg_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_lin_estrateg_id_seq', 1, false);


--
-- TOC entry 2549 (class 0 OID 17510)
-- Dependencies: 208 2590
-- Data for Name: scr_linea_estrategica; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_linea_estrategica (id, organizacion_id, "lEstrategicaNombre", "lEstrategicaDescripcion", "lEstrategicaInicio", "lEstrategicaFin", linea_estrategica_id) FROM stdin;
\.


--
-- TOC entry 2551 (class 0 OID 17520)
-- Dependencies: 210 2590
-- Data for Name: scr_linea_proyecto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_linea_proyecto (linea_estrategica_id, proyecto_id) FROM stdin;
\.


--
-- TOC entry 2552 (class 0 OID 17523)
-- Dependencies: 211 2590
-- Data for Name: scr_localidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_localidad (id, localidad_nombre, localidad_descripcion, localidad_id, localidad_lat, localidad_lon) FROM stdin;
2	San Salvador	\N	1	0	0
1	El Salvador	\N	\N	0	0
5	Ahuachapán	Ahuachapán	1	0	0
6	Santa Ana	Santa Ana	1	0	0
7	Sonsonate	Sonsonate	1	0	0
8	Usulután	Usulután	1	0	0
9	San Miguel	San Miguel	1	0	0
10	Morazán	Morazán	1	0	0
11	La Unión	La Unión	1	0	0
12	Chalatenango	Chalatenango	1	0	0
15	La Paz	La Paz	1	0	0
16	Cabañas	Cabañas	1	0	0
19	San Vicente	San Vicente	1	0	0
21	test	s	5	0	0
3	Suchitoto	Municipio general	13	13.9297339999999998	-89.0470650000000035
13	Cuscatlán	Cuscatlán	1	13.8319150000000004	-89.0262780000000049
4	Comunidad Valle Verde	Comunidad Valle Verde	3	13.9754299999999994	-89.066157000000004
17	Comunidad La mora	la mora	3	13.9255379999999995	-89.0478590000000025
18	Comunidad Nuevo Renacer	Nuevo Renacer	3	13.9385560000000002	-89.0774689999999936
22	Soyapango	Municipio de densidad nacional de #### 	2	3	3
20	Comunidad San Antonio del Monte		3	13.9500309999999992	-89.0686070000000001
24	Comunidad Santa Fé	Santa Fé	3	13.9328500000000002	-89.0429220000000043
23	Comunidad San Pablo el Cereto	El Cereto	3	13.9411389999999997	-89.0740360000000067
14	Comunidad El Sitio Zapotal	El sitio Zapotal	3	13.9515089999999997	-89.073724999999996
\.


--
-- TOC entry 2665 (class 0 OID 0)
-- Dependencies: 212
-- Name: scr_localidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_localidad_id_seq', 24, true);


--
-- TOC entry 2554 (class 0 OID 17531)
-- Dependencies: 213 2590
-- Data for Name: scr_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_log (id, src_fecha, src_descripcion, usuario_id) FROM stdin;
\.


--
-- TOC entry 2555 (class 0 OID 17537)
-- Dependencies: 214 2590
-- Data for Name: scr_marca_produc; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_marca_produc (id, "marcaProducNombre", "marcaProducDescrip") FROM stdin;
\.


--
-- TOC entry 2666 (class 0 OID 0)
-- Dependencies: 215
-- Name: scr_marca_produc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_marca_produc_id_seq', 1, false);


--
-- TOC entry 2557 (class 0 OID 17545)
-- Dependencies: 216 2590
-- Data for Name: scr_organizacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_organizacion (id, "organizacionNombre", "organizacionDescripcion", localidad_id) FROM stdin;
1	ACRASAME- ZP	acrasame_zp@hotmail.com	1
\.


--
-- TOC entry 2667 (class 0 OID 0)
-- Dependencies: 217
-- Name: scr_organizacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_organizacion_id_seq', 1, true);


--
-- TOC entry 2559 (class 0 OID 17553)
-- Dependencies: 218 2590
-- Data for Name: scr_periodo_representante; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_periodo_representante (organizacion_id, representante_legal_id, "periodoInicio", "periodoFin") FROM stdin;
\.


--
-- TOC entry 2560 (class 0 OID 17559)
-- Dependencies: 219 2590
-- Data for Name: scr_presen_produc; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_presen_produc (id, "presenProducNombre", "presenProducDescrip") FROM stdin;
\.


--
-- TOC entry 2668 (class 0 OID 0)
-- Dependencies: 220
-- Name: scr_presen_produc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_presen_produc_id_seq', 1, false);


--
-- TOC entry 2562 (class 0 OID 17567)
-- Dependencies: 221 2590
-- Data for Name: scr_producto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_producto (id, "productoNombre", "productoDescripcion", marca_id, "catProduc_id", u_medida_id, presentacion_id, "catDepresiacion_id", "productoComprobante", proveedor_id, "productoCodigo") FROM stdin;
\.


--
-- TOC entry 2563 (class 0 OID 17573)
-- Dependencies: 222 2590
-- Data for Name: scr_producto_area; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_producto_area (producto_id, "areaTrabajo_id") FROM stdin;
\.


--
-- TOC entry 2669 (class 0 OID 0)
-- Dependencies: 223
-- Name: scr_producto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_producto_id_seq', 1, false);


--
-- TOC entry 2565 (class 0 OID 17578)
-- Dependencies: 224 2590
-- Data for Name: scr_proveedor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_proveedor (id, "proveedorNombre", "proveedorDescripcion") FROM stdin;
\.


--
-- TOC entry 2670 (class 0 OID 0)
-- Dependencies: 225
-- Name: scr_proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_proveedor_id_seq', 1, false);


--
-- TOC entry 2567 (class 0 OID 17586)
-- Dependencies: 226 2590
-- Data for Name: scr_proyecto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_proyecto (id, "proyectoNombre", "proyectoDescrip", cooperante_id) FROM stdin;
\.


--
-- TOC entry 2671 (class 0 OID 0)
-- Dependencies: 227
-- Name: scr_proyecto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_proyecto_id_seq', 1, false);


--
-- TOC entry 2569 (class 0 OID 17594)
-- Dependencies: 228 2590
-- Data for Name: scr_recibo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_recibo (id, recibonumero, recibocuenta, recibosocio, recibolecturax, recibolecturay, recibofecha, usuario_id) FROM stdin;
\.


--
-- TOC entry 2672 (class 0 OID 0)
-- Dependencies: 229
-- Name: scr_recibo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_recibo_id_seq', 1, false);


--
-- TOC entry 2571 (class 0 OID 17602)
-- Dependencies: 230 2590
-- Data for Name: scr_representante_legal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_representante_legal (id, "rLegalNombre", "rLegalApellido", "rLegalTelefono", "rLegalCelular", "rLegalDireccion", "rLegalRegistro", cat_rep_legal_id, "rLegalemail") FROM stdin;
1	José Mario 	Recinos 	23013189	70920015	Presidente de ACRASAME- ZP. vigente 	2014-11-26 19:31:02.128563	3	mario@mailcom
\.


--
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 231
-- Name: scr_representate_legal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_representate_legal_id_seq', 1, true);


--
-- TOC entry 2573 (class 0 OID 17611)
-- Dependencies: 232 2590
-- Data for Name: scr_rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_rol (id, nombrerol, detallerol) FROM stdin;
4	root	Super usuario - SysAdmin
6	administrador	Responsable de el registro de datos
2	directiva	Miembro de la Junta Directiva de la Asociación
3	contador	Acceso a modulo contable
1	socio	Beneficiario de recursos
5	tecnico	Operador
\.


--
-- TOC entry 2574 (class 0 OID 17617)
-- Dependencies: 233 2590
-- Data for Name: scr_rr_ejecucion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_rr_ejecucion (id, solic_rr_id, empleado_id) FROM stdin;
\.


--
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 234
-- Name: scr_rr_ejecucion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_rr_ejecucion_id_seq', 1, false);


--
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 235
-- Name: scr_tip_depresiacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_tip_depresiacion_id_seq', 1, false);


--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 173
-- Name: scr_tipo_actividad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_tipo_actividad_id_seq', 1, false);


--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 236
-- Name: scr_tipo_cooperante_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_tipo_cooperante_id_seq', 1, false);


--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 237
-- Name: scr_tipo_produc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_tipo_produc_id_seq', 1, false);


--
-- TOC entry 2579 (class 0 OID 17628)
-- Dependencies: 238 2590
-- Data for Name: scr_transaccion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_transaccion (id, "transaxSecuencia", cuenta_id, "transaxMonto", "transaxDebeHaber", empleado_id, "transaxRegistro", "transaxFecha", pcontable_id, activa, comentario, "transaxImg") FROM stdin;
1	1	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3307-9] Recibo por consumo de agua"	\N
2	1	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3307-9] Recibo por consumo de agua"	\N
3	2	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3308-14] Recibo por consumo de agua"	\N
4	2	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3308-14] Recibo por consumo de agua"	\N
5	3	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3309-15] Recibo por consumo de agua"	\N
6	3	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3309-15] Recibo por consumo de agua"	\N
7	4	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3310-16] Recibo por consumo de agua"	\N
8	4	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3310-16] Recibo por consumo de agua"	\N
9	5	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3311-17] Recibo por consumo de agua"	\N
10	5	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3311-17] Recibo por consumo de agua"	\N
11	6	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3312-18] Recibo por consumo de agua"	\N
12	6	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3312-18] Recibo por consumo de agua"	\N
13	7	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3313-19] Recibo por consumo de agua"	\N
14	7	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3313-19] Recibo por consumo de agua"	\N
15	8	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3314-20] Recibo por consumo de agua"	\N
16	8	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3314-20] Recibo por consumo de agua"	\N
17	9	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3315-21] Recibo por consumo de agua"	\N
18	9	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3315-21] Recibo por consumo de agua"	\N
19	10	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3316-22] Recibo por consumo de agua"	\N
20	10	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3316-22] Recibo por consumo de agua"	\N
21	11	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3317-23] Recibo por consumo de agua"	\N
22	11	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3317-23] Recibo por consumo de agua"	\N
23	12	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3318-24] Recibo por consumo de agua"	\N
24	12	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3318-24] Recibo por consumo de agua"	\N
25	13	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3319-25] Recibo por consumo de agua"	\N
26	13	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3319-25] Recibo por consumo de agua"	\N
27	14	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3320-26] Recibo por consumo de agua"	\N
28	14	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3320-26] Recibo por consumo de agua"	\N
29	15	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3321-27] Recibo por consumo de agua"	\N
30	15	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3321-27] Recibo por consumo de agua"	\N
31	16	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3322-28] Recibo por consumo de agua"	\N
32	16	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3322-28] Recibo por consumo de agua"	\N
33	17	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3323-29] Recibo por consumo de agua"	\N
34	17	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3323-29] Recibo por consumo de agua"	\N
35	18	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3324-30] Recibo por consumo de agua"	\N
36	18	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3324-30] Recibo por consumo de agua"	\N
37	19	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3325-31] Recibo por consumo de agua"	\N
38	19	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3325-31] Recibo por consumo de agua"	\N
39	20	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3326-32] Recibo por consumo de agua"	\N
40	20	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3326-32] Recibo por consumo de agua"	\N
41	21	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3327-33] Recibo por consumo de agua"	\N
42	21	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3327-33] Recibo por consumo de agua"	\N
43	22	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3328-34] Recibo por consumo de agua"	\N
44	22	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3328-34] Recibo por consumo de agua"	\N
45	23	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3329-35] Recibo por consumo de agua"	\N
46	23	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3329-35] Recibo por consumo de agua"	\N
47	24	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3330-36] Recibo por consumo de agua"	\N
48	24	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3330-36] Recibo por consumo de agua"	\N
49	25	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3331-37] Recibo por consumo de agua"	\N
50	25	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3331-37] Recibo por consumo de agua"	\N
51	26	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3332-38] Recibo por consumo de agua"	\N
52	26	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3332-38] Recibo por consumo de agua"	\N
53	27	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3333-39] Recibo por consumo de agua"	\N
54	27	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3333-39] Recibo por consumo de agua"	\N
55	28	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3334-40] Recibo por consumo de agua"	\N
56	28	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3334-40] Recibo por consumo de agua"	\N
57	29	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3335-41] Recibo por consumo de agua"	\N
58	29	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3335-41] Recibo por consumo de agua"	\N
59	30	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3336-42] Recibo por consumo de agua"	\N
60	30	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3336-42] Recibo por consumo de agua"	\N
61	31	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3337-43] Recibo por consumo de agua"	\N
62	31	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3337-43] Recibo por consumo de agua"	\N
63	32	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3338-44] Recibo por consumo de agua"	\N
64	32	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3338-44] Recibo por consumo de agua"	\N
65	33	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3339-45] Recibo por consumo de agua"	\N
66	33	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3339-45] Recibo por consumo de agua"	\N
67	34	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3340-46] Recibo por consumo de agua"	\N
68	34	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3340-46] Recibo por consumo de agua"	\N
69	35	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3341-47] Recibo por consumo de agua"	\N
70	35	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3341-47] Recibo por consumo de agua"	\N
71	36	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3342-48] Recibo por consumo de agua"	\N
72	36	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3342-48] Recibo por consumo de agua"	\N
73	37	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3343-49] Recibo por consumo de agua"	\N
74	37	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3343-49] Recibo por consumo de agua"	\N
75	38	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3344-50] Recibo por consumo de agua"	\N
76	38	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3344-50] Recibo por consumo de agua"	\N
77	39	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3345-51] Recibo por consumo de agua"	\N
78	39	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3345-51] Recibo por consumo de agua"	\N
79	40	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3346-52] Recibo por consumo de agua"	\N
80	40	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3346-52] Recibo por consumo de agua"	\N
81	41	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3347-53] Recibo por consumo de agua"	\N
82	41	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3347-53] Recibo por consumo de agua"	\N
83	42	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3348-54] Recibo por consumo de agua"	\N
84	42	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3348-54] Recibo por consumo de agua"	\N
85	43	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3349-55] Recibo por consumo de agua"	\N
86	43	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3349-55] Recibo por consumo de agua"	\N
87	44	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3350-56] Recibo por consumo de agua"	\N
88	44	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3350-56] Recibo por consumo de agua"	\N
89	45	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3351-57] Recibo por consumo de agua"	\N
90	45	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3351-57] Recibo por consumo de agua"	\N
91	46	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3352-58] Recibo por consumo de agua"	\N
92	46	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3352-58] Recibo por consumo de agua"	\N
93	47	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3353-59] Recibo por consumo de agua"	\N
94	47	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3353-59] Recibo por consumo de agua"	\N
95	48	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3354-60] Recibo por consumo de agua"	\N
96	48	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3354-60] Recibo por consumo de agua"	\N
97	49	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3355-61] Recibo por consumo de agua"	\N
98	49	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3355-61] Recibo por consumo de agua"	\N
99	50	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3356-62] Recibo por consumo de agua"	\N
100	50	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3356-62] Recibo por consumo de agua"	\N
101	51	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3357-63] Recibo por consumo de agua"	\N
102	51	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3357-63] Recibo por consumo de agua"	\N
103	52	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3358-64] Recibo por consumo de agua"	\N
104	52	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3358-64] Recibo por consumo de agua"	\N
105	53	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3359-65] Recibo por consumo de agua"	\N
106	53	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3359-65] Recibo por consumo de agua"	\N
107	54	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3360-66] Recibo por consumo de agua"	\N
108	54	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3360-66] Recibo por consumo de agua"	\N
109	55	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3361-67] Recibo por consumo de agua"	\N
110	55	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3361-67] Recibo por consumo de agua"	\N
111	56	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3362-68] Recibo por consumo de agua"	\N
112	56	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3362-68] Recibo por consumo de agua"	\N
113	57	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3363-69] Recibo por consumo de agua"	\N
114	57	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3363-69] Recibo por consumo de agua"	\N
115	58	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3364-70] Recibo por consumo de agua"	\N
116	58	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3364-70] Recibo por consumo de agua"	\N
117	59	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3365-71] Recibo por consumo de agua"	\N
118	59	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3365-71] Recibo por consumo de agua"	\N
119	60	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3366-72] Recibo por consumo de agua"	\N
120	60	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3366-72] Recibo por consumo de agua"	\N
121	61	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3367-73] Recibo por consumo de agua"	\N
122	61	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3367-73] Recibo por consumo de agua"	\N
123	62	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3368-74] Recibo por consumo de agua"	\N
124	62	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3368-74] Recibo por consumo de agua"	\N
125	63	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3369-75] Recibo por consumo de agua"	\N
126	63	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3369-75] Recibo por consumo de agua"	\N
127	64	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3370-76] Recibo por consumo de agua"	\N
128	64	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3370-76] Recibo por consumo de agua"	\N
129	65	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3371-77] Recibo por consumo de agua"	\N
130	65	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3371-77] Recibo por consumo de agua"	\N
131	66	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3372-78] Recibo por consumo de agua"	\N
132	66	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3372-78] Recibo por consumo de agua"	\N
133	67	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3373-79] Recibo por consumo de agua"	\N
134	67	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3373-79] Recibo por consumo de agua"	\N
135	68	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3374-80] Recibo por consumo de agua"	\N
136	68	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3374-80] Recibo por consumo de agua"	\N
137	69	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3375-81] Recibo por consumo de agua"	\N
138	69	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3375-81] Recibo por consumo de agua"	\N
139	70	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3376-82] Recibo por consumo de agua"	\N
140	70	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3376-82] Recibo por consumo de agua"	\N
141	71	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3377-83] Recibo por consumo de agua"	\N
142	71	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3377-83] Recibo por consumo de agua"	\N
143	72	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3378-84] Recibo por consumo de agua"	\N
144	72	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3378-84] Recibo por consumo de agua"	\N
145	73	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3379-85] Recibo por consumo de agua"	\N
146	73	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3379-85] Recibo por consumo de agua"	\N
147	74	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3380-86] Recibo por consumo de agua"	\N
148	74	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3380-86] Recibo por consumo de agua"	\N
149	75	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3381-87] Recibo por consumo de agua"	\N
150	75	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3381-87] Recibo por consumo de agua"	\N
151	76	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3382-88] Recibo por consumo de agua"	\N
152	76	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3382-88] Recibo por consumo de agua"	\N
153	77	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3383-89] Recibo por consumo de agua"	\N
154	77	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3383-89] Recibo por consumo de agua"	\N
155	78	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3384-90] Recibo por consumo de agua"	\N
156	78	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3384-90] Recibo por consumo de agua"	\N
157	79	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3385-91] Recibo por consumo de agua"	\N
158	79	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3385-91] Recibo por consumo de agua"	\N
159	80	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3386-92] Recibo por consumo de agua"	\N
160	80	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3386-92] Recibo por consumo de agua"	\N
161	81	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3387-93] Recibo por consumo de agua"	\N
162	81	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3387-93] Recibo por consumo de agua"	\N
163	82	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3388-94] Recibo por consumo de agua"	\N
164	82	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3388-94] Recibo por consumo de agua"	\N
165	83	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3389-95] Recibo por consumo de agua"	\N
166	83	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3389-95] Recibo por consumo de agua"	\N
167	84	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3390-96] Recibo por consumo de agua"	\N
168	84	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3390-96] Recibo por consumo de agua"	\N
169	85	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3391-97] Recibo por consumo de agua"	\N
170	85	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3391-97] Recibo por consumo de agua"	\N
171	86	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3392-98] Recibo por consumo de agua"	\N
172	86	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3392-98] Recibo por consumo de agua"	\N
173	87	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3393-99] Recibo por consumo de agua"	\N
174	87	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3393-99] Recibo por consumo de agua"	\N
175	88	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3394-100] Recibo por consumo de agua"	\N
176	88	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3394-100] Recibo por consumo de agua"	\N
177	89	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3395-101] Recibo por consumo de agua"	\N
178	89	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3395-101] Recibo por consumo de agua"	\N
179	90	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3396-102] Recibo por consumo de agua"	\N
180	90	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3396-102] Recibo por consumo de agua"	\N
181	91	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3397-103] Recibo por consumo de agua"	\N
182	91	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3397-103] Recibo por consumo de agua"	\N
183	92	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3398-104] Recibo por consumo de agua"	\N
184	92	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3398-104] Recibo por consumo de agua"	\N
185	93	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3399-105] Recibo por consumo de agua"	\N
186	93	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3399-105] Recibo por consumo de agua"	\N
187	94	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3400-106] Recibo por consumo de agua"	\N
188	94	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3400-106] Recibo por consumo de agua"	\N
189	95	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3401-107] Recibo por consumo de agua"	\N
190	95	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3401-107] Recibo por consumo de agua"	\N
191	96	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3402-108] Recibo por consumo de agua"	\N
192	96	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3402-108] Recibo por consumo de agua"	\N
193	97	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3403-109] Recibo por consumo de agua"	\N
194	97	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3403-109] Recibo por consumo de agua"	\N
195	98	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3404-110] Recibo por consumo de agua"	\N
196	98	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3404-110] Recibo por consumo de agua"	\N
197	99	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3405-111] Recibo por consumo de agua"	\N
198	99	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3405-111] Recibo por consumo de agua"	\N
199	100	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3406-112] Recibo por consumo de agua"	\N
200	100	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3406-112] Recibo por consumo de agua"	\N
201	101	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3407-113] Recibo por consumo de agua"	\N
202	101	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3407-113] Recibo por consumo de agua"	\N
203	102	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3408-114] Recibo por consumo de agua"	\N
204	102	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3408-114] Recibo por consumo de agua"	\N
205	103	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3409-115] Recibo por consumo de agua"	\N
206	103	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3409-115] Recibo por consumo de agua"	\N
207	104	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3410-116] Recibo por consumo de agua"	\N
208	104	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3410-116] Recibo por consumo de agua"	\N
209	105	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3411-117] Recibo por consumo de agua"	\N
210	105	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3411-117] Recibo por consumo de agua"	\N
211	106	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3412-118] Recibo por consumo de agua"	\N
212	106	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3412-118] Recibo por consumo de agua"	\N
213	107	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3413-119] Recibo por consumo de agua"	\N
214	107	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3413-119] Recibo por consumo de agua"	\N
215	108	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3414-120] Recibo por consumo de agua"	\N
216	108	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3414-120] Recibo por consumo de agua"	\N
217	109	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3415-121] Recibo por consumo de agua"	\N
218	109	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3415-121] Recibo por consumo de agua"	\N
219	110	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3416-122] Recibo por consumo de agua"	\N
220	110	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3416-122] Recibo por consumo de agua"	\N
221	111	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3417-123] Recibo por consumo de agua"	\N
222	111	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3417-123] Recibo por consumo de agua"	\N
223	112	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3418-124] Recibo por consumo de agua"	\N
224	112	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3418-124] Recibo por consumo de agua"	\N
225	113	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3419-125] Recibo por consumo de agua"	\N
226	113	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3419-125] Recibo por consumo de agua"	\N
227	114	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3420-126] Recibo por consumo de agua"	\N
228	114	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3420-126] Recibo por consumo de agua"	\N
229	115	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3421-127] Recibo por consumo de agua"	\N
230	115	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3421-127] Recibo por consumo de agua"	\N
231	116	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3422-128] Recibo por consumo de agua"	\N
232	116	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3422-128] Recibo por consumo de agua"	\N
233	117	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3423-129] Recibo por consumo de agua"	\N
234	117	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3423-129] Recibo por consumo de agua"	\N
235	118	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3424-130] Recibo por consumo de agua"	\N
236	118	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3424-130] Recibo por consumo de agua"	\N
237	119	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3425-131] Recibo por consumo de agua"	\N
238	119	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3425-131] Recibo por consumo de agua"	\N
239	120	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3426-132] Recibo por consumo de agua"	\N
240	120	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3426-132] Recibo por consumo de agua"	\N
241	121	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3427-133] Recibo por consumo de agua"	\N
242	121	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3427-133] Recibo por consumo de agua"	\N
243	122	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3428-134] Recibo por consumo de agua"	\N
244	122	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3428-134] Recibo por consumo de agua"	\N
245	123	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3429-135] Recibo por consumo de agua"	\N
246	123	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3429-135] Recibo por consumo de agua"	\N
247	124	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3430-136] Recibo por consumo de agua"	\N
248	124	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3430-136] Recibo por consumo de agua"	\N
249	125	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3431-137] Recibo por consumo de agua"	\N
250	125	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3431-137] Recibo por consumo de agua"	\N
251	126	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3432-138] Recibo por consumo de agua"	\N
252	126	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3432-138] Recibo por consumo de agua"	\N
253	127	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3433-139] Recibo por consumo de agua"	\N
254	127	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3433-139] Recibo por consumo de agua"	\N
255	128	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3434-140] Recibo por consumo de agua"	\N
256	128	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3434-140] Recibo por consumo de agua"	\N
257	129	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3435-141] Recibo por consumo de agua"	\N
258	129	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3435-141] Recibo por consumo de agua"	\N
259	130	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3436-142] Recibo por consumo de agua"	\N
260	130	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3436-142] Recibo por consumo de agua"	\N
261	131	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3437-143] Recibo por consumo de agua"	\N
262	131	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3437-143] Recibo por consumo de agua"	\N
263	132	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3438-144] Recibo por consumo de agua"	\N
264	132	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3438-144] Recibo por consumo de agua"	\N
265	133	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3439-145] Recibo por consumo de agua"	\N
266	133	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3439-145] Recibo por consumo de agua"	\N
267	134	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3440-146] Recibo por consumo de agua"	\N
268	134	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3440-146] Recibo por consumo de agua"	\N
269	135	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3441-147] Recibo por consumo de agua"	\N
270	135	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3441-147] Recibo por consumo de agua"	\N
271	136	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3442-148] Recibo por consumo de agua"	\N
272	136	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3442-148] Recibo por consumo de agua"	\N
273	137	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3443-149] Recibo por consumo de agua"	\N
274	137	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3443-149] Recibo por consumo de agua"	\N
275	138	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3444-150] Recibo por consumo de agua"	\N
276	138	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3444-150] Recibo por consumo de agua"	\N
277	139	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3445-151] Recibo por consumo de agua"	\N
278	139	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3445-151] Recibo por consumo de agua"	\N
279	140	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3446-152] Recibo por consumo de agua"	\N
280	140	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3446-152] Recibo por consumo de agua"	\N
281	141	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3447-153] Recibo por consumo de agua"	\N
282	141	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3447-153] Recibo por consumo de agua"	\N
283	142	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3448-154] Recibo por consumo de agua"	\N
284	142	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3448-154] Recibo por consumo de agua"	\N
285	143	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3449-155] Recibo por consumo de agua"	\N
286	143	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3449-155] Recibo por consumo de agua"	\N
287	144	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3450-156] Recibo por consumo de agua"	\N
288	144	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3450-156] Recibo por consumo de agua"	\N
289	145	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3451-157] Recibo por consumo de agua"	\N
290	145	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3451-157] Recibo por consumo de agua"	\N
291	146	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3452-158] Recibo por consumo de agua"	\N
292	146	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3452-158] Recibo por consumo de agua"	\N
293	147	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3453-159] Recibo por consumo de agua"	\N
294	147	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3453-159] Recibo por consumo de agua"	\N
295	148	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3454-160] Recibo por consumo de agua"	\N
296	148	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3454-160] Recibo por consumo de agua"	\N
297	149	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3455-161] Recibo por consumo de agua"	\N
298	149	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3455-161] Recibo por consumo de agua"	\N
299	150	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3456-162] Recibo por consumo de agua"	\N
300	150	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3456-162] Recibo por consumo de agua"	\N
301	151	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3457-163] Recibo por consumo de agua"	\N
302	151	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3457-163] Recibo por consumo de agua"	\N
303	152	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3458-164] Recibo por consumo de agua"	\N
304	152	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3458-164] Recibo por consumo de agua"	\N
305	153	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3459-165] Recibo por consumo de agua"	\N
306	153	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3459-165] Recibo por consumo de agua"	\N
307	154	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3460-166] Recibo por consumo de agua"	\N
308	154	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3460-166] Recibo por consumo de agua"	\N
309	155	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3461-167] Recibo por consumo de agua"	\N
310	155	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3461-167] Recibo por consumo de agua"	\N
311	156	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3462-168] Recibo por consumo de agua"	\N
312	156	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3462-168] Recibo por consumo de agua"	\N
313	157	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3463-169] Recibo por consumo de agua"	\N
314	157	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3463-169] Recibo por consumo de agua"	\N
315	158	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3464-170] Recibo por consumo de agua"	\N
316	158	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3464-170] Recibo por consumo de agua"	\N
317	159	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3465-171] Recibo por consumo de agua"	\N
318	159	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3465-171] Recibo por consumo de agua"	\N
319	160	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3466-172] Recibo por consumo de agua"	\N
320	160	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3466-172] Recibo por consumo de agua"	\N
321	161	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3467-173] Recibo por consumo de agua"	\N
322	161	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3467-173] Recibo por consumo de agua"	\N
323	162	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3468-174] Recibo por consumo de agua"	\N
324	162	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3468-174] Recibo por consumo de agua"	\N
325	163	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3469-175] Recibo por consumo de agua"	\N
326	163	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3469-175] Recibo por consumo de agua"	\N
327	164	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3470-176] Recibo por consumo de agua"	\N
328	164	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3470-176] Recibo por consumo de agua"	\N
329	165	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3471-177] Recibo por consumo de agua"	\N
330	165	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3471-177] Recibo por consumo de agua"	\N
331	166	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3472-178] Recibo por consumo de agua"	\N
332	166	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3472-178] Recibo por consumo de agua"	\N
333	167	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3473-179] Recibo por consumo de agua"	\N
334	167	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3473-179] Recibo por consumo de agua"	\N
335	168	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3474-180] Recibo por consumo de agua"	\N
336	168	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3474-180] Recibo por consumo de agua"	\N
337	169	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3475-181] Recibo por consumo de agua"	\N
338	169	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3475-181] Recibo por consumo de agua"	\N
339	170	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3476-182] Recibo por consumo de agua"	\N
340	170	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3476-182] Recibo por consumo de agua"	\N
341	171	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3477-183] Recibo por consumo de agua"	\N
342	171	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3477-183] Recibo por consumo de agua"	\N
343	172	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3478-184] Recibo por consumo de agua"	\N
344	172	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3478-184] Recibo por consumo de agua"	\N
345	173	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3479-185] Recibo por consumo de agua"	\N
346	173	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3479-185] Recibo por consumo de agua"	\N
347	174	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3480-186] Recibo por consumo de agua"	\N
348	174	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3480-186] Recibo por consumo de agua"	\N
349	175	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3481-187] Recibo por consumo de agua"	\N
350	175	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3481-187] Recibo por consumo de agua"	\N
351	176	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3482-188] Recibo por consumo de agua"	\N
352	176	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3482-188] Recibo por consumo de agua"	\N
353	177	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3483-189] Recibo por consumo de agua"	\N
354	177	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3483-189] Recibo por consumo de agua"	\N
355	178	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3484-190] Recibo por consumo de agua"	\N
356	178	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3484-190] Recibo por consumo de agua"	\N
357	179	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3485-191] Recibo por consumo de agua"	\N
358	179	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3485-191] Recibo por consumo de agua"	\N
359	180	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3486-192] Recibo por consumo de agua"	\N
360	180	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3486-192] Recibo por consumo de agua"	\N
361	181	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3487-193] Recibo por consumo de agua"	\N
362	181	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3487-193] Recibo por consumo de agua"	\N
363	182	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3488-194] Recibo por consumo de agua"	\N
364	182	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3488-194] Recibo por consumo de agua"	\N
365	183	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3489-195] Recibo por consumo de agua"	\N
366	183	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3489-195] Recibo por consumo de agua"	\N
367	184	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3490-196] Recibo por consumo de agua"	\N
368	184	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3490-196] Recibo por consumo de agua"	\N
369	185	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3491-197] Recibo por consumo de agua"	\N
370	185	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3491-197] Recibo por consumo de agua"	\N
371	186	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3492-198] Recibo por consumo de agua"	\N
372	186	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3492-198] Recibo por consumo de agua"	\N
373	187	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3493-199] Recibo por consumo de agua"	\N
374	187	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3493-199] Recibo por consumo de agua"	\N
375	188	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3494-200] Recibo por consumo de agua"	\N
376	188	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3494-200] Recibo por consumo de agua"	\N
377	189	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3495-201] Recibo por consumo de agua"	\N
378	189	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3495-201] Recibo por consumo de agua"	\N
379	190	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3496-202] Recibo por consumo de agua"	\N
380	190	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3496-202] Recibo por consumo de agua"	\N
381	191	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3497-203] Recibo por consumo de agua"	\N
382	191	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3497-203] Recibo por consumo de agua"	\N
383	192	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3498-204] Recibo por consumo de agua"	\N
384	192	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3498-204] Recibo por consumo de agua"	\N
385	193	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3499-205] Recibo por consumo de agua"	\N
386	193	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3499-205] Recibo por consumo de agua"	\N
387	194	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3500-206] Recibo por consumo de agua"	\N
388	194	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3500-206] Recibo por consumo de agua"	\N
389	195	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3501-207] Recibo por consumo de agua"	\N
390	195	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3501-207] Recibo por consumo de agua"	\N
391	196	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3502-208] Recibo por consumo de agua"	\N
392	196	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3502-208] Recibo por consumo de agua"	\N
393	197	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3503-209] Recibo por consumo de agua"	\N
394	197	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3503-209] Recibo por consumo de agua"	\N
395	198	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3504-210] Recibo por consumo de agua"	\N
396	198	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3504-210] Recibo por consumo de agua"	\N
397	199	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3505-211] Recibo por consumo de agua"	\N
398	199	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3505-211] Recibo por consumo de agua"	\N
399	200	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3506-212] Recibo por consumo de agua"	\N
400	200	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3506-212] Recibo por consumo de agua"	\N
401	201	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3507-213] Recibo por consumo de agua"	\N
402	201	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3507-213] Recibo por consumo de agua"	\N
403	202	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3508-214] Recibo por consumo de agua"	\N
404	202	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3508-214] Recibo por consumo de agua"	\N
405	203	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3509-215] Recibo por consumo de agua"	\N
406	203	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3509-215] Recibo por consumo de agua"	\N
407	204	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3510-216] Recibo por consumo de agua"	\N
408	204	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3510-216] Recibo por consumo de agua"	\N
409	205	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3511-217] Recibo por consumo de agua"	\N
410	205	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3511-217] Recibo por consumo de agua"	\N
411	206	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3512-218] Recibo por consumo de agua"	\N
412	206	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3512-218] Recibo por consumo de agua"	\N
413	207	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3513-219] Recibo por consumo de agua"	\N
414	207	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3513-219] Recibo por consumo de agua"	\N
415	208	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3514-220] Recibo por consumo de agua"	\N
416	208	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3514-220] Recibo por consumo de agua"	\N
417	209	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3515-221] Recibo por consumo de agua"	\N
418	209	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3515-221] Recibo por consumo de agua"	\N
419	210	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3516-222] Recibo por consumo de agua"	\N
420	210	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3516-222] Recibo por consumo de agua"	\N
421	211	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3517-223] Recibo por consumo de agua"	\N
422	211	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3517-223] Recibo por consumo de agua"	\N
423	212	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3518-224] Recibo por consumo de agua"	\N
424	212	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3518-224] Recibo por consumo de agua"	\N
425	213	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3519-225] Recibo por consumo de agua"	\N
426	213	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3519-225] Recibo por consumo de agua"	\N
427	214	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3520-226] Recibo por consumo de agua"	\N
428	214	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3520-226] Recibo por consumo de agua"	\N
429	215	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3521-227] Recibo por consumo de agua"	\N
430	215	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3521-227] Recibo por consumo de agua"	\N
431	216	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3522-228] Recibo por consumo de agua"	\N
432	216	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3522-228] Recibo por consumo de agua"	\N
433	217	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3523-229] Recibo por consumo de agua"	\N
434	217	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3523-229] Recibo por consumo de agua"	\N
435	218	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3524-230] Recibo por consumo de agua"	\N
436	218	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3524-230] Recibo por consumo de agua"	\N
437	219	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3525-231] Recibo por consumo de agua"	\N
438	219	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3525-231] Recibo por consumo de agua"	\N
439	220	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3526-232] Recibo por consumo de agua"	\N
440	220	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3526-232] Recibo por consumo de agua"	\N
441	221	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3527-233] Recibo por consumo de agua"	\N
442	221	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3527-233] Recibo por consumo de agua"	\N
443	222	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3528-234] Recibo por consumo de agua"	\N
444	222	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3528-234] Recibo por consumo de agua"	\N
445	223	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3529-235] Recibo por consumo de agua"	\N
446	223	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3529-235] Recibo por consumo de agua"	\N
447	224	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3530-236] Recibo por consumo de agua"	\N
448	224	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3530-236] Recibo por consumo de agua"	\N
449	225	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3531-237] Recibo por consumo de agua"	\N
450	225	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3531-237] Recibo por consumo de agua"	\N
451	226	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3532-238] Recibo por consumo de agua"	\N
452	226	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3532-238] Recibo por consumo de agua"	\N
453	227	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3533-239] Recibo por consumo de agua"	\N
454	227	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3533-239] Recibo por consumo de agua"	\N
455	228	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3534-240] Recibo por consumo de agua"	\N
456	228	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3534-240] Recibo por consumo de agua"	\N
457	229	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3535-241] Recibo por consumo de agua"	\N
458	229	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3535-241] Recibo por consumo de agua"	\N
459	230	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3536-242] Recibo por consumo de agua"	\N
460	230	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3536-242] Recibo por consumo de agua"	\N
461	231	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3537-243] Recibo por consumo de agua"	\N
462	231	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3537-243] Recibo por consumo de agua"	\N
463	232	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3538-244] Recibo por consumo de agua"	\N
464	232	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3538-244] Recibo por consumo de agua"	\N
465	233	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3539-245] Recibo por consumo de agua"	\N
466	233	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3539-245] Recibo por consumo de agua"	\N
467	234	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3540-246] Recibo por consumo de agua"	\N
468	234	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3540-246] Recibo por consumo de agua"	\N
469	235	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3541-247] Recibo por consumo de agua"	\N
470	235	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3541-247] Recibo por consumo de agua"	\N
471	236	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3542-248] Recibo por consumo de agua"	\N
472	236	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3542-248] Recibo por consumo de agua"	\N
473	237	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3543-249] Recibo por consumo de agua"	\N
474	237	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3543-249] Recibo por consumo de agua"	\N
475	238	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3544-250] Recibo por consumo de agua"	\N
476	238	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3544-250] Recibo por consumo de agua"	\N
477	239	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3545-251] Recibo por consumo de agua"	\N
478	239	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3545-251] Recibo por consumo de agua"	\N
479	240	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3546-252] Recibo por consumo de agua"	\N
480	240	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3546-252] Recibo por consumo de agua"	\N
481	241	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3547-253] Recibo por consumo de agua"	\N
482	241	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3547-253] Recibo por consumo de agua"	\N
483	242	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3548-254] Recibo por consumo de agua"	\N
484	242	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3548-254] Recibo por consumo de agua"	\N
485	243	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3549-255] Recibo por consumo de agua"	\N
486	243	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3549-255] Recibo por consumo de agua"	\N
487	244	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3550-256] Recibo por consumo de agua"	\N
488	244	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3550-256] Recibo por consumo de agua"	\N
489	245	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3551-257] Recibo por consumo de agua"	\N
490	245	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3551-257] Recibo por consumo de agua"	\N
491	246	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3552-258] Recibo por consumo de agua"	\N
492	246	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3552-258] Recibo por consumo de agua"	\N
493	247	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3553-259] Recibo por consumo de agua"	\N
494	247	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3553-259] Recibo por consumo de agua"	\N
495	248	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3554-260] Recibo por consumo de agua"	\N
496	248	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3554-260] Recibo por consumo de agua"	\N
497	249	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3555-261] Recibo por consumo de agua"	\N
498	249	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3555-261] Recibo por consumo de agua"	\N
499	250	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3556-262] Recibo por consumo de agua"	\N
500	250	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3556-262] Recibo por consumo de agua"	\N
501	251	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3557-263] Recibo por consumo de agua"	\N
502	251	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3557-263] Recibo por consumo de agua"	\N
503	252	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3558-264] Recibo por consumo de agua"	\N
504	252	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3558-264] Recibo por consumo de agua"	\N
505	253	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3559-265] Recibo por consumo de agua"	\N
506	253	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3559-265] Recibo por consumo de agua"	\N
507	254	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3560-266] Recibo por consumo de agua"	\N
508	254	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3560-266] Recibo por consumo de agua"	\N
509	255	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3561-267] Recibo por consumo de agua"	\N
510	255	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3561-267] Recibo por consumo de agua"	\N
511	256	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3562-268] Recibo por consumo de agua"	\N
512	256	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3562-268] Recibo por consumo de agua"	\N
513	257	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3563-269] Recibo por consumo de agua"	\N
514	257	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3563-269] Recibo por consumo de agua"	\N
515	258	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3564-270] Recibo por consumo de agua"	\N
516	258	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3564-270] Recibo por consumo de agua"	\N
517	259	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3565-271] Recibo por consumo de agua"	\N
518	259	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3565-271] Recibo por consumo de agua"	\N
519	260	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3566-272] Recibo por consumo de agua"	\N
520	260	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3566-272] Recibo por consumo de agua"	\N
521	261	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3567-273] Recibo por consumo de agua"	\N
522	261	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3567-273] Recibo por consumo de agua"	\N
523	262	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3568-274] Recibo por consumo de agua"	\N
524	262	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3568-274] Recibo por consumo de agua"	\N
525	263	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3569-275] Recibo por consumo de agua"	\N
526	263	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3569-275] Recibo por consumo de agua"	\N
527	264	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3570-276] Recibo por consumo de agua"	\N
528	264	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3570-276] Recibo por consumo de agua"	\N
529	265	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3571-277] Recibo por consumo de agua"	\N
530	265	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3571-277] Recibo por consumo de agua"	\N
531	266	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3572-278] Recibo por consumo de agua"	\N
532	266	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3572-278] Recibo por consumo de agua"	\N
533	267	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3573-279] Recibo por consumo de agua"	\N
534	267	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3573-279] Recibo por consumo de agua"	\N
535	268	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3574-280] Recibo por consumo de agua"	\N
536	268	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3574-280] Recibo por consumo de agua"	\N
537	269	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3575-281] Recibo por consumo de agua"	\N
538	269	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3575-281] Recibo por consumo de agua"	\N
539	270	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3576-282] Recibo por consumo de agua"	\N
540	270	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3576-282] Recibo por consumo de agua"	\N
541	271	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3577-283] Recibo por consumo de agua"	\N
542	271	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3577-283] Recibo por consumo de agua"	\N
543	272	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3578-284] Recibo por consumo de agua"	\N
544	272	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3578-284] Recibo por consumo de agua"	\N
545	273	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3579-285] Recibo por consumo de agua"	\N
546	273	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3579-285] Recibo por consumo de agua"	\N
547	274	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3580-286] Recibo por consumo de agua"	\N
548	274	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3580-286] Recibo por consumo de agua"	\N
549	275	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3581-287] Recibo por consumo de agua"	\N
550	275	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3581-287] Recibo por consumo de agua"	\N
551	276	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3582-288] Recibo por consumo de agua"	\N
552	276	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3582-288] Recibo por consumo de agua"	\N
553	277	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3583-289] Recibo por consumo de agua"	\N
554	277	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3583-289] Recibo por consumo de agua"	\N
555	278	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3584-290] Recibo por consumo de agua"	\N
556	278	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3584-290] Recibo por consumo de agua"	\N
557	279	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3585-291] Recibo por consumo de agua"	\N
558	279	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3585-291] Recibo por consumo de agua"	\N
559	280	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3586-292] Recibo por consumo de agua"	\N
560	280	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3586-292] Recibo por consumo de agua"	\N
561	281	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3587-293] Recibo por consumo de agua"	\N
562	281	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3587-293] Recibo por consumo de agua"	\N
563	282	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3588-294] Recibo por consumo de agua"	\N
564	282	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3588-294] Recibo por consumo de agua"	\N
565	283	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3589-295] Recibo por consumo de agua"	\N
566	283	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3589-295] Recibo por consumo de agua"	\N
567	284	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3590-296] Recibo por consumo de agua"	\N
568	284	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3590-296] Recibo por consumo de agua"	\N
569	285	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3591-297] Recibo por consumo de agua"	\N
570	285	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3591-297] Recibo por consumo de agua"	\N
571	286	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3592-298] Recibo por consumo de agua"	\N
572	286	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3592-298] Recibo por consumo de agua"	\N
573	287	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3593-299] Recibo por consumo de agua"	\N
574	287	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3593-299] Recibo por consumo de agua"	\N
575	288	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3594-300] Recibo por consumo de agua"	\N
576	288	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3594-300] Recibo por consumo de agua"	\N
577	289	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3595-301] Recibo por consumo de agua"	\N
578	289	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3595-301] Recibo por consumo de agua"	\N
579	290	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3596-302] Recibo por consumo de agua"	\N
580	290	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3596-302] Recibo por consumo de agua"	\N
581	291	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3597-303] Recibo por consumo de agua"	\N
582	291	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3597-303] Recibo por consumo de agua"	\N
583	292	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3598-304] Recibo por consumo de agua"	\N
584	292	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3598-304] Recibo por consumo de agua"	\N
585	293	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3599-305] Recibo por consumo de agua"	\N
586	293	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3599-305] Recibo por consumo de agua"	\N
587	294	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3600-306] Recibo por consumo de agua"	\N
588	294	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3600-306] Recibo por consumo de agua"	\N
589	295	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3601-307] Recibo por consumo de agua"	\N
590	295	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3601-307] Recibo por consumo de agua"	\N
591	296	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3602-308] Recibo por consumo de agua"	\N
592	296	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3602-308] Recibo por consumo de agua"	\N
593	297	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3603-309] Recibo por consumo de agua"	\N
594	297	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3603-309] Recibo por consumo de agua"	\N
595	298	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3604-310] Recibo por consumo de agua"	\N
596	298	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3604-310] Recibo por consumo de agua"	\N
597	299	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3605-311] Recibo por consumo de agua"	\N
598	299	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3605-311] Recibo por consumo de agua"	\N
599	300	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3606-312] Recibo por consumo de agua"	\N
600	300	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3606-312] Recibo por consumo de agua"	\N
601	301	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3607-313] Recibo por consumo de agua"	\N
602	301	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3607-313] Recibo por consumo de agua"	\N
603	302	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3608-314] Recibo por consumo de agua"	\N
604	302	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3608-314] Recibo por consumo de agua"	\N
605	303	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3609-315] Recibo por consumo de agua"	\N
606	303	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3609-315] Recibo por consumo de agua"	\N
607	304	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3610-316] Recibo por consumo de agua"	\N
608	304	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3610-316] Recibo por consumo de agua"	\N
609	305	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3611-317] Recibo por consumo de agua"	\N
610	305	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3611-317] Recibo por consumo de agua"	\N
611	306	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3612-318] Recibo por consumo de agua"	\N
612	306	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3612-318] Recibo por consumo de agua"	\N
613	307	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3613-319] Recibo por consumo de agua"	\N
614	307	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3613-319] Recibo por consumo de agua"	\N
615	308	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3614-320] Recibo por consumo de agua"	\N
616	308	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3614-320] Recibo por consumo de agua"	\N
617	309	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3615-321] Recibo por consumo de agua"	\N
618	309	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3615-321] Recibo por consumo de agua"	\N
619	310	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3616-322] Recibo por consumo de agua"	\N
620	310	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3616-322] Recibo por consumo de agua"	\N
621	311	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3617-323] Recibo por consumo de agua"	\N
622	311	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3617-323] Recibo por consumo de agua"	\N
623	312	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3618-324] Recibo por consumo de agua"	\N
624	312	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3618-324] Recibo por consumo de agua"	\N
625	313	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3619-325] Recibo por consumo de agua"	\N
626	313	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3619-325] Recibo por consumo de agua"	\N
627	314	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3620-326] Recibo por consumo de agua"	\N
628	314	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3620-326] Recibo por consumo de agua"	\N
629	315	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3621-327] Recibo por consumo de agua"	\N
630	315	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3621-327] Recibo por consumo de agua"	\N
631	316	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3622-328] Recibo por consumo de agua"	\N
632	316	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3622-328] Recibo por consumo de agua"	\N
633	317	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3623-329] Recibo por consumo de agua"	\N
634	317	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3623-329] Recibo por consumo de agua"	\N
635	318	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3624-330] Recibo por consumo de agua"	\N
636	318	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3624-330] Recibo por consumo de agua"	\N
637	319	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3625-331] Recibo por consumo de agua"	\N
638	319	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3625-331] Recibo por consumo de agua"	\N
639	320	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3626-332] Recibo por consumo de agua"	\N
640	320	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3626-332] Recibo por consumo de agua"	\N
641	321	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3627-333] Recibo por consumo de agua"	\N
642	321	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3627-333] Recibo por consumo de agua"	\N
643	322	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3628-334] Recibo por consumo de agua"	\N
644	322	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3628-334] Recibo por consumo de agua"	\N
645	323	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3629-335] Recibo por consumo de agua"	\N
646	323	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3629-335] Recibo por consumo de agua"	\N
647	324	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3630-336] Recibo por consumo de agua"	\N
648	324	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3630-336] Recibo por consumo de agua"	\N
649	325	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3631-337] Recibo por consumo de agua"	\N
650	325	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3631-337] Recibo por consumo de agua"	\N
651	326	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3632-338] Recibo por consumo de agua"	\N
652	326	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3632-338] Recibo por consumo de agua"	\N
653	327	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3633-339] Recibo por consumo de agua"	\N
654	327	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3633-339] Recibo por consumo de agua"	\N
655	328	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3634-340] Recibo por consumo de agua"	\N
656	328	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3634-340] Recibo por consumo de agua"	\N
657	329	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3635-341] Recibo por consumo de agua"	\N
658	329	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3635-341] Recibo por consumo de agua"	\N
659	330	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3636-342] Recibo por consumo de agua"	\N
660	330	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3636-342] Recibo por consumo de agua"	\N
661	331	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3637-343] Recibo por consumo de agua"	\N
662	331	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3637-343] Recibo por consumo de agua"	\N
663	332	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3638-344] Recibo por consumo de agua"	\N
664	332	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3638-344] Recibo por consumo de agua"	\N
665	333	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3639-345] Recibo por consumo de agua"	\N
666	333	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3639-345] Recibo por consumo de agua"	\N
667	334	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3640-346] Recibo por consumo de agua"	\N
668	334	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3640-346] Recibo por consumo de agua"	\N
669	335	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3641-347] Recibo por consumo de agua"	\N
670	335	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3641-347] Recibo por consumo de agua"	\N
671	336	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3642-348] Recibo por consumo de agua"	\N
672	336	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3642-348] Recibo por consumo de agua"	\N
673	337	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3643-349] Recibo por consumo de agua"	\N
674	337	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3643-349] Recibo por consumo de agua"	\N
675	338	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3644-350] Recibo por consumo de agua"	\N
676	338	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3644-350] Recibo por consumo de agua"	\N
677	339	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3645-351] Recibo por consumo de agua"	\N
678	339	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3645-351] Recibo por consumo de agua"	\N
679	340	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3646-352] Recibo por consumo de agua"	\N
680	340	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3646-352] Recibo por consumo de agua"	\N
681	341	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3647-353] Recibo por consumo de agua"	\N
682	341	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3647-353] Recibo por consumo de agua"	\N
683	342	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3648-354] Recibo por consumo de agua"	\N
684	342	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3648-354] Recibo por consumo de agua"	\N
685	343	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3649-355] Recibo por consumo de agua"	\N
686	343	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3649-355] Recibo por consumo de agua"	\N
687	344	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3650-356] Recibo por consumo de agua"	\N
688	344	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3650-356] Recibo por consumo de agua"	\N
689	345	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3651-357] Recibo por consumo de agua"	\N
690	345	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3651-357] Recibo por consumo de agua"	\N
691	346	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3652-358] Recibo por consumo de agua"	\N
692	346	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3652-358] Recibo por consumo de agua"	\N
693	347	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3653-359] Recibo por consumo de agua"	\N
694	347	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3653-359] Recibo por consumo de agua"	\N
695	348	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3654-360] Recibo por consumo de agua"	\N
696	348	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3654-360] Recibo por consumo de agua"	\N
697	349	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3655-361] Recibo por consumo de agua"	\N
698	349	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3655-361] Recibo por consumo de agua"	\N
699	350	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3656-362] Recibo por consumo de agua"	\N
700	350	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3656-362] Recibo por consumo de agua"	\N
701	351	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3657-363] Recibo por consumo de agua"	\N
702	351	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3657-363] Recibo por consumo de agua"	\N
703	352	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3658-364] Recibo por consumo de agua"	\N
704	352	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3658-364] Recibo por consumo de agua"	\N
705	353	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3659-365] Recibo por consumo de agua"	\N
706	353	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3659-365] Recibo por consumo de agua"	\N
707	354	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3660-366] Recibo por consumo de agua"	\N
708	354	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3660-366] Recibo por consumo de agua"	\N
709	355	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3661-367] Recibo por consumo de agua"	\N
710	355	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3661-367] Recibo por consumo de agua"	\N
711	356	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3662-368] Recibo por consumo de agua"	\N
712	356	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3662-368] Recibo por consumo de agua"	\N
713	357	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3663-369] Recibo por consumo de agua"	\N
714	357	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3663-369] Recibo por consumo de agua"	\N
715	358	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3664-370] Recibo por consumo de agua"	\N
716	358	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3664-370] Recibo por consumo de agua"	\N
717	359	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3665-371] Recibo por consumo de agua"	\N
718	359	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3665-371] Recibo por consumo de agua"	\N
719	360	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3666-372] Recibo por consumo de agua"	\N
720	360	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3666-372] Recibo por consumo de agua"	\N
721	361	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3667-373] Recibo por consumo de agua"	\N
722	361	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3667-373] Recibo por consumo de agua"	\N
723	362	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3668-374] Recibo por consumo de agua"	\N
724	362	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3668-374] Recibo por consumo de agua"	\N
725	363	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3669-375] Recibo por consumo de agua"	\N
726	363	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3669-375] Recibo por consumo de agua"	\N
727	364	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3670-376] Recibo por consumo de agua"	\N
728	364	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3670-376] Recibo por consumo de agua"	\N
729	365	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3671-377] Recibo por consumo de agua"	\N
730	365	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3671-377] Recibo por consumo de agua"	\N
731	366	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3672-378] Recibo por consumo de agua"	\N
732	366	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3672-378] Recibo por consumo de agua"	\N
733	367	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3673-379] Recibo por consumo de agua"	\N
734	367	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3673-379] Recibo por consumo de agua"	\N
735	368	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3674-380] Recibo por consumo de agua"	\N
736	368	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3674-380] Recibo por consumo de agua"	\N
737	369	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3675-381] Recibo por consumo de agua"	\N
738	369	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3675-381] Recibo por consumo de agua"	\N
739	370	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3676-382] Recibo por consumo de agua"	\N
740	370	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3676-382] Recibo por consumo de agua"	\N
741	371	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3677-383] Recibo por consumo de agua"	\N
742	371	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3677-383] Recibo por consumo de agua"	\N
743	372	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3678-384] Recibo por consumo de agua"	\N
744	372	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3678-384] Recibo por consumo de agua"	\N
745	373	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3679-385] Recibo por consumo de agua"	\N
746	373	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3679-385] Recibo por consumo de agua"	\N
747	374	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3680-386] Recibo por consumo de agua"	\N
748	374	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3680-386] Recibo por consumo de agua"	\N
749	375	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3681-387] Recibo por consumo de agua"	\N
750	375	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3681-387] Recibo por consumo de agua"	\N
751	376	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3682-388] Recibo por consumo de agua"	\N
752	376	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3682-388] Recibo por consumo de agua"	\N
753	377	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3683-389] Recibo por consumo de agua"	\N
754	377	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3683-389] Recibo por consumo de agua"	\N
755	378	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3684-390] Recibo por consumo de agua"	\N
756	378	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3684-390] Recibo por consumo de agua"	\N
757	379	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3685-391] Recibo por consumo de agua"	\N
758	379	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3685-391] Recibo por consumo de agua"	\N
759	380	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3686-392] Recibo por consumo de agua"	\N
760	380	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3686-392] Recibo por consumo de agua"	\N
761	381	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3687-393] Recibo por consumo de agua"	\N
762	381	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3687-393] Recibo por consumo de agua"	\N
763	382	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3688-394] Recibo por consumo de agua"	\N
764	382	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3688-394] Recibo por consumo de agua"	\N
765	383	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3689-395] Recibo por consumo de agua"	\N
766	383	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3689-395] Recibo por consumo de agua"	\N
767	384	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3690-396] Recibo por consumo de agua"	\N
768	384	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3690-396] Recibo por consumo de agua"	\N
769	385	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3691-397] Recibo por consumo de agua"	\N
770	385	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3691-397] Recibo por consumo de agua"	\N
771	386	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3692-398] Recibo por consumo de agua"	\N
772	386	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3692-398] Recibo por consumo de agua"	\N
773	387	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3693-399] Recibo por consumo de agua"	\N
774	387	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3693-399] Recibo por consumo de agua"	\N
775	388	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3694-400] Recibo por consumo de agua"	\N
776	388	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3694-400] Recibo por consumo de agua"	\N
777	389	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3695-401] Recibo por consumo de agua"	\N
778	389	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3695-401] Recibo por consumo de agua"	\N
779	390	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3696-402] Recibo por consumo de agua"	\N
780	390	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3696-402] Recibo por consumo de agua"	\N
781	391	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3697-403] Recibo por consumo de agua"	\N
782	391	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3697-403] Recibo por consumo de agua"	\N
783	392	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3698-404] Recibo por consumo de agua"	\N
784	392	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3698-404] Recibo por consumo de agua"	\N
785	393	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3699-405] Recibo por consumo de agua"	\N
786	393	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3699-405] Recibo por consumo de agua"	\N
787	394	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3700-406] Recibo por consumo de agua"	\N
788	394	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3700-406] Recibo por consumo de agua"	\N
789	395	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3701-407] Recibo por consumo de agua"	\N
790	395	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3701-407] Recibo por consumo de agua"	\N
791	396	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3702-408] Recibo por consumo de agua"	\N
792	396	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3702-408] Recibo por consumo de agua"	\N
793	397	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3703-409] Recibo por consumo de agua"	\N
794	397	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3703-409] Recibo por consumo de agua"	\N
795	398	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3704-410] Recibo por consumo de agua"	\N
796	398	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3704-410] Recibo por consumo de agua"	\N
797	399	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3705-411] Recibo por consumo de agua"	\N
798	399	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3705-411] Recibo por consumo de agua"	\N
799	400	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3706-412] Recibo por consumo de agua"	\N
800	400	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3706-412] Recibo por consumo de agua"	\N
801	401	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3707-413] Recibo por consumo de agua"	\N
802	401	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3707-413] Recibo por consumo de agua"	\N
803	402	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3708-414] Recibo por consumo de agua"	\N
804	402	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3708-414] Recibo por consumo de agua"	\N
805	403	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3709-415] Recibo por consumo de agua"	\N
806	403	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3709-415] Recibo por consumo de agua"	\N
807	404	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3710-416] Recibo por consumo de agua"	\N
808	404	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3710-416] Recibo por consumo de agua"	\N
809	405	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3711-417] Recibo por consumo de agua"	\N
810	405	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3711-417] Recibo por consumo de agua"	\N
811	406	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3712-418] Recibo por consumo de agua"	\N
812	406	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3712-418] Recibo por consumo de agua"	\N
813	407	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3713-419] Recibo por consumo de agua"	\N
814	407	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3713-419] Recibo por consumo de agua"	\N
815	408	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3714-420] Recibo por consumo de agua"	\N
816	408	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3714-420] Recibo por consumo de agua"	\N
817	409	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3715-421] Recibo por consumo de agua"	\N
818	409	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3715-421] Recibo por consumo de agua"	\N
819	410	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3716-422] Recibo por consumo de agua"	\N
820	410	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3716-422] Recibo por consumo de agua"	\N
821	411	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3717-423] Recibo por consumo de agua"	\N
822	411	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3717-423] Recibo por consumo de agua"	\N
823	412	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3718-424] Recibo por consumo de agua"	\N
824	412	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3718-424] Recibo por consumo de agua"	\N
825	413	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3719-425] Recibo por consumo de agua"	\N
826	413	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3719-425] Recibo por consumo de agua"	\N
827	414	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3720-426] Recibo por consumo de agua"	\N
828	414	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3720-426] Recibo por consumo de agua"	\N
829	415	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3721-427] Recibo por consumo de agua"	\N
830	415	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3721-427] Recibo por consumo de agua"	\N
831	416	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3722-428] Recibo por consumo de agua"	\N
832	416	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3722-428] Recibo por consumo de agua"	\N
833	417	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3723-429] Recibo por consumo de agua"	\N
834	417	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3723-429] Recibo por consumo de agua"	\N
835	418	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3724-430] Recibo por consumo de agua"	\N
836	418	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3724-430] Recibo por consumo de agua"	\N
837	419	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3725-431] Recibo por consumo de agua"	\N
838	419	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3725-431] Recibo por consumo de agua"	\N
839	420	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3726-432] Recibo por consumo de agua"	\N
840	420	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3726-432] Recibo por consumo de agua"	\N
841	421	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3727-433] Recibo por consumo de agua"	\N
842	421	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3727-433] Recibo por consumo de agua"	\N
843	422	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3728-434] Recibo por consumo de agua"	\N
844	422	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3728-434] Recibo por consumo de agua"	\N
845	423	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3729-435] Recibo por consumo de agua"	\N
846	423	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3729-435] Recibo por consumo de agua"	\N
847	424	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3730-436] Recibo por consumo de agua"	\N
848	424	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3730-436] Recibo por consumo de agua"	\N
849	425	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3731-437] Recibo por consumo de agua"	\N
850	425	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3731-437] Recibo por consumo de agua"	\N
851	426	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3732-438] Recibo por consumo de agua"	\N
852	426	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3732-438] Recibo por consumo de agua"	\N
853	427	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3733-439] Recibo por consumo de agua"	\N
854	427	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3733-439] Recibo por consumo de agua"	\N
855	428	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3734-440] Recibo por consumo de agua"	\N
856	428	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3734-440] Recibo por consumo de agua"	\N
857	429	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3735-441] Recibo por consumo de agua"	\N
858	429	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3735-441] Recibo por consumo de agua"	\N
859	430	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3736-442] Recibo por consumo de agua"	\N
860	430	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3736-442] Recibo por consumo de agua"	\N
861	431	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3737-443] Recibo por consumo de agua"	\N
862	431	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3737-443] Recibo por consumo de agua"	\N
863	432	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3738-444] Recibo por consumo de agua"	\N
864	432	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3738-444] Recibo por consumo de agua"	\N
865	433	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3739-445] Recibo por consumo de agua"	\N
866	433	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3739-445] Recibo por consumo de agua"	\N
867	434	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3740-446] Recibo por consumo de agua"	\N
868	434	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3740-446] Recibo por consumo de agua"	\N
869	435	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3741-447] Recibo por consumo de agua"	\N
870	435	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3741-447] Recibo por consumo de agua"	\N
871	436	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3742-448] Recibo por consumo de agua"	\N
872	436	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3742-448] Recibo por consumo de agua"	\N
873	437	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3743-449] Recibo por consumo de agua"	\N
874	437	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3743-449] Recibo por consumo de agua"	\N
875	438	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3744-450] Recibo por consumo de agua"	\N
876	438	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3744-450] Recibo por consumo de agua"	\N
877	439	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3745-451] Recibo por consumo de agua"	\N
878	439	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3745-451] Recibo por consumo de agua"	\N
879	440	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3746-452] Recibo por consumo de agua"	\N
880	440	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3746-452] Recibo por consumo de agua"	\N
881	441	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3747-453] Recibo por consumo de agua"	\N
882	441	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3747-453] Recibo por consumo de agua"	\N
883	442	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3748-454] Recibo por consumo de agua"	\N
884	442	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3748-454] Recibo por consumo de agua"	\N
885	443	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3749-455] Recibo por consumo de agua"	\N
886	443	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3749-455] Recibo por consumo de agua"	\N
887	444	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3750-456] Recibo por consumo de agua"	\N
888	444	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3750-456] Recibo por consumo de agua"	\N
889	445	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3751-457] Recibo por consumo de agua"	\N
890	445	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3751-457] Recibo por consumo de agua"	\N
891	446	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3752-458] Recibo por consumo de agua"	\N
892	446	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3752-458] Recibo por consumo de agua"	\N
893	447	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3753-459] Recibo por consumo de agua"	\N
894	447	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3753-459] Recibo por consumo de agua"	\N
895	448	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3754-460] Recibo por consumo de agua"	\N
896	448	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3754-460] Recibo por consumo de agua"	\N
897	449	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3755-461] Recibo por consumo de agua"	\N
898	449	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3755-461] Recibo por consumo de agua"	\N
899	450	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3756-462] Recibo por consumo de agua"	\N
900	450	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3756-462] Recibo por consumo de agua"	\N
901	451	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3757-463] Recibo por consumo de agua"	\N
902	451	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3757-463] Recibo por consumo de agua"	\N
903	452	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3758-464] Recibo por consumo de agua"	\N
904	452	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3758-464] Recibo por consumo de agua"	\N
905	453	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3759-465] Recibo por consumo de agua"	\N
906	453	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3759-465] Recibo por consumo de agua"	\N
907	454	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3760-466] Recibo por consumo de agua"	\N
908	454	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3760-466] Recibo por consumo de agua"	\N
909	455	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3761-467] Recibo por consumo de agua"	\N
910	455	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3761-467] Recibo por consumo de agua"	\N
911	456	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3762-468] Recibo por consumo de agua"	\N
912	456	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3762-468] Recibo por consumo de agua"	\N
913	457	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3763-469] Recibo por consumo de agua"	\N
914	457	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3763-469] Recibo por consumo de agua"	\N
915	458	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3764-470] Recibo por consumo de agua"	\N
916	458	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3764-470] Recibo por consumo de agua"	\N
917	459	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3765-471] Recibo por consumo de agua"	\N
918	459	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3765-471] Recibo por consumo de agua"	\N
919	460	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3766-472] Recibo por consumo de agua"	\N
920	460	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3766-472] Recibo por consumo de agua"	\N
921	461	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3767-473] Recibo por consumo de agua"	\N
922	461	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3767-473] Recibo por consumo de agua"	\N
923	462	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3768-474] Recibo por consumo de agua"	\N
924	462	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3768-474] Recibo por consumo de agua"	\N
925	463	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3769-475] Recibo por consumo de agua"	\N
926	463	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3769-475] Recibo por consumo de agua"	\N
927	464	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3770-476] Recibo por consumo de agua"	\N
928	464	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3770-476] Recibo por consumo de agua"	\N
929	465	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3771-477] Recibo por consumo de agua"	\N
930	465	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3771-477] Recibo por consumo de agua"	\N
931	466	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3772-478] Recibo por consumo de agua"	\N
932	466	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3772-478] Recibo por consumo de agua"	\N
933	467	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3773-479] Recibo por consumo de agua"	\N
934	467	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3773-479] Recibo por consumo de agua"	\N
935	468	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3774-480] Recibo por consumo de agua"	\N
936	468	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3774-480] Recibo por consumo de agua"	\N
937	469	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3775-481] Recibo por consumo de agua"	\N
938	469	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3775-481] Recibo por consumo de agua"	\N
939	470	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3776-482] Recibo por consumo de agua"	\N
940	470	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3776-482] Recibo por consumo de agua"	\N
941	471	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3777-483] Recibo por consumo de agua"	\N
942	471	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3777-483] Recibo por consumo de agua"	\N
943	472	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3778-484] Recibo por consumo de agua"	\N
944	472	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3778-484] Recibo por consumo de agua"	\N
945	473	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3779-485] Recibo por consumo de agua"	\N
946	473	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3779-485] Recibo por consumo de agua"	\N
947	474	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3780-486] Recibo por consumo de agua"	\N
948	474	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3780-486] Recibo por consumo de agua"	\N
949	475	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3781-487] Recibo por consumo de agua"	\N
950	475	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3781-487] Recibo por consumo de agua"	\N
951	476	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3782-488] Recibo por consumo de agua"	\N
952	476	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3782-488] Recibo por consumo de agua"	\N
953	477	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3783-489] Recibo por consumo de agua"	\N
954	477	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3783-489] Recibo por consumo de agua"	\N
955	478	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3784-490] Recibo por consumo de agua"	\N
956	478	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3784-490] Recibo por consumo de agua"	\N
957	479	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3785-491] Recibo por consumo de agua"	\N
958	479	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3785-491] Recibo por consumo de agua"	\N
959	480	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3786-492] Recibo por consumo de agua"	\N
960	480	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3786-492] Recibo por consumo de agua"	\N
961	481	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3787-493] Recibo por consumo de agua"	\N
962	481	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3787-493] Recibo por consumo de agua"	\N
963	482	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3788-494] Recibo por consumo de agua"	\N
964	482	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3788-494] Recibo por consumo de agua"	\N
965	483	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3789-495] Recibo por consumo de agua"	\N
966	483	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3789-495] Recibo por consumo de agua"	\N
967	484	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3790-496] Recibo por consumo de agua"	\N
968	484	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3790-496] Recibo por consumo de agua"	\N
969	485	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3791-497] Recibo por consumo de agua"	\N
970	485	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3791-497] Recibo por consumo de agua"	\N
971	486	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3792-498] Recibo por consumo de agua"	\N
972	486	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3792-498] Recibo por consumo de agua"	\N
973	487	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3793-499] Recibo por consumo de agua"	\N
974	487	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3793-499] Recibo por consumo de agua"	\N
975	488	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3794-500] Recibo por consumo de agua"	\N
976	488	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3794-500] Recibo por consumo de agua"	\N
977	489	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3795-501] Recibo por consumo de agua"	\N
978	489	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3795-501] Recibo por consumo de agua"	\N
979	490	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3796-502] Recibo por consumo de agua"	\N
980	490	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3796-502] Recibo por consumo de agua"	\N
981	491	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3797-503] Recibo por consumo de agua"	\N
982	491	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3797-503] Recibo por consumo de agua"	\N
983	492	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3798-504] Recibo por consumo de agua"	\N
984	492	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3798-504] Recibo por consumo de agua"	\N
985	493	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3799-505] Recibo por consumo de agua"	\N
986	493	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3799-505] Recibo por consumo de agua"	\N
987	494	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3800-506] Recibo por consumo de agua"	\N
988	494	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3800-506] Recibo por consumo de agua"	\N
989	495	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3801-507] Recibo por consumo de agua"	\N
990	495	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3801-507] Recibo por consumo de agua"	\N
991	496	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3802-508] Recibo por consumo de agua"	\N
992	496	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3802-508] Recibo por consumo de agua"	\N
993	497	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3803-509] Recibo por consumo de agua"	\N
994	497	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3803-509] Recibo por consumo de agua"	\N
995	498	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3804-510] Recibo por consumo de agua"	\N
996	498	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3804-510] Recibo por consumo de agua"	\N
997	499	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3805-511] Recibo por consumo de agua"	\N
998	499	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3805-511] Recibo por consumo de agua"	\N
999	500	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3806-512] Recibo por consumo de agua"	\N
1000	500	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3806-512] Recibo por consumo de agua"	\N
1001	501	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3807-513] Recibo por consumo de agua"	\N
1002	501	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3807-513] Recibo por consumo de agua"	\N
1003	502	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3808-514] Recibo por consumo de agua"	\N
1004	502	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3808-514] Recibo por consumo de agua"	\N
1005	503	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3809-515] Recibo por consumo de agua"	\N
1006	503	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3809-515] Recibo por consumo de agua"	\N
1007	504	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3810-516] Recibo por consumo de agua"	\N
1008	504	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3810-516] Recibo por consumo de agua"	\N
1009	505	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3811-517] Recibo por consumo de agua"	\N
1010	505	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3811-517] Recibo por consumo de agua"	\N
1011	506	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3812-518] Recibo por consumo de agua"	\N
1012	506	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3812-518] Recibo por consumo de agua"	\N
1013	507	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3813-519] Recibo por consumo de agua"	\N
1014	507	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3813-519] Recibo por consumo de agua"	\N
1015	508	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3814-520] Recibo por consumo de agua"	\N
1016	508	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3814-520] Recibo por consumo de agua"	\N
1017	509	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3815-521] Recibo por consumo de agua"	\N
1018	509	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3815-521] Recibo por consumo de agua"	\N
1019	510	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3816-522] Recibo por consumo de agua"	\N
1020	510	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3816-522] Recibo por consumo de agua"	\N
1021	511	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3817-523] Recibo por consumo de agua"	\N
1022	511	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3817-523] Recibo por consumo de agua"	\N
1023	512	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3818-524] Recibo por consumo de agua"	\N
1024	512	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3818-524] Recibo por consumo de agua"	\N
1025	513	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3819-525] Recibo por consumo de agua"	\N
1026	513	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3819-525] Recibo por consumo de agua"	\N
1027	514	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3820-526] Recibo por consumo de agua"	\N
1028	514	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3820-526] Recibo por consumo de agua"	\N
1029	515	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3821-527] Recibo por consumo de agua"	\N
1030	515	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3821-527] Recibo por consumo de agua"	\N
1031	516	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3822-528] Recibo por consumo de agua"	\N
1032	516	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3822-528] Recibo por consumo de agua"	\N
1033	517	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3823-529] Recibo por consumo de agua"	\N
1034	517	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3823-529] Recibo por consumo de agua"	\N
1035	518	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3824-530] Recibo por consumo de agua"	\N
1036	518	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3824-530] Recibo por consumo de agua"	\N
1037	519	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3825-531] Recibo por consumo de agua"	\N
1038	519	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3825-531] Recibo por consumo de agua"	\N
1039	520	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3826-532] Recibo por consumo de agua"	\N
1040	520	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3826-532] Recibo por consumo de agua"	\N
1041	521	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3827-533] Recibo por consumo de agua"	\N
1042	521	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3827-533] Recibo por consumo de agua"	\N
1043	522	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3828-534] Recibo por consumo de agua"	\N
1044	522	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3828-534] Recibo por consumo de agua"	\N
1045	523	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3829-535] Recibo por consumo de agua"	\N
1046	523	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3829-535] Recibo por consumo de agua"	\N
1047	524	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3830-536] Recibo por consumo de agua"	\N
1048	524	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3830-536] Recibo por consumo de agua"	\N
1049	525	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3831-537] Recibo por consumo de agua"	\N
1050	525	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3831-537] Recibo por consumo de agua"	\N
1051	526	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3832-538] Recibo por consumo de agua"	\N
1052	526	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3832-538] Recibo por consumo de agua"	\N
1053	527	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3833-539] Recibo por consumo de agua"	\N
1054	527	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3833-539] Recibo por consumo de agua"	\N
1055	528	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3834-540] Recibo por consumo de agua"	\N
1056	528	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3834-540] Recibo por consumo de agua"	\N
1057	529	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3835-541] Recibo por consumo de agua"	\N
1058	529	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3835-541] Recibo por consumo de agua"	\N
1059	530	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3836-542] Recibo por consumo de agua"	\N
1060	530	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3836-542] Recibo por consumo de agua"	\N
1061	531	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3837-543] Recibo por consumo de agua"	\N
1062	531	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3837-543] Recibo por consumo de agua"	\N
1063	532	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3838-544] Recibo por consumo de agua"	\N
1064	532	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3838-544] Recibo por consumo de agua"	\N
1065	533	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3839-545] Recibo por consumo de agua"	\N
1066	533	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3839-545] Recibo por consumo de agua"	\N
1067	534	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3840-546] Recibo por consumo de agua"	\N
1068	534	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3840-546] Recibo por consumo de agua"	\N
1069	535	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3841-547] Recibo por consumo de agua"	\N
1070	535	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3841-547] Recibo por consumo de agua"	\N
1071	536	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3842-548] Recibo por consumo de agua"	\N
1072	536	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3842-548] Recibo por consumo de agua"	\N
1073	537	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3843-549] Recibo por consumo de agua"	\N
1074	537	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3843-549] Recibo por consumo de agua"	\N
1075	538	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3844-550] Recibo por consumo de agua"	\N
1076	538	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3844-550] Recibo por consumo de agua"	\N
1077	539	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3845-551] Recibo por consumo de agua"	\N
1078	539	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3845-551] Recibo por consumo de agua"	\N
1079	540	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3846-552] Recibo por consumo de agua"	\N
1080	540	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3846-552] Recibo por consumo de agua"	\N
1081	541	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3847-553] Recibo por consumo de agua"	\N
1082	541	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3847-553] Recibo por consumo de agua"	\N
1083	542	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3848-554] Recibo por consumo de agua"	\N
1084	542	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3848-554] Recibo por consumo de agua"	\N
1085	543	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3849-555] Recibo por consumo de agua"	\N
1086	543	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3849-555] Recibo por consumo de agua"	\N
1087	544	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3850-556] Recibo por consumo de agua"	\N
1088	544	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3850-556] Recibo por consumo de agua"	\N
1089	545	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3851-557] Recibo por consumo de agua"	\N
1090	545	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3851-557] Recibo por consumo de agua"	\N
1091	546	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3852-558] Recibo por consumo de agua"	\N
1092	546	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3852-558] Recibo por consumo de agua"	\N
1093	547	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3853-559] Recibo por consumo de agua"	\N
1094	547	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3853-559] Recibo por consumo de agua"	\N
1095	548	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3854-560] Recibo por consumo de agua"	\N
1096	548	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3854-560] Recibo por consumo de agua"	\N
1097	549	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3855-561] Recibo por consumo de agua"	\N
1098	549	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3855-561] Recibo por consumo de agua"	\N
1099	550	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3856-562] Recibo por consumo de agua"	\N
1100	550	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3856-562] Recibo por consumo de agua"	\N
1101	551	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3857-563] Recibo por consumo de agua"	\N
1102	551	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3857-563] Recibo por consumo de agua"	\N
1103	552	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3858-564] Recibo por consumo de agua"	\N
1104	552	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3858-564] Recibo por consumo de agua"	\N
1105	553	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3859-565] Recibo por consumo de agua"	\N
1106	553	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3859-565] Recibo por consumo de agua"	\N
1107	554	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3860-566] Recibo por consumo de agua"	\N
1108	554	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3860-566] Recibo por consumo de agua"	\N
1109	555	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3861-567] Recibo por consumo de agua"	\N
1110	555	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3861-567] Recibo por consumo de agua"	\N
1111	556	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3862-568] Recibo por consumo de agua"	\N
1112	556	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3862-568] Recibo por consumo de agua"	\N
1113	557	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3863-569] Recibo por consumo de agua"	\N
1114	557	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3863-569] Recibo por consumo de agua"	\N
1115	558	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3864-570] Recibo por consumo de agua"	\N
1116	558	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3864-570] Recibo por consumo de agua"	\N
1117	559	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3865-571] Recibo por consumo de agua"	\N
1118	559	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3865-571] Recibo por consumo de agua"	\N
1119	560	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3866-572] Recibo por consumo de agua"	\N
1120	560	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3866-572] Recibo por consumo de agua"	\N
1121	561	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3867-573] Recibo por consumo de agua"	\N
1122	561	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3867-573] Recibo por consumo de agua"	\N
1123	562	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3868-574] Recibo por consumo de agua"	\N
1124	562	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3868-574] Recibo por consumo de agua"	\N
1125	563	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3869-575] Recibo por consumo de agua"	\N
1126	563	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3869-575] Recibo por consumo de agua"	\N
1127	564	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3870-576] Recibo por consumo de agua"	\N
1128	564	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3870-576] Recibo por consumo de agua"	\N
1129	565	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3871-577] Recibo por consumo de agua"	\N
1130	565	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3871-577] Recibo por consumo de agua"	\N
1131	566	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3872-578] Recibo por consumo de agua"	\N
1132	566	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3872-578] Recibo por consumo de agua"	\N
1133	567	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3873-579] Recibo por consumo de agua"	\N
1134	567	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3873-579] Recibo por consumo de agua"	\N
1135	568	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3874-580] Recibo por consumo de agua"	\N
1136	568	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3874-580] Recibo por consumo de agua"	\N
1137	569	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3875-581] Recibo por consumo de agua"	\N
1138	569	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3875-581] Recibo por consumo de agua"	\N
1139	570	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3876-582] Recibo por consumo de agua"	\N
1140	570	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3876-582] Recibo por consumo de agua"	\N
1141	571	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3877-583] Recibo por consumo de agua"	\N
1142	571	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3877-583] Recibo por consumo de agua"	\N
1143	572	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3878-584] Recibo por consumo de agua"	\N
1144	572	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3878-584] Recibo por consumo de agua"	\N
1145	573	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3879-585] Recibo por consumo de agua"	\N
1146	573	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3879-585] Recibo por consumo de agua"	\N
1147	574	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3880-586] Recibo por consumo de agua"	\N
1148	574	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3880-586] Recibo por consumo de agua"	\N
1149	575	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3881-587] Recibo por consumo de agua"	\N
1150	575	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3881-587] Recibo por consumo de agua"	\N
1151	576	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3882-588] Recibo por consumo de agua"	\N
1152	576	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3882-588] Recibo por consumo de agua"	\N
1153	577	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3883-589] Recibo por consumo de agua"	\N
1154	577	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3883-589] Recibo por consumo de agua"	\N
1155	578	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3884-590] Recibo por consumo de agua"	\N
1156	578	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3884-590] Recibo por consumo de agua"	\N
1157	579	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3885-591] Recibo por consumo de agua"	\N
1158	579	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3885-591] Recibo por consumo de agua"	\N
1159	580	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3886-592] Recibo por consumo de agua"	\N
1160	580	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3886-592] Recibo por consumo de agua"	\N
1161	581	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3887-593] Recibo por consumo de agua"	\N
1162	581	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3887-593] Recibo por consumo de agua"	\N
1163	582	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3888-594] Recibo por consumo de agua"	\N
1164	582	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3888-594] Recibo por consumo de agua"	\N
1165	583	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3889-595] Recibo por consumo de agua"	\N
1166	583	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3889-595] Recibo por consumo de agua"	\N
1167	584	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3890-596] Recibo por consumo de agua"	\N
1168	584	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3890-596] Recibo por consumo de agua"	\N
1169	585	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3891-597] Recibo por consumo de agua"	\N
1170	585	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3891-597] Recibo por consumo de agua"	\N
1171	586	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3892-598] Recibo por consumo de agua"	\N
1172	586	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3892-598] Recibo por consumo de agua"	\N
1173	587	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3893-599] Recibo por consumo de agua"	\N
1174	587	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3893-599] Recibo por consumo de agua"	\N
1175	588	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3894-600] Recibo por consumo de agua"	\N
1176	588	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3894-600] Recibo por consumo de agua"	\N
1177	589	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3895-601] Recibo por consumo de agua"	\N
1178	589	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3895-601] Recibo por consumo de agua"	\N
1179	590	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3896-602] Recibo por consumo de agua"	\N
1180	590	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3896-602] Recibo por consumo de agua"	\N
1181	591	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3897-603] Recibo por consumo de agua"	\N
1182	591	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3897-603] Recibo por consumo de agua"	\N
1183	592	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3898-604] Recibo por consumo de agua"	\N
1184	592	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3898-604] Recibo por consumo de agua"	\N
1185	593	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3899-605] Recibo por consumo de agua"	\N
1186	593	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3899-605] Recibo por consumo de agua"	\N
1187	594	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3900-606] Recibo por consumo de agua"	\N
1188	594	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3900-606] Recibo por consumo de agua"	\N
1189	595	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3901-607] Recibo por consumo de agua"	\N
1190	595	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3901-607] Recibo por consumo de agua"	\N
1191	596	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3902-608] Recibo por consumo de agua"	\N
1192	596	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3902-608] Recibo por consumo de agua"	\N
1193	597	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3903-609] Recibo por consumo de agua"	\N
1194	597	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3903-609] Recibo por consumo de agua"	\N
1195	598	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3904-610] Recibo por consumo de agua"	\N
1196	598	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3904-610] Recibo por consumo de agua"	\N
1197	599	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3905-611] Recibo por consumo de agua"	\N
1198	599	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3905-611] Recibo por consumo de agua"	\N
1199	600	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3906-612] Recibo por consumo de agua"	\N
1200	600	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3906-612] Recibo por consumo de agua"	\N
1201	601	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3907-613] Recibo por consumo de agua"	\N
1202	601	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3907-613] Recibo por consumo de agua"	\N
1203	602	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3908-614] Recibo por consumo de agua"	\N
1204	602	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3908-614] Recibo por consumo de agua"	\N
1205	603	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3909-615] Recibo por consumo de agua"	\N
1206	603	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3909-615] Recibo por consumo de agua"	\N
1207	604	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3910-616] Recibo por consumo de agua"	\N
1208	604	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3910-616] Recibo por consumo de agua"	\N
1209	605	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3911-617] Recibo por consumo de agua"	\N
1210	605	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3911-617] Recibo por consumo de agua"	\N
1211	606	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3912-618] Recibo por consumo de agua"	\N
1212	606	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3912-618] Recibo por consumo de agua"	\N
1213	607	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3913-619] Recibo por consumo de agua"	\N
1214	607	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3913-619] Recibo por consumo de agua"	\N
1215	608	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3914-620] Recibo por consumo de agua"	\N
1216	608	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3914-620] Recibo por consumo de agua"	\N
1217	609	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3915-621] Recibo por consumo de agua"	\N
1218	609	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3915-621] Recibo por consumo de agua"	\N
1219	610	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3916-622] Recibo por consumo de agua"	\N
1220	610	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3916-622] Recibo por consumo de agua"	\N
1221	611	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3917-623] Recibo por consumo de agua"	\N
1222	611	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3917-623] Recibo por consumo de agua"	\N
1223	612	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3918-624] Recibo por consumo de agua"	\N
1224	612	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3918-624] Recibo por consumo de agua"	\N
1225	613	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3919-625] Recibo por consumo de agua"	\N
1226	613	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3919-625] Recibo por consumo de agua"	\N
1227	614	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3920-626] Recibo por consumo de agua"	\N
1228	614	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3920-626] Recibo por consumo de agua"	\N
1229	615	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3921-627] Recibo por consumo de agua"	\N
1230	615	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3921-627] Recibo por consumo de agua"	\N
1231	616	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3922-628] Recibo por consumo de agua"	\N
1232	616	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3922-628] Recibo por consumo de agua"	\N
1233	617	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3923-629] Recibo por consumo de agua"	\N
1234	617	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3923-629] Recibo por consumo de agua"	\N
1235	618	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3924-630] Recibo por consumo de agua"	\N
1236	618	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3924-630] Recibo por consumo de agua"	\N
1237	619	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3925-631] Recibo por consumo de agua"	\N
1238	619	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3925-631] Recibo por consumo de agua"	\N
1239	620	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3926-632] Recibo por consumo de agua"	\N
1240	620	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3926-632] Recibo por consumo de agua"	\N
1241	621	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3927-633] Recibo por consumo de agua"	\N
1242	621	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3927-633] Recibo por consumo de agua"	\N
1243	622	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3928-634] Recibo por consumo de agua"	\N
1244	622	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3928-634] Recibo por consumo de agua"	\N
1245	623	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3929-635] Recibo por consumo de agua"	\N
1246	623	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3929-635] Recibo por consumo de agua"	\N
1247	624	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3930-636] Recibo por consumo de agua"	\N
1248	624	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3930-636] Recibo por consumo de agua"	\N
1249	625	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3931-637] Recibo por consumo de agua"	\N
1250	625	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3931-637] Recibo por consumo de agua"	\N
1251	626	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3932-638] Recibo por consumo de agua"	\N
1252	626	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3932-638] Recibo por consumo de agua"	\N
1253	627	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3933-639] Recibo por consumo de agua"	\N
1254	627	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3933-639] Recibo por consumo de agua"	\N
1255	628	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3934-640] Recibo por consumo de agua"	\N
1256	628	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3934-640] Recibo por consumo de agua"	\N
1257	629	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3935-641] Recibo por consumo de agua"	\N
1258	629	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3935-641] Recibo por consumo de agua"	\N
1259	630	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3936-642] Recibo por consumo de agua"	\N
1260	630	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3936-642] Recibo por consumo de agua"	\N
1261	631	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3937-643] Recibo por consumo de agua"	\N
1262	631	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3937-643] Recibo por consumo de agua"	\N
1263	632	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3938-644] Recibo por consumo de agua"	\N
1264	632	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3938-644] Recibo por consumo de agua"	\N
1265	633	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3939-645] Recibo por consumo de agua"	\N
1266	633	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3939-645] Recibo por consumo de agua"	\N
1267	634	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3940-646] Recibo por consumo de agua"	\N
1268	634	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3940-646] Recibo por consumo de agua"	\N
1269	635	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3941-647] Recibo por consumo de agua"	\N
1270	635	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3941-647] Recibo por consumo de agua"	\N
1271	636	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3942-648] Recibo por consumo de agua"	\N
1272	636	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3942-648] Recibo por consumo de agua"	\N
1273	637	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3943-649] Recibo por consumo de agua"	\N
1274	637	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3943-649] Recibo por consumo de agua"	\N
1275	638	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3944-650] Recibo por consumo de agua"	\N
1276	638	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3944-650] Recibo por consumo de agua"	\N
1277	639	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3945-651] Recibo por consumo de agua"	\N
1278	639	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3945-651] Recibo por consumo de agua"	\N
1279	640	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3946-652] Recibo por consumo de agua"	\N
1280	640	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3946-652] Recibo por consumo de agua"	\N
1281	641	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3947-653] Recibo por consumo de agua"	\N
1282	641	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3947-653] Recibo por consumo de agua"	\N
1283	642	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3948-654] Recibo por consumo de agua"	\N
1284	642	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3948-654] Recibo por consumo de agua"	\N
1285	643	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3949-655] Recibo por consumo de agua"	\N
1286	643	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3949-655] Recibo por consumo de agua"	\N
1287	644	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3950-656] Recibo por consumo de agua"	\N
1288	644	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3950-656] Recibo por consumo de agua"	\N
1289	645	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3951-657] Recibo por consumo de agua"	\N
1290	645	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3951-657] Recibo por consumo de agua"	\N
1291	646	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3952-658] Recibo por consumo de agua"	\N
1292	646	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3952-658] Recibo por consumo de agua"	\N
1293	647	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3953-659] Recibo por consumo de agua"	\N
1294	647	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3953-659] Recibo por consumo de agua"	\N
1295	648	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3954-660] Recibo por consumo de agua"	\N
1296	648	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3954-660] Recibo por consumo de agua"	\N
1297	649	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3955-661] Recibo por consumo de agua"	\N
1298	649	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3955-661] Recibo por consumo de agua"	\N
1299	650	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3956-662] Recibo por consumo de agua"	\N
1300	650	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3956-662] Recibo por consumo de agua"	\N
1301	651	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3957-663] Recibo por consumo de agua"	\N
1302	651	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3957-663] Recibo por consumo de agua"	\N
1303	652	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3958-664] Recibo por consumo de agua"	\N
1304	652	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3958-664] Recibo por consumo de agua"	\N
1305	653	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3959-665] Recibo por consumo de agua"	\N
1306	653	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3959-665] Recibo por consumo de agua"	\N
1307	654	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3960-666] Recibo por consumo de agua"	\N
1308	654	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3960-666] Recibo por consumo de agua"	\N
1309	655	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3961-667] Recibo por consumo de agua"	\N
1310	655	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3961-667] Recibo por consumo de agua"	\N
1311	656	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3962-668] Recibo por consumo de agua"	\N
1312	656	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3962-668] Recibo por consumo de agua"	\N
1313	657	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3963-669] Recibo por consumo de agua"	\N
1314	657	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3963-669] Recibo por consumo de agua"	\N
1315	658	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3964-670] Recibo por consumo de agua"	\N
1316	658	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3964-670] Recibo por consumo de agua"	\N
1317	659	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3965-671] Recibo por consumo de agua"	\N
1318	659	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3965-671] Recibo por consumo de agua"	\N
1319	660	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3966-672] Recibo por consumo de agua"	\N
1320	660	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3966-672] Recibo por consumo de agua"	\N
1321	661	259	5.25	t	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3967-673] Recibo por consumo de agua"	\N
1322	661	204	5.25	f	1	2015-01-14 05:56:50	2015-01-14	9	t	"[3967-673] Recibo por consumo de agua"	\N
1323	662	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3968-9] Recibo por consumo de agua"	\N
1324	662	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3968-9] Recibo por consumo de agua"	\N
1325	663	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3969-25] Recibo por consumo de agua"	\N
1326	663	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3969-25] Recibo por consumo de agua"	\N
1327	664	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3970-26] Recibo por consumo de agua"	\N
1328	664	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3970-26] Recibo por consumo de agua"	\N
1329	665	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3971-27] Recibo por consumo de agua"	\N
1330	665	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3971-27] Recibo por consumo de agua"	\N
1331	666	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3972-30] Recibo por consumo de agua"	\N
1332	666	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3972-30] Recibo por consumo de agua"	\N
1333	667	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3973-712] Recibo por consumo de agua"	\N
1334	667	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3973-712] Recibo por consumo de agua"	\N
1335	668	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3974-713] Recibo por consumo de agua"	\N
1336	668	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3974-713] Recibo por consumo de agua"	\N
1337	669	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3975-714] Recibo por consumo de agua"	\N
1338	669	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3975-714] Recibo por consumo de agua"	\N
1339	670	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3976-32] Recibo por consumo de agua"	\N
1340	670	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3976-32] Recibo por consumo de agua"	\N
1341	671	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3977-33] Recibo por consumo de agua"	\N
1342	671	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3977-33] Recibo por consumo de agua"	\N
1343	672	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3978-38] Recibo por consumo de agua"	\N
1344	672	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3978-38] Recibo por consumo de agua"	\N
1345	673	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3979-39] Recibo por consumo de agua"	\N
1346	673	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3979-39] Recibo por consumo de agua"	\N
1347	674	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3980-40] Recibo por consumo de agua"	\N
1348	674	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3980-40] Recibo por consumo de agua"	\N
1349	675	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3981-41] Recibo por consumo de agua"	\N
1350	675	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3981-41] Recibo por consumo de agua"	\N
1351	676	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3982-43] Recibo por consumo de agua"	\N
1352	676	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3982-43] Recibo por consumo de agua"	\N
1353	677	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3983-44] Recibo por consumo de agua"	\N
1354	677	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3983-44] Recibo por consumo de agua"	\N
1355	678	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3984-45] Recibo por consumo de agua"	\N
1356	678	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3984-45] Recibo por consumo de agua"	\N
1357	679	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3985-46] Recibo por consumo de agua"	\N
1358	679	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3985-46] Recibo por consumo de agua"	\N
1359	680	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3986-47] Recibo por consumo de agua"	\N
1360	680	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3986-47] Recibo por consumo de agua"	\N
1361	681	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3987-48] Recibo por consumo de agua"	\N
1362	681	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3987-48] Recibo por consumo de agua"	\N
1363	682	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3988-49] Recibo por consumo de agua"	\N
1364	682	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3988-49] Recibo por consumo de agua"	\N
1365	683	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3989-50] Recibo por consumo de agua"	\N
1366	683	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3989-50] Recibo por consumo de agua"	\N
1367	684	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3990-51] Recibo por consumo de agua"	\N
1368	684	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3990-51] Recibo por consumo de agua"	\N
1369	685	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3991-52] Recibo por consumo de agua"	\N
1370	685	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3991-52] Recibo por consumo de agua"	\N
1371	686	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3992-53] Recibo por consumo de agua"	\N
1372	686	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3992-53] Recibo por consumo de agua"	\N
1373	687	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3993-54] Recibo por consumo de agua"	\N
1374	687	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3993-54] Recibo por consumo de agua"	\N
1375	688	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3994-55] Recibo por consumo de agua"	\N
1376	688	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3994-55] Recibo por consumo de agua"	\N
1377	689	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3995-56] Recibo por consumo de agua"	\N
1378	689	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3995-56] Recibo por consumo de agua"	\N
1379	690	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3996-57] Recibo por consumo de agua"	\N
1380	690	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3996-57] Recibo por consumo de agua"	\N
1381	691	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3997-58] Recibo por consumo de agua"	\N
1382	691	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3997-58] Recibo por consumo de agua"	\N
1383	692	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3998-59] Recibo por consumo de agua"	\N
1384	692	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3998-59] Recibo por consumo de agua"	\N
1385	693	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3999-60] Recibo por consumo de agua"	\N
1386	693	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[3999-60] Recibo por consumo de agua"	\N
1387	694	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4000-61] Recibo por consumo de agua"	\N
1388	694	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4000-61] Recibo por consumo de agua"	\N
1389	695	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4001-62] Recibo por consumo de agua"	\N
1390	695	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4001-62] Recibo por consumo de agua"	\N
1391	696	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4002-63] Recibo por consumo de agua"	\N
1392	696	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4002-63] Recibo por consumo de agua"	\N
1393	697	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4003-64] Recibo por consumo de agua"	\N
1394	697	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4003-64] Recibo por consumo de agua"	\N
1395	698	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4004-65] Recibo por consumo de agua"	\N
1396	698	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4004-65] Recibo por consumo de agua"	\N
1397	699	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4005-67] Recibo por consumo de agua"	\N
1398	699	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4005-67] Recibo por consumo de agua"	\N
1399	700	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4006-68] Recibo por consumo de agua"	\N
1400	700	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4006-68] Recibo por consumo de agua"	\N
1401	701	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4007-70] Recibo por consumo de agua"	\N
1402	701	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4007-70] Recibo por consumo de agua"	\N
1403	702	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4008-71] Recibo por consumo de agua"	\N
1404	702	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4008-71] Recibo por consumo de agua"	\N
1405	703	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4009-72] Recibo por consumo de agua"	\N
1406	703	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4009-72] Recibo por consumo de agua"	\N
1407	704	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4010-73] Recibo por consumo de agua"	\N
1408	704	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4010-73] Recibo por consumo de agua"	\N
1409	705	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4011-74] Recibo por consumo de agua"	\N
1410	705	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4011-74] Recibo por consumo de agua"	\N
1411	706	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4012-75] Recibo por consumo de agua"	\N
1412	706	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4012-75] Recibo por consumo de agua"	\N
1413	707	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4013-76] Recibo por consumo de agua"	\N
1414	707	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4013-76] Recibo por consumo de agua"	\N
1415	708	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4014-77] Recibo por consumo de agua"	\N
1416	708	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4014-77] Recibo por consumo de agua"	\N
1417	709	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4015-78] Recibo por consumo de agua"	\N
1418	709	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4015-78] Recibo por consumo de agua"	\N
1419	710	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4016-79] Recibo por consumo de agua"	\N
1420	710	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4016-79] Recibo por consumo de agua"	\N
1421	711	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4017-80] Recibo por consumo de agua"	\N
1422	711	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4017-80] Recibo por consumo de agua"	\N
1423	712	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4018-82] Recibo por consumo de agua"	\N
1424	712	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4018-82] Recibo por consumo de agua"	\N
1425	713	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4019-85] Recibo por consumo de agua"	\N
1426	713	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4019-85] Recibo por consumo de agua"	\N
1427	714	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4020-86] Recibo por consumo de agua"	\N
1428	714	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4020-86] Recibo por consumo de agua"	\N
1429	715	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4021-87] Recibo por consumo de agua"	\N
1430	715	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4021-87] Recibo por consumo de agua"	\N
1431	716	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4022-88] Recibo por consumo de agua"	\N
1432	716	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4022-88] Recibo por consumo de agua"	\N
1433	717	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4023-91] Recibo por consumo de agua"	\N
1434	717	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4023-91] Recibo por consumo de agua"	\N
1435	718	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4024-92] Recibo por consumo de agua"	\N
1436	718	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4024-92] Recibo por consumo de agua"	\N
1437	719	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4025-93] Recibo por consumo de agua"	\N
1438	719	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4025-93] Recibo por consumo de agua"	\N
1439	720	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4026-94] Recibo por consumo de agua"	\N
1440	720	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4026-94] Recibo por consumo de agua"	\N
1441	721	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4027-95] Recibo por consumo de agua"	\N
1442	721	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4027-95] Recibo por consumo de agua"	\N
1443	722	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4028-96] Recibo por consumo de agua"	\N
1444	722	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4028-96] Recibo por consumo de agua"	\N
1445	723	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4029-97] Recibo por consumo de agua"	\N
1446	723	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4029-97] Recibo por consumo de agua"	\N
1447	724	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4030-98] Recibo por consumo de agua"	\N
1448	724	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4030-98] Recibo por consumo de agua"	\N
1449	725	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4031-99] Recibo por consumo de agua"	\N
1450	725	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4031-99] Recibo por consumo de agua"	\N
1451	726	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4032-100] Recibo por consumo de agua"	\N
1452	726	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4032-100] Recibo por consumo de agua"	\N
1453	727	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4033-101] Recibo por consumo de agua"	\N
1454	727	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4033-101] Recibo por consumo de agua"	\N
1455	728	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4034-102] Recibo por consumo de agua"	\N
1456	728	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4034-102] Recibo por consumo de agua"	\N
1457	729	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4035-103] Recibo por consumo de agua"	\N
1458	729	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4035-103] Recibo por consumo de agua"	\N
1459	730	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4036-104] Recibo por consumo de agua"	\N
1460	730	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4036-104] Recibo por consumo de agua"	\N
1461	731	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4037-105] Recibo por consumo de agua"	\N
1462	731	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4037-105] Recibo por consumo de agua"	\N
1463	732	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4038-106] Recibo por consumo de agua"	\N
1464	732	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4038-106] Recibo por consumo de agua"	\N
1465	733	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4039-107] Recibo por consumo de agua"	\N
1466	733	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4039-107] Recibo por consumo de agua"	\N
1467	734	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4040-108] Recibo por consumo de agua"	\N
1468	734	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4040-108] Recibo por consumo de agua"	\N
1469	735	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4041-110] Recibo por consumo de agua"	\N
1470	735	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4041-110] Recibo por consumo de agua"	\N
1471	736	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4042-111] Recibo por consumo de agua"	\N
1472	736	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4042-111] Recibo por consumo de agua"	\N
1473	737	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4043-112] Recibo por consumo de agua"	\N
1474	737	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4043-112] Recibo por consumo de agua"	\N
1475	738	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4044-114] Recibo por consumo de agua"	\N
1476	738	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4044-114] Recibo por consumo de agua"	\N
1477	739	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4045-115] Recibo por consumo de agua"	\N
1478	739	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4045-115] Recibo por consumo de agua"	\N
1479	740	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4046-116] Recibo por consumo de agua"	\N
1480	740	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4046-116] Recibo por consumo de agua"	\N
1481	741	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4047-117] Recibo por consumo de agua"	\N
1482	741	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4047-117] Recibo por consumo de agua"	\N
1483	742	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4048-118] Recibo por consumo de agua"	\N
1484	742	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4048-118] Recibo por consumo de agua"	\N
1485	743	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4049-119] Recibo por consumo de agua"	\N
1486	743	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4049-119] Recibo por consumo de agua"	\N
1487	744	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4050-120] Recibo por consumo de agua"	\N
1488	744	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4050-120] Recibo por consumo de agua"	\N
1489	745	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4051-121] Recibo por consumo de agua"	\N
1490	745	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4051-121] Recibo por consumo de agua"	\N
1491	746	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4052-122] Recibo por consumo de agua"	\N
1492	746	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4052-122] Recibo por consumo de agua"	\N
1493	747	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4053-123] Recibo por consumo de agua"	\N
1494	747	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4053-123] Recibo por consumo de agua"	\N
1495	748	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4054-124] Recibo por consumo de agua"	\N
1496	748	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4054-124] Recibo por consumo de agua"	\N
1497	749	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4055-125] Recibo por consumo de agua"	\N
1498	749	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4055-125] Recibo por consumo de agua"	\N
1499	750	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4056-128] Recibo por consumo de agua"	\N
1500	750	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4056-128] Recibo por consumo de agua"	\N
1501	751	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4057-130] Recibo por consumo de agua"	\N
1502	751	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4057-130] Recibo por consumo de agua"	\N
1503	752	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4058-131] Recibo por consumo de agua"	\N
1504	752	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4058-131] Recibo por consumo de agua"	\N
1505	753	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4059-132] Recibo por consumo de agua"	\N
1506	753	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4059-132] Recibo por consumo de agua"	\N
1507	754	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4060-137] Recibo por consumo de agua"	\N
1508	754	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4060-137] Recibo por consumo de agua"	\N
1509	755	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4061-138] Recibo por consumo de agua"	\N
1510	755	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4061-138] Recibo por consumo de agua"	\N
1511	756	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4062-139] Recibo por consumo de agua"	\N
1512	756	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4062-139] Recibo por consumo de agua"	\N
1513	757	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4063-142] Recibo por consumo de agua"	\N
1514	757	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4063-142] Recibo por consumo de agua"	\N
1515	758	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4064-143] Recibo por consumo de agua"	\N
1516	758	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4064-143] Recibo por consumo de agua"	\N
1517	759	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4065-144] Recibo por consumo de agua"	\N
1518	759	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4065-144] Recibo por consumo de agua"	\N
1519	760	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4066-145] Recibo por consumo de agua"	\N
1520	760	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4066-145] Recibo por consumo de agua"	\N
1521	761	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4067-146] Recibo por consumo de agua"	\N
1522	761	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4067-146] Recibo por consumo de agua"	\N
1523	762	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4068-147] Recibo por consumo de agua"	\N
1524	762	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4068-147] Recibo por consumo de agua"	\N
1525	763	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4069-148] Recibo por consumo de agua"	\N
1526	763	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4069-148] Recibo por consumo de agua"	\N
1527	764	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4070-151] Recibo por consumo de agua"	\N
1528	764	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4070-151] Recibo por consumo de agua"	\N
1529	765	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4071-153] Recibo por consumo de agua"	\N
1530	765	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4071-153] Recibo por consumo de agua"	\N
1531	766	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4072-154] Recibo por consumo de agua"	\N
1532	766	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4072-154] Recibo por consumo de agua"	\N
1533	767	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4073-155] Recibo por consumo de agua"	\N
1534	767	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4073-155] Recibo por consumo de agua"	\N
1535	768	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4074-156] Recibo por consumo de agua"	\N
1536	768	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4074-156] Recibo por consumo de agua"	\N
1537	769	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4075-159] Recibo por consumo de agua"	\N
1538	769	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4075-159] Recibo por consumo de agua"	\N
1539	770	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4076-160] Recibo por consumo de agua"	\N
1540	770	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4076-160] Recibo por consumo de agua"	\N
1541	771	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4077-161] Recibo por consumo de agua"	\N
1542	771	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4077-161] Recibo por consumo de agua"	\N
1543	772	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4078-162] Recibo por consumo de agua"	\N
1544	772	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4078-162] Recibo por consumo de agua"	\N
1545	773	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4079-165] Recibo por consumo de agua"	\N
1546	773	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4079-165] Recibo por consumo de agua"	\N
1547	774	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4080-169] Recibo por consumo de agua"	\N
1548	774	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4080-169] Recibo por consumo de agua"	\N
1549	775	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4081-170] Recibo por consumo de agua"	\N
1550	775	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4081-170] Recibo por consumo de agua"	\N
1551	776	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4082-171] Recibo por consumo de agua"	\N
1552	776	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4082-171] Recibo por consumo de agua"	\N
1553	777	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4083-172] Recibo por consumo de agua"	\N
1554	777	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4083-172] Recibo por consumo de agua"	\N
1555	778	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4084-173] Recibo por consumo de agua"	\N
1556	778	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4084-173] Recibo por consumo de agua"	\N
1557	779	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4085-174] Recibo por consumo de agua"	\N
1558	779	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4085-174] Recibo por consumo de agua"	\N
1559	780	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4086-175] Recibo por consumo de agua"	\N
1560	780	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4086-175] Recibo por consumo de agua"	\N
1561	781	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4087-176] Recibo por consumo de agua"	\N
1562	781	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4087-176] Recibo por consumo de agua"	\N
1563	782	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4088-177] Recibo por consumo de agua"	\N
1564	782	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4088-177] Recibo por consumo de agua"	\N
1565	783	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4089-178] Recibo por consumo de agua"	\N
1566	783	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4089-178] Recibo por consumo de agua"	\N
1567	784	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4090-179] Recibo por consumo de agua"	\N
1568	784	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4090-179] Recibo por consumo de agua"	\N
1569	785	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4091-180] Recibo por consumo de agua"	\N
1570	785	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4091-180] Recibo por consumo de agua"	\N
1571	786	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4092-181] Recibo por consumo de agua"	\N
1572	786	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4092-181] Recibo por consumo de agua"	\N
1573	787	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4093-182] Recibo por consumo de agua"	\N
1574	787	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4093-182] Recibo por consumo de agua"	\N
1575	788	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4094-183] Recibo por consumo de agua"	\N
1576	788	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4094-183] Recibo por consumo de agua"	\N
1577	789	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4095-184] Recibo por consumo de agua"	\N
1578	789	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4095-184] Recibo por consumo de agua"	\N
1579	790	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4096-185] Recibo por consumo de agua"	\N
1580	790	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4096-185] Recibo por consumo de agua"	\N
1581	791	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4097-186] Recibo por consumo de agua"	\N
1582	791	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4097-186] Recibo por consumo de agua"	\N
1583	792	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4098-187] Recibo por consumo de agua"	\N
1584	792	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4098-187] Recibo por consumo de agua"	\N
1585	793	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4099-188] Recibo por consumo de agua"	\N
1586	793	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4099-188] Recibo por consumo de agua"	\N
1587	794	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4100-189] Recibo por consumo de agua"	\N
1588	794	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4100-189] Recibo por consumo de agua"	\N
1589	795	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4101-190] Recibo por consumo de agua"	\N
1590	795	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4101-190] Recibo por consumo de agua"	\N
1591	796	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4102-191] Recibo por consumo de agua"	\N
1592	796	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4102-191] Recibo por consumo de agua"	\N
1593	797	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4103-192] Recibo por consumo de agua"	\N
1594	797	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4103-192] Recibo por consumo de agua"	\N
1595	798	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4104-193] Recibo por consumo de agua"	\N
1596	798	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4104-193] Recibo por consumo de agua"	\N
1597	799	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4105-194] Recibo por consumo de agua"	\N
1598	799	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4105-194] Recibo por consumo de agua"	\N
1599	800	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4106-195] Recibo por consumo de agua"	\N
1600	800	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4106-195] Recibo por consumo de agua"	\N
1601	801	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4107-196] Recibo por consumo de agua"	\N
1602	801	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4107-196] Recibo por consumo de agua"	\N
1603	802	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4108-197] Recibo por consumo de agua"	\N
1604	802	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4108-197] Recibo por consumo de agua"	\N
1605	803	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4109-198] Recibo por consumo de agua"	\N
1606	803	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4109-198] Recibo por consumo de agua"	\N
1607	804	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4110-199] Recibo por consumo de agua"	\N
1608	804	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4110-199] Recibo por consumo de agua"	\N
1609	805	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4111-200] Recibo por consumo de agua"	\N
1610	805	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4111-200] Recibo por consumo de agua"	\N
1611	806	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4112-201] Recibo por consumo de agua"	\N
1612	806	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4112-201] Recibo por consumo de agua"	\N
1613	807	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4113-202] Recibo por consumo de agua"	\N
1614	807	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4113-202] Recibo por consumo de agua"	\N
1615	808	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4114-203] Recibo por consumo de agua"	\N
1616	808	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4114-203] Recibo por consumo de agua"	\N
1617	809	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4115-204] Recibo por consumo de agua"	\N
1618	809	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4115-204] Recibo por consumo de agua"	\N
1619	810	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4116-205] Recibo por consumo de agua"	\N
1620	810	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4116-205] Recibo por consumo de agua"	\N
1621	811	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4117-206] Recibo por consumo de agua"	\N
1622	811	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4117-206] Recibo por consumo de agua"	\N
1623	812	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4118-207] Recibo por consumo de agua"	\N
1624	812	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4118-207] Recibo por consumo de agua"	\N
1625	813	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4119-208] Recibo por consumo de agua"	\N
1626	813	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4119-208] Recibo por consumo de agua"	\N
1627	814	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4120-209] Recibo por consumo de agua"	\N
1628	814	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4120-209] Recibo por consumo de agua"	\N
1629	815	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4121-210] Recibo por consumo de agua"	\N
1630	815	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4121-210] Recibo por consumo de agua"	\N
1631	816	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4122-211] Recibo por consumo de agua"	\N
1632	816	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4122-211] Recibo por consumo de agua"	\N
1633	817	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4123-214] Recibo por consumo de agua"	\N
1634	817	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4123-214] Recibo por consumo de agua"	\N
1635	818	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4124-215] Recibo por consumo de agua"	\N
1636	818	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4124-215] Recibo por consumo de agua"	\N
1637	819	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4125-216] Recibo por consumo de agua"	\N
1638	819	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4125-216] Recibo por consumo de agua"	\N
1639	820	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4126-217] Recibo por consumo de agua"	\N
1640	820	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4126-217] Recibo por consumo de agua"	\N
1641	821	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4127-218] Recibo por consumo de agua"	\N
1642	821	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4127-218] Recibo por consumo de agua"	\N
1643	822	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4128-219] Recibo por consumo de agua"	\N
1644	822	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4128-219] Recibo por consumo de agua"	\N
1645	823	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4129-220] Recibo por consumo de agua"	\N
1646	823	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4129-220] Recibo por consumo de agua"	\N
1647	824	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4130-221] Recibo por consumo de agua"	\N
1648	824	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4130-221] Recibo por consumo de agua"	\N
1649	825	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4131-223] Recibo por consumo de agua"	\N
1650	825	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4131-223] Recibo por consumo de agua"	\N
1651	826	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4132-224] Recibo por consumo de agua"	\N
1652	826	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4132-224] Recibo por consumo de agua"	\N
1653	827	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4133-226] Recibo por consumo de agua"	\N
1654	827	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4133-226] Recibo por consumo de agua"	\N
1655	828	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4134-227] Recibo por consumo de agua"	\N
1656	828	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4134-227] Recibo por consumo de agua"	\N
1657	829	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4135-228] Recibo por consumo de agua"	\N
1658	829	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4135-228] Recibo por consumo de agua"	\N
1659	830	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4136-229] Recibo por consumo de agua"	\N
1660	830	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4136-229] Recibo por consumo de agua"	\N
1661	831	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4137-230] Recibo por consumo de agua"	\N
1662	831	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4137-230] Recibo por consumo de agua"	\N
1663	832	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4138-231] Recibo por consumo de agua"	\N
1664	832	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4138-231] Recibo por consumo de agua"	\N
1665	833	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4139-232] Recibo por consumo de agua"	\N
1666	833	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4139-232] Recibo por consumo de agua"	\N
1667	834	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4140-233] Recibo por consumo de agua"	\N
1668	834	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4140-233] Recibo por consumo de agua"	\N
1669	835	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4141-234] Recibo por consumo de agua"	\N
1670	835	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4141-234] Recibo por consumo de agua"	\N
1671	836	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4142-236] Recibo por consumo de agua"	\N
1672	836	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4142-236] Recibo por consumo de agua"	\N
1673	837	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4143-237] Recibo por consumo de agua"	\N
1674	837	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4143-237] Recibo por consumo de agua"	\N
1675	838	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4144-238] Recibo por consumo de agua"	\N
1676	838	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4144-238] Recibo por consumo de agua"	\N
1677	839	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4145-239] Recibo por consumo de agua"	\N
1678	839	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4145-239] Recibo por consumo de agua"	\N
1679	840	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4146-240] Recibo por consumo de agua"	\N
1680	840	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4146-240] Recibo por consumo de agua"	\N
1681	841	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4147-242] Recibo por consumo de agua"	\N
1682	841	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4147-242] Recibo por consumo de agua"	\N
1683	842	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4148-243] Recibo por consumo de agua"	\N
1684	842	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4148-243] Recibo por consumo de agua"	\N
1685	843	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4149-244] Recibo por consumo de agua"	\N
1686	843	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4149-244] Recibo por consumo de agua"	\N
1687	844	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4150-245] Recibo por consumo de agua"	\N
1688	844	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4150-245] Recibo por consumo de agua"	\N
1689	845	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4151-246] Recibo por consumo de agua"	\N
1690	845	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4151-246] Recibo por consumo de agua"	\N
1691	846	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4152-247] Recibo por consumo de agua"	\N
1692	846	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4152-247] Recibo por consumo de agua"	\N
1693	847	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4153-248] Recibo por consumo de agua"	\N
1694	847	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4153-248] Recibo por consumo de agua"	\N
1695	848	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4154-249] Recibo por consumo de agua"	\N
1696	848	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4154-249] Recibo por consumo de agua"	\N
1697	849	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4155-250] Recibo por consumo de agua"	\N
1698	849	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4155-250] Recibo por consumo de agua"	\N
1699	850	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4156-252] Recibo por consumo de agua"	\N
1700	850	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4156-252] Recibo por consumo de agua"	\N
1701	851	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4157-253] Recibo por consumo de agua"	\N
1702	851	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4157-253] Recibo por consumo de agua"	\N
1703	852	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4158-255] Recibo por consumo de agua"	\N
1704	852	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4158-255] Recibo por consumo de agua"	\N
1705	853	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4159-256] Recibo por consumo de agua"	\N
1706	853	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4159-256] Recibo por consumo de agua"	\N
1707	854	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4160-257] Recibo por consumo de agua"	\N
1708	854	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4160-257] Recibo por consumo de agua"	\N
1709	855	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4161-258] Recibo por consumo de agua"	\N
1710	855	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4161-258] Recibo por consumo de agua"	\N
1711	856	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4162-259] Recibo por consumo de agua"	\N
1712	856	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4162-259] Recibo por consumo de agua"	\N
1713	857	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4163-260] Recibo por consumo de agua"	\N
1714	857	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4163-260] Recibo por consumo de agua"	\N
1715	858	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4164-261] Recibo por consumo de agua"	\N
1716	858	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4164-261] Recibo por consumo de agua"	\N
1717	859	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4165-262] Recibo por consumo de agua"	\N
1718	859	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4165-262] Recibo por consumo de agua"	\N
1719	860	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4166-263] Recibo por consumo de agua"	\N
1720	860	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4166-263] Recibo por consumo de agua"	\N
1721	861	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4167-264] Recibo por consumo de agua"	\N
1722	861	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4167-264] Recibo por consumo de agua"	\N
1723	862	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4168-265] Recibo por consumo de agua"	\N
1724	862	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4168-265] Recibo por consumo de agua"	\N
1725	863	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4169-266] Recibo por consumo de agua"	\N
1726	863	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4169-266] Recibo por consumo de agua"	\N
1727	864	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4170-267] Recibo por consumo de agua"	\N
1728	864	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4170-267] Recibo por consumo de agua"	\N
1729	865	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4171-268] Recibo por consumo de agua"	\N
1730	865	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4171-268] Recibo por consumo de agua"	\N
1731	866	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4172-269] Recibo por consumo de agua"	\N
1732	866	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4172-269] Recibo por consumo de agua"	\N
1733	867	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4173-271] Recibo por consumo de agua"	\N
1734	867	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4173-271] Recibo por consumo de agua"	\N
1735	868	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4174-272] Recibo por consumo de agua"	\N
1736	868	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4174-272] Recibo por consumo de agua"	\N
1737	869	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4175-273] Recibo por consumo de agua"	\N
1738	869	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4175-273] Recibo por consumo de agua"	\N
1739	870	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4176-274] Recibo por consumo de agua"	\N
1740	870	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4176-274] Recibo por consumo de agua"	\N
1741	871	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4177-275] Recibo por consumo de agua"	\N
1742	871	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4177-275] Recibo por consumo de agua"	\N
1743	872	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4178-276] Recibo por consumo de agua"	\N
1744	872	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4178-276] Recibo por consumo de agua"	\N
1745	873	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4179-278] Recibo por consumo de agua"	\N
1746	873	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4179-278] Recibo por consumo de agua"	\N
1747	874	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4180-279] Recibo por consumo de agua"	\N
1748	874	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4180-279] Recibo por consumo de agua"	\N
1749	875	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4181-280] Recibo por consumo de agua"	\N
1750	875	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4181-280] Recibo por consumo de agua"	\N
1751	876	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4182-281] Recibo por consumo de agua"	\N
1752	876	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4182-281] Recibo por consumo de agua"	\N
1753	877	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4183-282] Recibo por consumo de agua"	\N
1754	877	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4183-282] Recibo por consumo de agua"	\N
1755	878	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4184-283] Recibo por consumo de agua"	\N
1756	878	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4184-283] Recibo por consumo de agua"	\N
1757	879	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4185-284] Recibo por consumo de agua"	\N
1758	879	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4185-284] Recibo por consumo de agua"	\N
1759	880	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4186-286] Recibo por consumo de agua"	\N
1760	880	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4186-286] Recibo por consumo de agua"	\N
1761	881	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4187-287] Recibo por consumo de agua"	\N
1762	881	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4187-287] Recibo por consumo de agua"	\N
1763	882	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4188-288] Recibo por consumo de agua"	\N
1764	882	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4188-288] Recibo por consumo de agua"	\N
1765	883	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4189-289] Recibo por consumo de agua"	\N
1766	883	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4189-289] Recibo por consumo de agua"	\N
1767	884	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4190-290] Recibo por consumo de agua"	\N
1768	884	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4190-290] Recibo por consumo de agua"	\N
1769	885	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4191-291] Recibo por consumo de agua"	\N
1770	885	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4191-291] Recibo por consumo de agua"	\N
1771	886	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4192-292] Recibo por consumo de agua"	\N
1772	886	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4192-292] Recibo por consumo de agua"	\N
1773	887	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4193-293] Recibo por consumo de agua"	\N
1774	887	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4193-293] Recibo por consumo de agua"	\N
1775	888	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4194-295] Recibo por consumo de agua"	\N
1776	888	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4194-295] Recibo por consumo de agua"	\N
1777	889	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4195-309] Recibo por consumo de agua"	\N
1778	889	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4195-309] Recibo por consumo de agua"	\N
1779	890	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4196-310] Recibo por consumo de agua"	\N
1780	890	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4196-310] Recibo por consumo de agua"	\N
1781	891	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4197-311] Recibo por consumo de agua"	\N
1782	891	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4197-311] Recibo por consumo de agua"	\N
1783	892	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4198-312] Recibo por consumo de agua"	\N
1784	892	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4198-312] Recibo por consumo de agua"	\N
1785	893	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4199-313] Recibo por consumo de agua"	\N
1786	893	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4199-313] Recibo por consumo de agua"	\N
1787	894	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4200-314] Recibo por consumo de agua"	\N
1788	894	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4200-314] Recibo por consumo de agua"	\N
1789	895	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4201-315] Recibo por consumo de agua"	\N
1790	895	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4201-315] Recibo por consumo de agua"	\N
1791	896	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4202-317] Recibo por consumo de agua"	\N
1792	896	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4202-317] Recibo por consumo de agua"	\N
1793	897	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4203-318] Recibo por consumo de agua"	\N
1794	897	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4203-318] Recibo por consumo de agua"	\N
1795	898	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4204-320] Recibo por consumo de agua"	\N
1796	898	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4204-320] Recibo por consumo de agua"	\N
1797	899	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4205-321] Recibo por consumo de agua"	\N
1798	899	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4205-321] Recibo por consumo de agua"	\N
1799	900	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4206-322] Recibo por consumo de agua"	\N
1800	900	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4206-322] Recibo por consumo de agua"	\N
1801	901	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4207-323] Recibo por consumo de agua"	\N
1802	901	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4207-323] Recibo por consumo de agua"	\N
1803	902	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4208-324] Recibo por consumo de agua"	\N
1804	902	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4208-324] Recibo por consumo de agua"	\N
1805	903	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4209-325] Recibo por consumo de agua"	\N
1806	903	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4209-325] Recibo por consumo de agua"	\N
1807	904	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4210-326] Recibo por consumo de agua"	\N
1808	904	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4210-326] Recibo por consumo de agua"	\N
1809	905	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4211-327] Recibo por consumo de agua"	\N
1810	905	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4211-327] Recibo por consumo de agua"	\N
1811	906	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4212-328] Recibo por consumo de agua"	\N
1812	906	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4212-328] Recibo por consumo de agua"	\N
1813	907	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4213-329] Recibo por consumo de agua"	\N
1814	907	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4213-329] Recibo por consumo de agua"	\N
1815	908	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4214-330] Recibo por consumo de agua"	\N
1816	908	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4214-330] Recibo por consumo de agua"	\N
1817	909	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4215-331] Recibo por consumo de agua"	\N
1818	909	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4215-331] Recibo por consumo de agua"	\N
1819	910	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4216-332] Recibo por consumo de agua"	\N
1820	910	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4216-332] Recibo por consumo de agua"	\N
1821	911	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4217-333] Recibo por consumo de agua"	\N
1822	911	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4217-333] Recibo por consumo de agua"	\N
1823	912	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4218-334] Recibo por consumo de agua"	\N
1824	912	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4218-334] Recibo por consumo de agua"	\N
1825	913	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4219-335] Recibo por consumo de agua"	\N
1826	913	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4219-335] Recibo por consumo de agua"	\N
1827	914	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4220-336] Recibo por consumo de agua"	\N
1828	914	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4220-336] Recibo por consumo de agua"	\N
1829	915	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4221-337] Recibo por consumo de agua"	\N
1830	915	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4221-337] Recibo por consumo de agua"	\N
1831	916	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4222-340] Recibo por consumo de agua"	\N
1832	916	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4222-340] Recibo por consumo de agua"	\N
1833	917	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4223-341] Recibo por consumo de agua"	\N
1834	917	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4223-341] Recibo por consumo de agua"	\N
1835	918	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4224-342] Recibo por consumo de agua"	\N
1836	918	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4224-342] Recibo por consumo de agua"	\N
1837	919	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4225-343] Recibo por consumo de agua"	\N
1838	919	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4225-343] Recibo por consumo de agua"	\N
1839	920	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4226-344] Recibo por consumo de agua"	\N
1840	920	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4226-344] Recibo por consumo de agua"	\N
1841	921	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4227-345] Recibo por consumo de agua"	\N
1842	921	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4227-345] Recibo por consumo de agua"	\N
1843	922	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4228-346] Recibo por consumo de agua"	\N
1844	922	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4228-346] Recibo por consumo de agua"	\N
1845	923	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4229-347] Recibo por consumo de agua"	\N
1846	923	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4229-347] Recibo por consumo de agua"	\N
1847	924	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4230-348] Recibo por consumo de agua"	\N
1848	924	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4230-348] Recibo por consumo de agua"	\N
1849	925	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4231-349] Recibo por consumo de agua"	\N
1850	925	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4231-349] Recibo por consumo de agua"	\N
1851	926	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4232-350] Recibo por consumo de agua"	\N
1852	926	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4232-350] Recibo por consumo de agua"	\N
1853	927	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4233-351] Recibo por consumo de agua"	\N
1854	927	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4233-351] Recibo por consumo de agua"	\N
1855	928	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4234-353] Recibo por consumo de agua"	\N
1856	928	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4234-353] Recibo por consumo de agua"	\N
1857	929	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4235-354] Recibo por consumo de agua"	\N
1858	929	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4235-354] Recibo por consumo de agua"	\N
1859	930	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4236-355] Recibo por consumo de agua"	\N
1860	930	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4236-355] Recibo por consumo de agua"	\N
1861	931	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4237-356] Recibo por consumo de agua"	\N
1862	931	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4237-356] Recibo por consumo de agua"	\N
1863	932	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4238-357] Recibo por consumo de agua"	\N
1864	932	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4238-357] Recibo por consumo de agua"	\N
1865	933	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4239-358] Recibo por consumo de agua"	\N
1866	933	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4239-358] Recibo por consumo de agua"	\N
1867	934	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4240-360] Recibo por consumo de agua"	\N
1868	934	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4240-360] Recibo por consumo de agua"	\N
1869	935	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4241-361] Recibo por consumo de agua"	\N
1870	935	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4241-361] Recibo por consumo de agua"	\N
1871	936	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4242-362] Recibo por consumo de agua"	\N
1872	936	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4242-362] Recibo por consumo de agua"	\N
1873	937	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4243-363] Recibo por consumo de agua"	\N
1874	937	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4243-363] Recibo por consumo de agua"	\N
1875	938	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4244-364] Recibo por consumo de agua"	\N
1876	938	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4244-364] Recibo por consumo de agua"	\N
1877	939	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4245-365] Recibo por consumo de agua"	\N
1878	939	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4245-365] Recibo por consumo de agua"	\N
1879	940	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4246-366] Recibo por consumo de agua"	\N
1880	940	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4246-366] Recibo por consumo de agua"	\N
1881	941	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4247-367] Recibo por consumo de agua"	\N
1882	941	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4247-367] Recibo por consumo de agua"	\N
1883	942	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4248-368] Recibo por consumo de agua"	\N
1884	942	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4248-368] Recibo por consumo de agua"	\N
1885	943	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4249-369] Recibo por consumo de agua"	\N
1886	943	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4249-369] Recibo por consumo de agua"	\N
1887	944	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4250-370] Recibo por consumo de agua"	\N
1888	944	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4250-370] Recibo por consumo de agua"	\N
1889	945	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4251-371] Recibo por consumo de agua"	\N
1890	945	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4251-371] Recibo por consumo de agua"	\N
1891	946	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4252-372] Recibo por consumo de agua"	\N
1892	946	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4252-372] Recibo por consumo de agua"	\N
1893	947	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4253-373] Recibo por consumo de agua"	\N
1894	947	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4253-373] Recibo por consumo de agua"	\N
1895	948	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4254-374] Recibo por consumo de agua"	\N
1896	948	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4254-374] Recibo por consumo de agua"	\N
1897	949	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4255-375] Recibo por consumo de agua"	\N
1898	949	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4255-375] Recibo por consumo de agua"	\N
1899	950	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4256-377] Recibo por consumo de agua"	\N
1900	950	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4256-377] Recibo por consumo de agua"	\N
1901	951	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4257-378] Recibo por consumo de agua"	\N
1902	951	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4257-378] Recibo por consumo de agua"	\N
1903	952	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4258-379] Recibo por consumo de agua"	\N
1904	952	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4258-379] Recibo por consumo de agua"	\N
1905	953	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4259-380] Recibo por consumo de agua"	\N
1906	953	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4259-380] Recibo por consumo de agua"	\N
1907	954	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4260-381] Recibo por consumo de agua"	\N
1908	954	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4260-381] Recibo por consumo de agua"	\N
1909	955	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4261-382] Recibo por consumo de agua"	\N
1910	955	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4261-382] Recibo por consumo de agua"	\N
1911	956	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4262-383] Recibo por consumo de agua"	\N
1912	956	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4262-383] Recibo por consumo de agua"	\N
1913	957	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4263-384] Recibo por consumo de agua"	\N
1914	957	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4263-384] Recibo por consumo de agua"	\N
1915	958	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4264-385] Recibo por consumo de agua"	\N
1916	958	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4264-385] Recibo por consumo de agua"	\N
1917	959	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4265-386] Recibo por consumo de agua"	\N
1918	959	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4265-386] Recibo por consumo de agua"	\N
1919	960	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4266-387] Recibo por consumo de agua"	\N
1920	960	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4266-387] Recibo por consumo de agua"	\N
1921	961	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4267-388] Recibo por consumo de agua"	\N
1922	961	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4267-388] Recibo por consumo de agua"	\N
1923	962	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4268-389] Recibo por consumo de agua"	\N
1924	962	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4268-389] Recibo por consumo de agua"	\N
1925	963	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4269-390] Recibo por consumo de agua"	\N
1926	963	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4269-390] Recibo por consumo de agua"	\N
1927	964	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4270-391] Recibo por consumo de agua"	\N
1928	964	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4270-391] Recibo por consumo de agua"	\N
1929	965	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4271-392] Recibo por consumo de agua"	\N
1930	965	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4271-392] Recibo por consumo de agua"	\N
1931	966	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4272-393] Recibo por consumo de agua"	\N
1932	966	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4272-393] Recibo por consumo de agua"	\N
1933	967	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4273-394] Recibo por consumo de agua"	\N
1934	967	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4273-394] Recibo por consumo de agua"	\N
1935	968	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4274-395] Recibo por consumo de agua"	\N
1936	968	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4274-395] Recibo por consumo de agua"	\N
1937	969	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4275-396] Recibo por consumo de agua"	\N
1938	969	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4275-396] Recibo por consumo de agua"	\N
1939	970	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4276-397] Recibo por consumo de agua"	\N
1940	970	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4276-397] Recibo por consumo de agua"	\N
1941	971	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4277-398] Recibo por consumo de agua"	\N
1942	971	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4277-398] Recibo por consumo de agua"	\N
1943	972	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4278-399] Recibo por consumo de agua"	\N
1944	972	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4278-399] Recibo por consumo de agua"	\N
1945	973	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4279-400] Recibo por consumo de agua"	\N
1946	973	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4279-400] Recibo por consumo de agua"	\N
1947	974	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4280-401] Recibo por consumo de agua"	\N
1948	974	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4280-401] Recibo por consumo de agua"	\N
1949	975	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4281-402] Recibo por consumo de agua"	\N
1950	975	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4281-402] Recibo por consumo de agua"	\N
1951	976	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4282-403] Recibo por consumo de agua"	\N
1952	976	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4282-403] Recibo por consumo de agua"	\N
1953	977	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4283-404] Recibo por consumo de agua"	\N
1954	977	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4283-404] Recibo por consumo de agua"	\N
1955	978	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4284-405] Recibo por consumo de agua"	\N
1956	978	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4284-405] Recibo por consumo de agua"	\N
1957	979	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4285-406] Recibo por consumo de agua"	\N
1958	979	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4285-406] Recibo por consumo de agua"	\N
1959	980	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4286-407] Recibo por consumo de agua"	\N
1960	980	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4286-407] Recibo por consumo de agua"	\N
1961	981	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4287-408] Recibo por consumo de agua"	\N
1962	981	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4287-408] Recibo por consumo de agua"	\N
1963	982	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4288-409] Recibo por consumo de agua"	\N
1964	982	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4288-409] Recibo por consumo de agua"	\N
1965	983	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4289-410] Recibo por consumo de agua"	\N
1966	983	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4289-410] Recibo por consumo de agua"	\N
1967	984	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4290-411] Recibo por consumo de agua"	\N
1968	984	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4290-411] Recibo por consumo de agua"	\N
1969	985	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4291-412] Recibo por consumo de agua"	\N
1970	985	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4291-412] Recibo por consumo de agua"	\N
1971	986	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4292-413] Recibo por consumo de agua"	\N
1972	986	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4292-413] Recibo por consumo de agua"	\N
1973	987	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4293-414] Recibo por consumo de agua"	\N
1974	987	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4293-414] Recibo por consumo de agua"	\N
1975	988	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4294-415] Recibo por consumo de agua"	\N
1976	988	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4294-415] Recibo por consumo de agua"	\N
1977	989	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4295-416] Recibo por consumo de agua"	\N
1978	989	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4295-416] Recibo por consumo de agua"	\N
1979	990	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4296-417] Recibo por consumo de agua"	\N
1980	990	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4296-417] Recibo por consumo de agua"	\N
1981	991	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4297-418] Recibo por consumo de agua"	\N
1982	991	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4297-418] Recibo por consumo de agua"	\N
1983	992	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4298-419] Recibo por consumo de agua"	\N
1984	992	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4298-419] Recibo por consumo de agua"	\N
1985	993	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4299-420] Recibo por consumo de agua"	\N
1986	993	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4299-420] Recibo por consumo de agua"	\N
1987	994	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4300-424] Recibo por consumo de agua"	\N
1988	994	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4300-424] Recibo por consumo de agua"	\N
1989	995	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4301-426] Recibo por consumo de agua"	\N
1990	995	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4301-426] Recibo por consumo de agua"	\N
1991	996	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4302-427] Recibo por consumo de agua"	\N
1992	996	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4302-427] Recibo por consumo de agua"	\N
1993	997	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4303-428] Recibo por consumo de agua"	\N
1994	997	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4303-428] Recibo por consumo de agua"	\N
1995	998	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4304-430] Recibo por consumo de agua"	\N
1996	998	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4304-430] Recibo por consumo de agua"	\N
1997	999	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4305-433] Recibo por consumo de agua"	\N
1998	999	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4305-433] Recibo por consumo de agua"	\N
1999	1000	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4306-434] Recibo por consumo de agua"	\N
2000	1000	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4306-434] Recibo por consumo de agua"	\N
2001	1001	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4307-435] Recibo por consumo de agua"	\N
2002	1001	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4307-435] Recibo por consumo de agua"	\N
2003	1002	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4308-438] Recibo por consumo de agua"	\N
2004	1002	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4308-438] Recibo por consumo de agua"	\N
2005	1003	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4309-439] Recibo por consumo de agua"	\N
2006	1003	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4309-439] Recibo por consumo de agua"	\N
2007	1004	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4310-440] Recibo por consumo de agua"	\N
2008	1004	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4310-440] Recibo por consumo de agua"	\N
2009	1005	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4311-441] Recibo por consumo de agua"	\N
2010	1005	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4311-441] Recibo por consumo de agua"	\N
2011	1006	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4312-442] Recibo por consumo de agua"	\N
2012	1006	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4312-442] Recibo por consumo de agua"	\N
2013	1007	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4313-444] Recibo por consumo de agua"	\N
2014	1007	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4313-444] Recibo por consumo de agua"	\N
2015	1008	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4314-445] Recibo por consumo de agua"	\N
2016	1008	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4314-445] Recibo por consumo de agua"	\N
2017	1009	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4315-447] Recibo por consumo de agua"	\N
2018	1009	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4315-447] Recibo por consumo de agua"	\N
2019	1010	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4316-448] Recibo por consumo de agua"	\N
2020	1010	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4316-448] Recibo por consumo de agua"	\N
2021	1011	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4317-451] Recibo por consumo de agua"	\N
2022	1011	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4317-451] Recibo por consumo de agua"	\N
2023	1012	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4318-452] Recibo por consumo de agua"	\N
2024	1012	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4318-452] Recibo por consumo de agua"	\N
2025	1013	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4319-453] Recibo por consumo de agua"	\N
2026	1013	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4319-453] Recibo por consumo de agua"	\N
2027	1014	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4320-454] Recibo por consumo de agua"	\N
2028	1014	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4320-454] Recibo por consumo de agua"	\N
2029	1015	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4321-456] Recibo por consumo de agua"	\N
2030	1015	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4321-456] Recibo por consumo de agua"	\N
2031	1016	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4322-457] Recibo por consumo de agua"	\N
2032	1016	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4322-457] Recibo por consumo de agua"	\N
2033	1017	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4323-458] Recibo por consumo de agua"	\N
2034	1017	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4323-458] Recibo por consumo de agua"	\N
2035	1018	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4324-459] Recibo por consumo de agua"	\N
2036	1018	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4324-459] Recibo por consumo de agua"	\N
2037	1019	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4325-460] Recibo por consumo de agua"	\N
2038	1019	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4325-460] Recibo por consumo de agua"	\N
2039	1020	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4326-461] Recibo por consumo de agua"	\N
2040	1020	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4326-461] Recibo por consumo de agua"	\N
2041	1021	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4327-463] Recibo por consumo de agua"	\N
2042	1021	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4327-463] Recibo por consumo de agua"	\N
2043	1022	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4328-466] Recibo por consumo de agua"	\N
2044	1022	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4328-466] Recibo por consumo de agua"	\N
2045	1023	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4329-468] Recibo por consumo de agua"	\N
2046	1023	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4329-468] Recibo por consumo de agua"	\N
2047	1024	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4330-469] Recibo por consumo de agua"	\N
2048	1024	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4330-469] Recibo por consumo de agua"	\N
2049	1025	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4331-471] Recibo por consumo de agua"	\N
2050	1025	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4331-471] Recibo por consumo de agua"	\N
2051	1026	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4332-472] Recibo por consumo de agua"	\N
2052	1026	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4332-472] Recibo por consumo de agua"	\N
2053	1027	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4333-473] Recibo por consumo de agua"	\N
2054	1027	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4333-473] Recibo por consumo de agua"	\N
2055	1028	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4334-474] Recibo por consumo de agua"	\N
2056	1028	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4334-474] Recibo por consumo de agua"	\N
2057	1029	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4335-475] Recibo por consumo de agua"	\N
2058	1029	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4335-475] Recibo por consumo de agua"	\N
2059	1030	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4336-476] Recibo por consumo de agua"	\N
2060	1030	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4336-476] Recibo por consumo de agua"	\N
2061	1031	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4337-477] Recibo por consumo de agua"	\N
2062	1031	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4337-477] Recibo por consumo de agua"	\N
2063	1032	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4338-478] Recibo por consumo de agua"	\N
2064	1032	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4338-478] Recibo por consumo de agua"	\N
2065	1033	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4339-479] Recibo por consumo de agua"	\N
2066	1033	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4339-479] Recibo por consumo de agua"	\N
2067	1034	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4340-480] Recibo por consumo de agua"	\N
2068	1034	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4340-480] Recibo por consumo de agua"	\N
2069	1035	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4341-481] Recibo por consumo de agua"	\N
2070	1035	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4341-481] Recibo por consumo de agua"	\N
2071	1036	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4342-482] Recibo por consumo de agua"	\N
2072	1036	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4342-482] Recibo por consumo de agua"	\N
2073	1037	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4343-484] Recibo por consumo de agua"	\N
2074	1037	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4343-484] Recibo por consumo de agua"	\N
2075	1038	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4344-485] Recibo por consumo de agua"	\N
2076	1038	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4344-485] Recibo por consumo de agua"	\N
2077	1039	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4345-486] Recibo por consumo de agua"	\N
2078	1039	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4345-486] Recibo por consumo de agua"	\N
2079	1040	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4346-487] Recibo por consumo de agua"	\N
2080	1040	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4346-487] Recibo por consumo de agua"	\N
2081	1041	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4347-493] Recibo por consumo de agua"	\N
2082	1041	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4347-493] Recibo por consumo de agua"	\N
2083	1042	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4348-495] Recibo por consumo de agua"	\N
2084	1042	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4348-495] Recibo por consumo de agua"	\N
2085	1043	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4349-498] Recibo por consumo de agua"	\N
2086	1043	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4349-498] Recibo por consumo de agua"	\N
2087	1044	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4350-499] Recibo por consumo de agua"	\N
2088	1044	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4350-499] Recibo por consumo de agua"	\N
2089	1045	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4351-501] Recibo por consumo de agua"	\N
2090	1045	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4351-501] Recibo por consumo de agua"	\N
2091	1046	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4352-502] Recibo por consumo de agua"	\N
2092	1046	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4352-502] Recibo por consumo de agua"	\N
2093	1047	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4353-503] Recibo por consumo de agua"	\N
2094	1047	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4353-503] Recibo por consumo de agua"	\N
2095	1048	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4354-504] Recibo por consumo de agua"	\N
2096	1048	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4354-504] Recibo por consumo de agua"	\N
2097	1049	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4355-506] Recibo por consumo de agua"	\N
2098	1049	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4355-506] Recibo por consumo de agua"	\N
2099	1050	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4356-507] Recibo por consumo de agua"	\N
2100	1050	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4356-507] Recibo por consumo de agua"	\N
2101	1051	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4357-508] Recibo por consumo de agua"	\N
2102	1051	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4357-508] Recibo por consumo de agua"	\N
2103	1052	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4358-509] Recibo por consumo de agua"	\N
2104	1052	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4358-509] Recibo por consumo de agua"	\N
2105	1053	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4359-513] Recibo por consumo de agua"	\N
2106	1053	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4359-513] Recibo por consumo de agua"	\N
2107	1054	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4360-514] Recibo por consumo de agua"	\N
2108	1054	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4360-514] Recibo por consumo de agua"	\N
2109	1055	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4361-515] Recibo por consumo de agua"	\N
2110	1055	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4361-515] Recibo por consumo de agua"	\N
2111	1056	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4362-516] Recibo por consumo de agua"	\N
2112	1056	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4362-516] Recibo por consumo de agua"	\N
2113	1057	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4363-517] Recibo por consumo de agua"	\N
2114	1057	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4363-517] Recibo por consumo de agua"	\N
2115	1058	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4364-518] Recibo por consumo de agua"	\N
2116	1058	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4364-518] Recibo por consumo de agua"	\N
2117	1059	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4365-519] Recibo por consumo de agua"	\N
2118	1059	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4365-519] Recibo por consumo de agua"	\N
2119	1060	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4366-520] Recibo por consumo de agua"	\N
2120	1060	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4366-520] Recibo por consumo de agua"	\N
2121	1061	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4367-521] Recibo por consumo de agua"	\N
2122	1061	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4367-521] Recibo por consumo de agua"	\N
2123	1062	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4368-522] Recibo por consumo de agua"	\N
2124	1062	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4368-522] Recibo por consumo de agua"	\N
2125	1063	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4369-523] Recibo por consumo de agua"	\N
2126	1063	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4369-523] Recibo por consumo de agua"	\N
2127	1064	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4370-524] Recibo por consumo de agua"	\N
2128	1064	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4370-524] Recibo por consumo de agua"	\N
2129	1065	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4371-527] Recibo por consumo de agua"	\N
2130	1065	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4371-527] Recibo por consumo de agua"	\N
2131	1066	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4372-528] Recibo por consumo de agua"	\N
2132	1066	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4372-528] Recibo por consumo de agua"	\N
2133	1067	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4373-530] Recibo por consumo de agua"	\N
2134	1067	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4373-530] Recibo por consumo de agua"	\N
2135	1068	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4374-531] Recibo por consumo de agua"	\N
2136	1068	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4374-531] Recibo por consumo de agua"	\N
2137	1069	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4375-532] Recibo por consumo de agua"	\N
2138	1069	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4375-532] Recibo por consumo de agua"	\N
2139	1070	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4376-533] Recibo por consumo de agua"	\N
2140	1070	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4376-533] Recibo por consumo de agua"	\N
2141	1071	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4377-534] Recibo por consumo de agua"	\N
2142	1071	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4377-534] Recibo por consumo de agua"	\N
2143	1072	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4378-537] Recibo por consumo de agua"	\N
2144	1072	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4378-537] Recibo por consumo de agua"	\N
2145	1073	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4379-538] Recibo por consumo de agua"	\N
2146	1073	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4379-538] Recibo por consumo de agua"	\N
2147	1074	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4380-539] Recibo por consumo de agua"	\N
2148	1074	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4380-539] Recibo por consumo de agua"	\N
2149	1075	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4381-541] Recibo por consumo de agua"	\N
2150	1075	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4381-541] Recibo por consumo de agua"	\N
2151	1076	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4382-544] Recibo por consumo de agua"	\N
2152	1076	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4382-544] Recibo por consumo de agua"	\N
2153	1077	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4383-545] Recibo por consumo de agua"	\N
2154	1077	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4383-545] Recibo por consumo de agua"	\N
2155	1078	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4384-546] Recibo por consumo de agua"	\N
2156	1078	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4384-546] Recibo por consumo de agua"	\N
2157	1079	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4385-551] Recibo por consumo de agua"	\N
2158	1079	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4385-551] Recibo por consumo de agua"	\N
2159	1080	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4386-552] Recibo por consumo de agua"	\N
2160	1080	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4386-552] Recibo por consumo de agua"	\N
2161	1081	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4387-553] Recibo por consumo de agua"	\N
2162	1081	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4387-553] Recibo por consumo de agua"	\N
2163	1082	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4388-554] Recibo por consumo de agua"	\N
2164	1082	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4388-554] Recibo por consumo de agua"	\N
2165	1083	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4389-557] Recibo por consumo de agua"	\N
2166	1083	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4389-557] Recibo por consumo de agua"	\N
2167	1084	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4390-558] Recibo por consumo de agua"	\N
2168	1084	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4390-558] Recibo por consumo de agua"	\N
2169	1085	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4391-560] Recibo por consumo de agua"	\N
2170	1085	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4391-560] Recibo por consumo de agua"	\N
2171	1086	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4392-562] Recibo por consumo de agua"	\N
2172	1086	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4392-562] Recibo por consumo de agua"	\N
2173	1087	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4393-563] Recibo por consumo de agua"	\N
2174	1087	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4393-563] Recibo por consumo de agua"	\N
2175	1088	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4394-565] Recibo por consumo de agua"	\N
2176	1088	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4394-565] Recibo por consumo de agua"	\N
2177	1089	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4395-566] Recibo por consumo de agua"	\N
2178	1089	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4395-566] Recibo por consumo de agua"	\N
2179	1090	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4396-567] Recibo por consumo de agua"	\N
2180	1090	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4396-567] Recibo por consumo de agua"	\N
2181	1091	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4397-568] Recibo por consumo de agua"	\N
2182	1091	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4397-568] Recibo por consumo de agua"	\N
2183	1092	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4398-569] Recibo por consumo de agua"	\N
2184	1092	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4398-569] Recibo por consumo de agua"	\N
2185	1093	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4399-570] Recibo por consumo de agua"	\N
2186	1093	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4399-570] Recibo por consumo de agua"	\N
2187	1094	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4400-571] Recibo por consumo de agua"	\N
2188	1094	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4400-571] Recibo por consumo de agua"	\N
2189	1095	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4401-572] Recibo por consumo de agua"	\N
2190	1095	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4401-572] Recibo por consumo de agua"	\N
2191	1096	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4402-574] Recibo por consumo de agua"	\N
2192	1096	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4402-574] Recibo por consumo de agua"	\N
2193	1097	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4403-575] Recibo por consumo de agua"	\N
2194	1097	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4403-575] Recibo por consumo de agua"	\N
2195	1098	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4404-576] Recibo por consumo de agua"	\N
2196	1098	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4404-576] Recibo por consumo de agua"	\N
2197	1099	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4405-577] Recibo por consumo de agua"	\N
2198	1099	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4405-577] Recibo por consumo de agua"	\N
2199	1100	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4406-578] Recibo por consumo de agua"	\N
2200	1100	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4406-578] Recibo por consumo de agua"	\N
2201	1101	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4407-579] Recibo por consumo de agua"	\N
2202	1101	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4407-579] Recibo por consumo de agua"	\N
2203	1102	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4408-580] Recibo por consumo de agua"	\N
2204	1102	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4408-580] Recibo por consumo de agua"	\N
2205	1103	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4409-581] Recibo por consumo de agua"	\N
2206	1103	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4409-581] Recibo por consumo de agua"	\N
2207	1104	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4410-583] Recibo por consumo de agua"	\N
2208	1104	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4410-583] Recibo por consumo de agua"	\N
2209	1105	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4411-587] Recibo por consumo de agua"	\N
2210	1105	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4411-587] Recibo por consumo de agua"	\N
2211	1106	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4412-588] Recibo por consumo de agua"	\N
2212	1106	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4412-588] Recibo por consumo de agua"	\N
2213	1107	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4413-591] Recibo por consumo de agua"	\N
2214	1107	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4413-591] Recibo por consumo de agua"	\N
2215	1108	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4414-592] Recibo por consumo de agua"	\N
2216	1108	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4414-592] Recibo por consumo de agua"	\N
2217	1109	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4415-593] Recibo por consumo de agua"	\N
2218	1109	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4415-593] Recibo por consumo de agua"	\N
2219	1110	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4416-594] Recibo por consumo de agua"	\N
2220	1110	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4416-594] Recibo por consumo de agua"	\N
2221	1111	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4417-595] Recibo por consumo de agua"	\N
2222	1111	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4417-595] Recibo por consumo de agua"	\N
2223	1112	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4418-596] Recibo por consumo de agua"	\N
2224	1112	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4418-596] Recibo por consumo de agua"	\N
2225	1113	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4419-597] Recibo por consumo de agua"	\N
2226	1113	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4419-597] Recibo por consumo de agua"	\N
2227	1114	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4420-598] Recibo por consumo de agua"	\N
2228	1114	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4420-598] Recibo por consumo de agua"	\N
2229	1115	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4421-599] Recibo por consumo de agua"	\N
2230	1115	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4421-599] Recibo por consumo de agua"	\N
2231	1116	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4422-601] Recibo por consumo de agua"	\N
2232	1116	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4422-601] Recibo por consumo de agua"	\N
2233	1117	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4423-602] Recibo por consumo de agua"	\N
2234	1117	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4423-602] Recibo por consumo de agua"	\N
2235	1118	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4424-603] Recibo por consumo de agua"	\N
2236	1118	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4424-603] Recibo por consumo de agua"	\N
2237	1119	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4425-604] Recibo por consumo de agua"	\N
2238	1119	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4425-604] Recibo por consumo de agua"	\N
2239	1120	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4426-605] Recibo por consumo de agua"	\N
2240	1120	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4426-605] Recibo por consumo de agua"	\N
2241	1121	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4427-606] Recibo por consumo de agua"	\N
2242	1121	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4427-606] Recibo por consumo de agua"	\N
2243	1122	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4428-607] Recibo por consumo de agua"	\N
2244	1122	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4428-607] Recibo por consumo de agua"	\N
2245	1123	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4429-608] Recibo por consumo de agua"	\N
2246	1123	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4429-608] Recibo por consumo de agua"	\N
2247	1124	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4430-609] Recibo por consumo de agua"	\N
2248	1124	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4430-609] Recibo por consumo de agua"	\N
2249	1125	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4431-610] Recibo por consumo de agua"	\N
2250	1125	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4431-610] Recibo por consumo de agua"	\N
2251	1126	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4432-611] Recibo por consumo de agua"	\N
2252	1126	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4432-611] Recibo por consumo de agua"	\N
2253	1127	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4433-612] Recibo por consumo de agua"	\N
2254	1127	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4433-612] Recibo por consumo de agua"	\N
2255	1128	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4434-613] Recibo por consumo de agua"	\N
2256	1128	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4434-613] Recibo por consumo de agua"	\N
2257	1129	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4435-614] Recibo por consumo de agua"	\N
2258	1129	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4435-614] Recibo por consumo de agua"	\N
2259	1130	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4436-615] Recibo por consumo de agua"	\N
2260	1130	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4436-615] Recibo por consumo de agua"	\N
2261	1131	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4437-616] Recibo por consumo de agua"	\N
2262	1131	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4437-616] Recibo por consumo de agua"	\N
2263	1132	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4438-617] Recibo por consumo de agua"	\N
2264	1132	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4438-617] Recibo por consumo de agua"	\N
2265	1133	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4439-618] Recibo por consumo de agua"	\N
2266	1133	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4439-618] Recibo por consumo de agua"	\N
2267	1134	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4440-619] Recibo por consumo de agua"	\N
2268	1134	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4440-619] Recibo por consumo de agua"	\N
2269	1135	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4441-621] Recibo por consumo de agua"	\N
2270	1135	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4441-621] Recibo por consumo de agua"	\N
2271	1136	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4442-624] Recibo por consumo de agua"	\N
2272	1136	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4442-624] Recibo por consumo de agua"	\N
2273	1137	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4443-625] Recibo por consumo de agua"	\N
2274	1137	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4443-625] Recibo por consumo de agua"	\N
2275	1138	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4444-626] Recibo por consumo de agua"	\N
2276	1138	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4444-626] Recibo por consumo de agua"	\N
2277	1139	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4445-627] Recibo por consumo de agua"	\N
2278	1139	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4445-627] Recibo por consumo de agua"	\N
2279	1140	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4446-628] Recibo por consumo de agua"	\N
2280	1140	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4446-628] Recibo por consumo de agua"	\N
2281	1141	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4447-629] Recibo por consumo de agua"	\N
2282	1141	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4447-629] Recibo por consumo de agua"	\N
2283	1142	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4448-630] Recibo por consumo de agua"	\N
2284	1142	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4448-630] Recibo por consumo de agua"	\N
2285	1143	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4449-631] Recibo por consumo de agua"	\N
2286	1143	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4449-631] Recibo por consumo de agua"	\N
2287	1144	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4450-632] Recibo por consumo de agua"	\N
2288	1144	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4450-632] Recibo por consumo de agua"	\N
2289	1145	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4451-633] Recibo por consumo de agua"	\N
2290	1145	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4451-633] Recibo por consumo de agua"	\N
2291	1146	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4452-634] Recibo por consumo de agua"	\N
2292	1146	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4452-634] Recibo por consumo de agua"	\N
2293	1147	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4453-635] Recibo por consumo de agua"	\N
2294	1147	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4453-635] Recibo por consumo de agua"	\N
2295	1148	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4454-637] Recibo por consumo de agua"	\N
2296	1148	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4454-637] Recibo por consumo de agua"	\N
2297	1149	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4455-638] Recibo por consumo de agua"	\N
2298	1149	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4455-638] Recibo por consumo de agua"	\N
2299	1150	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4456-639] Recibo por consumo de agua"	\N
2300	1150	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4456-639] Recibo por consumo de agua"	\N
2301	1151	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4457-640] Recibo por consumo de agua"	\N
2302	1151	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4457-640] Recibo por consumo de agua"	\N
2303	1152	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4458-641] Recibo por consumo de agua"	\N
2304	1152	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4458-641] Recibo por consumo de agua"	\N
2305	1153	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4459-645] Recibo por consumo de agua"	\N
2306	1153	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4459-645] Recibo por consumo de agua"	\N
2307	1154	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4460-647] Recibo por consumo de agua"	\N
2308	1154	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4460-647] Recibo por consumo de agua"	\N
2309	1155	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4461-648] Recibo por consumo de agua"	\N
2310	1155	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4461-648] Recibo por consumo de agua"	\N
2311	1156	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4462-649] Recibo por consumo de agua"	\N
2312	1156	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4462-649] Recibo por consumo de agua"	\N
2313	1157	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4463-650] Recibo por consumo de agua"	\N
2314	1157	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4463-650] Recibo por consumo de agua"	\N
2315	1158	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4464-653] Recibo por consumo de agua"	\N
2316	1158	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4464-653] Recibo por consumo de agua"	\N
2317	1159	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4465-655] Recibo por consumo de agua"	\N
2318	1159	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4465-655] Recibo por consumo de agua"	\N
2319	1160	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4466-656] Recibo por consumo de agua"	\N
2320	1160	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4466-656] Recibo por consumo de agua"	\N
2321	1161	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4467-657] Recibo por consumo de agua"	\N
2322	1161	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4467-657] Recibo por consumo de agua"	\N
2323	1162	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4468-658] Recibo por consumo de agua"	\N
2324	1162	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4468-658] Recibo por consumo de agua"	\N
2325	1163	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4469-659] Recibo por consumo de agua"	\N
2326	1163	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4469-659] Recibo por consumo de agua"	\N
2327	1164	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4470-660] Recibo por consumo de agua"	\N
2328	1164	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4470-660] Recibo por consumo de agua"	\N
2329	1165	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4471-661] Recibo por consumo de agua"	\N
2330	1165	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4471-661] Recibo por consumo de agua"	\N
2331	1166	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4472-662] Recibo por consumo de agua"	\N
2332	1166	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4472-662] Recibo por consumo de agua"	\N
2333	1167	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4473-663] Recibo por consumo de agua"	\N
2334	1167	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4473-663] Recibo por consumo de agua"	\N
2335	1168	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4474-664] Recibo por consumo de agua"	\N
2336	1168	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4474-664] Recibo por consumo de agua"	\N
2337	1169	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4475-665] Recibo por consumo de agua"	\N
2338	1169	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4475-665] Recibo por consumo de agua"	\N
2339	1170	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4476-666] Recibo por consumo de agua"	\N
2340	1170	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4476-666] Recibo por consumo de agua"	\N
2341	1171	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4477-667] Recibo por consumo de agua"	\N
2342	1171	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4477-667] Recibo por consumo de agua"	\N
2343	1172	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4478-668] Recibo por consumo de agua"	\N
2344	1172	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4478-668] Recibo por consumo de agua"	\N
2345	1173	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4479-669] Recibo por consumo de agua"	\N
2346	1173	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4479-669] Recibo por consumo de agua"	\N
2347	1174	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4480-670] Recibo por consumo de agua"	\N
2348	1174	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4480-670] Recibo por consumo de agua"	\N
2349	1175	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4481-671] Recibo por consumo de agua"	\N
2350	1175	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4481-671] Recibo por consumo de agua"	\N
2351	1176	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4482-673] Recibo por consumo de agua"	\N
2352	1176	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4482-673] Recibo por consumo de agua"	\N
2353	1177	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4483-674] Recibo por consumo de agua"	\N
2354	1177	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4483-674] Recibo por consumo de agua"	\N
2355	1178	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4484-675] Recibo por consumo de agua"	\N
2356	1178	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4484-675] Recibo por consumo de agua"	\N
2357	1179	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4485-676] Recibo por consumo de agua"	\N
2358	1179	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4485-676] Recibo por consumo de agua"	\N
2359	1180	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4486-677] Recibo por consumo de agua"	\N
2360	1180	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4486-677] Recibo por consumo de agua"	\N
2361	1181	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4487-678] Recibo por consumo de agua"	\N
2362	1181	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4487-678] Recibo por consumo de agua"	\N
2363	1182	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4488-679] Recibo por consumo de agua"	\N
2364	1182	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4488-679] Recibo por consumo de agua"	\N
2365	1183	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4489-680] Recibo por consumo de agua"	\N
2366	1183	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4489-680] Recibo por consumo de agua"	\N
2367	1184	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4490-681] Recibo por consumo de agua"	\N
2368	1184	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4490-681] Recibo por consumo de agua"	\N
2369	1185	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4491-682] Recibo por consumo de agua"	\N
2370	1185	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4491-682] Recibo por consumo de agua"	\N
2371	1186	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4492-683] Recibo por consumo de agua"	\N
2372	1186	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4492-683] Recibo por consumo de agua"	\N
2373	1187	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4493-684] Recibo por consumo de agua"	\N
2374	1187	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4493-684] Recibo por consumo de agua"	\N
2375	1188	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4494-686] Recibo por consumo de agua"	\N
2376	1188	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4494-686] Recibo por consumo de agua"	\N
2377	1189	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4495-688] Recibo por consumo de agua"	\N
2378	1189	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4495-688] Recibo por consumo de agua"	\N
2379	1190	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4496-689] Recibo por consumo de agua"	\N
2380	1190	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4496-689] Recibo por consumo de agua"	\N
2381	1191	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4497-690] Recibo por consumo de agua"	\N
2382	1191	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4497-690] Recibo por consumo de agua"	\N
2383	1192	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4498-691] Recibo por consumo de agua"	\N
2384	1192	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4498-691] Recibo por consumo de agua"	\N
2385	1193	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4499-692] Recibo por consumo de agua"	\N
2386	1193	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4499-692] Recibo por consumo de agua"	\N
2387	1194	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4500-693] Recibo por consumo de agua"	\N
2388	1194	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4500-693] Recibo por consumo de agua"	\N
2389	1195	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4501-694] Recibo por consumo de agua"	\N
2390	1195	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4501-694] Recibo por consumo de agua"	\N
2391	1196	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4502-695] Recibo por consumo de agua"	\N
2392	1196	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4502-695] Recibo por consumo de agua"	\N
2393	1197	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4503-696] Recibo por consumo de agua"	\N
2394	1197	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4503-696] Recibo por consumo de agua"	\N
2395	1198	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4504-697] Recibo por consumo de agua"	\N
2396	1198	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4504-697] Recibo por consumo de agua"	\N
2397	1199	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4505-698] Recibo por consumo de agua"	\N
2398	1199	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4505-698] Recibo por consumo de agua"	\N
2399	1200	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4506-700] Recibo por consumo de agua"	\N
2400	1200	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4506-700] Recibo por consumo de agua"	\N
2401	1201	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4507-701] Recibo por consumo de agua"	\N
2402	1201	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4507-701] Recibo por consumo de agua"	\N
2403	1202	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4508-702] Recibo por consumo de agua"	\N
2404	1202	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4508-702] Recibo por consumo de agua"	\N
2405	1203	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4509-703] Recibo por consumo de agua"	\N
2406	1203	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4509-703] Recibo por consumo de agua"	\N
2407	1204	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4510-704] Recibo por consumo de agua"	\N
2408	1204	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4510-704] Recibo por consumo de agua"	\N
2409	1205	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4511-705] Recibo por consumo de agua"	\N
2410	1205	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4511-705] Recibo por consumo de agua"	\N
2411	1206	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4512-706] Recibo por consumo de agua"	\N
2412	1206	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4512-706] Recibo por consumo de agua"	\N
2413	1207	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4513-707] Recibo por consumo de agua"	\N
2414	1207	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4513-707] Recibo por consumo de agua"	\N
2415	1208	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4514-708] Recibo por consumo de agua"	\N
2416	1208	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4514-708] Recibo por consumo de agua"	\N
2417	1209	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4515-709] Recibo por consumo de agua"	\N
2418	1209	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4515-709] Recibo por consumo de agua"	\N
2419	1210	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4516-710] Recibo por consumo de agua"	\N
2420	1210	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4516-710] Recibo por consumo de agua"	\N
2421	1211	259	5.25	t	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4517-711] Recibo por consumo de agua"	\N
2422	1211	204	5.25	f	1	2015-02-16 20:51:44	2015-02-16	9	t	"[4517-711] Recibo por consumo de agua"	\N
\.


--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 239
-- Name: scr_transaccion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_transaccion_id_seq', 3520, true);


--
-- TOC entry 2581 (class 0 OID 17643)
-- Dependencies: 240 2590
-- Data for Name: scr_u_medida_produc; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_u_medida_produc (id, "uMedidaProducNombre", "uMedidaProducDescrip") FROM stdin;
\.


--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 241
-- Name: scr_u_medida_produc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('scr_u_medida_produc_id_seq', 1, false);


--
-- TOC entry 2583 (class 0 OID 17651)
-- Dependencies: 242 2590
-- Data for Name: scr_usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_usuario (id, username, password, correousuario, detalleuuario, ultimavisitausuario, ipusuario, salt, nombreusuario, apellidousuario, telefonousuario, nacimientousuario, latusuario, lonusuario, direccionusuario, sexousuario, registrousuario, cuentausuario, estado_id, localidad_id, imagenusuario, contador) FROM stdin;
7	root	a6186d50e8c59041178bac8bbc4cc4a7013e0f6d3b701142ddf213190f0d346abe83f23de752dd26ce674aa5de163f30ccccd57912f4594f8a411b869d2c44c8	root@mail.com		2014-12-06 09:29:48	127.0.0.1	70341034178477204811252659007728794512	root	acrasame	99999999	2014-01-01	1	1	\N	3	2014-12-06 09:29:48	<cuentas><anda>0000</anda></cuentas>	1	13	\N	7
651	Socio 621	0ef53d0631868fb1b800cb2a6c8b42d29fedd3c7f6f6130362503cfcd77884724cbcefc883b6de733c24464ed9ebb5dbc2cce7beaa94f3ce021b194508dbbd37	Socio621@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	124529828929603537296288447098450097023	Jose Maria	Abrego	621	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
652	Socio 622	3014d4e851f2395333c6f772d009e26d6dc0fdce172892ecb20b07eecdb580ea55870c033ffd163ceb702dd12a1b8f7649b9ef05757157fa6f5c4c308574d481	Socio622@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	131309834763514957567389687936198119964	Enamorado Marcial	Casco	622	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
654	Socio 624	529552c8a26f934080c1fff58ed13b8f968ec7b0cb1c35e4d0a07a8cb661c1942362fa9b90ff672673af5cf56e835f76a13dbae113ae2e51af6a3e69410bd534	Socio624@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	164163288693446802992655064239951727991	Pablo Antonio	Vasquez Rodriguez	624	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
672	Socio 642	b37949325a023f3a5eaa0874a60265c2dbef3bc3ca79004b9e0220a5a3e4e1e5c9ca017150589cbbd1dfeb73e19039b2b42f57c1c84af489030182bb393a3a7f	Socio642@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	187575247472036018952011028592829729929	Oscar	Casco	642	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
685	Socio 655	5b4b2ac758a129036b86bfb5f52e11ce146abc780477553d646ebd7193c4543c9e43a27b04861400c4975c004afba1fb70a43eb07c4bcd232781b17f5319bd35	Socio655@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	251550850126805069362969028752512328207	Yesenia	Andrades	655	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
687	Socio 657	0a0e535fca17fbaa0ef3fe4d02e8a0e204d95cdf16f68f34140fe37bddf9ce00ab474f12833f13d7ea9b3f77052aadfb182e9e228e91311d997276e48c694df6	Socio657@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	188901042258634400304486011235189251316	Feliciano Antonio	Huezo	657	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
699	Socio 669	4cff923094da92a432f363142b7a06da5f274f3ce65fe6f1ee88074c8c89e7ee635784ef483f771f0671f4774601c8e22509c00eff90b8ef95997b53c34cc28b	Socio669@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	92569983120412053176405636035774463216	Oscar	Lopez	669	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
31	Socio 6	c0d4b3c3cc03cac83f9d698303053a8b8a000257f0682b22cc804571a6e53007cf14e4a5a53d8c876082bf1dcc098885892e949a8ec479adf89a850da14529c2	Socio6@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	29690914246999899603675752904744935990	Marta Alicia	Montoya	6	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
34	Socio 9	70bf9068c774afbf531fa2e7311fe483eac381b0bcc3c52dfd391cc3559df9335786aac8c2a1c390e026d6302d9d4080bd428168c4b792c636379972f14bebe7	Socio9@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	85209585904819271730726197518643723947	Santos Antonio	Landaverde	9	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
35	Socio 10	b227dd67ca9af254510326cb8e05ab547f965e7a172e2a482f8d34279a342fd9d9ed233d18d5089968ef1fdc1ba09c6efbd1b3deba976ac794824e28e9298233	Socio10@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	44721867538849612801883165184245433078	Nilton Antonio	Landaverde	10	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
36	Socio 11	cd2efaa80d0cba834c137a3bcd71af2436a24cd99b1571528985810147de1a8a7a47ec132acaaf77950df7bdcef98cdbe68f845e2534fc3e60e2dcfedf29dfa9	Socio11@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	104271928578732239537937224818279345449	Cristobal	Garcia Menjivar	11	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
37	Socio 12	f1a3474cf749aed47a3b8b4cc795c16e2f5b874f3583623131ef4919587be4a9214c86ff36688e73aef80e004d07c85fc1d86188d7fceddc4425e0041f941805	Socio12@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	170295682925676840819683672805032597068	Jose Angel	Montoya	12	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
42	Socio 17	a01b51621e99ea38c7102fc37ee7806008d440d8974924d42f2520b1d21572d460c22e0e2a892a2228953b603a30a0c95a7f11cfbbdfbcb7b76726b2cb0bd737	Socio17@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	197895742034487763616522590028951433817	Iglesia Catolica	La Mora	17	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
66	Socio 41	f3e7e201dbd27cc657e740e1775b67a7607d26f27f09c173b1e1bf12035e660546ba6f9887fa6ef5232f3ad5a0b69b5564201ae8a30ea1e7b9503299b938e529	Socio41@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	326425681228419600692551524639405281504	Nelly Patricia	Alas	41	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
69	Socio 44	24374c6309431e233724459043ff0f8e5a6f480d80248b4fc48f42abc3ba36ebf24e24b9804dd3e61df1a191e005412527e1f8efcc0e5cc509aa7f63622faa75	Socio44@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	104217757352528209675017035419191624740	Mario Antonio	Montoya L.	44	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
81	Socio 56	3894b2ca383739f5ee46ffe26fd604fb81cd715b60ef9edc5308f346ea218bbc83148d0c17ea8cb8a92d785a680d1d7d58718ed466618d42ee9fa6431dd9a754	Socio56@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	287385634836813380906938679883421866430	Jose Angel	Perez Perez	56	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
83	Socio 58	443c4170e09b53f8b7ac3cc775109725df3b94d1c8e19ea19cf69b9a2961122cb51245c099f5ca4937dee292d226142504bca492c3519592d78a323520402cb1	Socio58@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	206364612700202200482659947018587042719	Pedro	Hernandez	58	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
84	Socio 59	7e9b927ed918cc2c82dd2aeda70a20c9d01812cf264e7c3f4497ecd932ed9dece2b91035d1fc1e8337f2c87a4339f0e0bb63bdba0e680b92d6313aa4786b9f59	Socio59@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	76882618726583469253733891533650612309	Roberto	Velasquez	59	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
89	Socio 64	459108318ac7acff1debca2fa347e36ad813bbae4884b78b88160f89cbfe59982dd29701d762a07fa15edad6b62d1d0bc761d0e64e54c0c70d33dd455ce01414	Socio64@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	15580997308381404847970123856399657399	Julian Antonio	Murillo Calderon	64	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
90	Socio 65	00b33286cba4f12cce12cd12200cee57c466cae2b1687b4aa6e69cc596cd7ccd93db9cb067b1adef70d34e11ad7c5e51dee3f0b77650e0072bcc3770343a1542	Socio65@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	78515492382417137281906721275970299432	Silvia Judiht	Ramirez Alas	65	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
109	Socio 84	12e13f06e625a05bd7407af6b29e010ce2a358b7fedcb05077c9841042f19cdf22c80c300429cc0930bfad85bb5d361adff74ee006015168fd04b1cb7527163c	Socio84@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	6676829425084388130946355973975478742	Nelson Omar	Montoya	84	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
113	Socio 88	604daced97b7861d69a24660417e7fd86907b85736be1ccce5510d4322d9ee4f4d515313967cf342ab6a49e49531a81edb5e1f7253a72773caf92a17666a136e	Socio88@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	56645034468822411886446600095330600825	Jesus Balmore	Lopez	88	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
126	Socio 101	4db5c7afc3928d24ab37a2459c04948e5017d791fdce6fb5b88f3acb8b0fe46fb83df783ab0e0c7fec93c7858e721020d6dd93242000e827f4b58b2d552310df	Socio101@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	147135630018096229367689542143332368039	Maria Francisca	Giron	101	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
127	Socio 102	18f4025729fb4933c9456412f61c20ebbd5efa7864bdb96f3900030fe4ddcf7500f7e961c764873b6aa9778fa88778c8013a54112958f518070d632a50660455	Socio102@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	103306990091014255242945179025352437272	Salvador	Nuðez Ramos	102	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
129	Socio 104	f150651e260f666f429d1e213a9b47b625e0673d3c99e3906a00824be3d54155d36cb822e13893cf9b9b7a6d611eb99bfbf40fb5ea5dff6ac637197cf99122d7	Socio104@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	51250057966251884478804754808700804759	Lucia Del Carmen	Nuðez	104	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
133	Socio 108	4b68e75ebc91f78723001eabfccb881397b892d7dbb178c810c89164b7661aa8e5ea80438b6c2351c02713a41fe6bb7294592af9bfd768c1567ff94e2d8cc5cc	Socio108@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	126463199983731987878174867997022913174	Lilian	Montoya	108	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
134	Socio 109	e3673f3fb18bf1126249fe435080030fe1a6da87fa3ab2749cd73634cbf8a59c00ae26304c7debae67b9190d80c00add28c937e3ee2d21ce858bd69cb83347de	Socio109@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	89130202082741709771852898145773865896	Sonia	Palacios	109	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
135	Socio 110	b985930024fb7f72fcc6474d42b4d1cffa3200293c21ea2c86208f864b813da85eaa78934179779920bffed18ee0146bbd60bfdb083dc1abe713292d19dec15e	Socio110@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	22351534983339160169986542706191115935	Juana Antonio	Ansora	110	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
136	Socio 111	a570fcd6b9b280e142b6941d7aba12310c5d312ee4a9849dbea6e9d49da167fae33501fbf57d655f3f0ef96089fde8a8ad5351659818ab25949e7c0e32cc0767	Socio111@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	174671396457018608100707304918478986440	Concepcion Inocente	Herrera Casco	111	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
140	Socio 115	16ef43822282102a0ff4b4a34a8d123fecfef1d577ae59477ef670b01403787e7c3ec73c1c08be53423388a94bfb6eb525b45fa3d0ab3ec16a4e1c7afee60059	Socio115@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	132955026011054853136543979018538275716	Oscar Neptali	Landaverde	115	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
141	Socio 116	7f53890f77a839cebb5d0c29d7fb22e1f203b53c912b73df33e7248b562c5eb74c26da8184e1d632c85a34e4a52226f87bc4b753b893074665c8afd8572a5677	Socio116@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	198400497328209152775931854544173900535	Rosa Del Carmen	Rivera	116	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
149	Socio 124	57b91a98a8b5b491c82bdb7979dce342755f340e6b6ba18489acbc79223eddf37d9fa36c10f12a5ff7daa8e1429f8c99fdfd93d138fbe58cad1a5142f960ebb5	Socio124@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	20645722354719525118117658893564579764	Luis Mardoqueo	Alas Galdamez	124	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
150	Socio 125	f87337e05596ce6f5439e26ed9390d73dd76ac4ff23ce4b3a58cc1bd89898637056d39cdb5ff609fe1a44139b02d61653f13402847021957aefaf6d90149b241	Socio125@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	295576643124163662870465247963246585619	Maria Luiza	Alas Galdamez	125	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
152	Socio 127	04cbaa1604be01650e6f3fb4295427178ce780336cf6b30cf1af901f3ac69b8404779f305bd3c2464d7314734350170d0099ada8ea85ee72114e7f1d652dbaea	Socio127@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	149112829453977984584116385897206005800	Julio	Acosta	127	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
157	Socio 132	4a50d695de13ba52aab9771e72db7ed0917cc9f6af09efba7fe16553afe74653d2d9c4fbdc05e1d73c63f8c17887635512835e0fdb0575b227c2aa0fc8e1145d	Socio132@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	153075143070927865877685844095483408739	Jose Luis	Marroquin Montoya	132	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
158	Socio 133	89a50e8c26837bf970d45eb21fecf2284d27e1d5fe187eb8261ebfafaf684c3d7f32599ce771ffe4f59331a3aa5bc271ba071cb7f65ea3806d820514305cdf1a	Socio133@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	126385777483362663842998606300378070619	Centor Escolar	El Rosario	133	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
163	Socio 138	440de39839361bde549f66344957d3527c018d56c2bdab80c0a8a6c3bc38335ad438b8fe35bf1c565712934c00975e7be3fa102dafa96c022cae9e2760ab3cb8	Socio138@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	237775467055410492891382170039450115702	Dora Alicia	Franco	138	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
164	Socio 139	1a3f9c7faace48aaa190945e694b869ef156ef1fcd2a1e8910bc2d31352a9f724ec6cb057c593b10441ca7c757aa649282fd5d46111776e60bf108a03493673f	Socio139@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	176150159143748113577938788242698731610	Jose Rene	Ramirez	139	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
166	Socio 141	948bc02b7d9cfab3b511f04b83660e04d7cae5920b68ddb8fd9b7cc83e51c034292ed36793d9a0ce3141386267d7ed47609ef0fa2af713ead6066f3055da2a42	Socio141@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	152017320636238711455027875568796550801	Buena Ventura	Alas	141	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
167	Socio 142	556e24c83498c2a90dee7f796b45ff6b6d4485f434d1c1f34e717152d71525cef4b54a6c1c806c1a2647caef2e39c562a195034f2cd38271511706b637007c46	Socio142@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	323287091951608533654568116342490785352	Jose Mario	Montoya Landaverde	142	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
168	Socio 143	0fc21168418ee4335ed457263106f27b1a280e4b2b8922f59f95f4943c4a4c5f8537f5bea63c2ad9c8d592223a8f1c586a96700878c256394f748666af06ed00	Socio143@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	253591683939548353305314603121660837641	Mauricio	Lopez Cruz	143	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
212	Socio 187	ee73c1ac6c40d2f2efde25ed3cea1bbc7dddad9a9425cbfaf48086f02055b51248c22ed9ca39e93b73137764ca83fa2ce0f3bff55190ccf023d7e1d045250847	Socio187@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	80051670453273338222917656427646930865	Mario De Jesus	Ceron	187	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
213	Socio 188	a4d2da90e61f2283a02a58ef44764953edf6218dc625e0ba0074292d5feb7316ae7c5226af2618c3c5499879eab3c37dfa41346992f40c71661d8381c24647f7	Socio188@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	322912236878264415757879131729437551854	Felix	Landaverde	188	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
222	Socio 197	ff8fc433e5e8d5d47fb73e210dc0fd32f03cf3fc8ebbeeaa79342aafb6b5c6a38958884a297151c609c762e91c4f3b1673af1566ff45a30ed280d2f7810c443c	Socio197@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	297305717475884022773809363790563543008	Raquel	Guardado	197	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
225	Socio 200	66445dd8454146f5310f15642a3afab7cbab5c561763a1e7cef7f1d15331708147cacd80973bcbbd7d664b278215937f06924ce5dea08fb71bf3794ecedb660e	Socio200@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	222877615802537439289333210148795258429	Jacobo	Guardado	200	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
235	Socio 210	a3bf46ab7052986c21186fb272d2d8da791bdfe49d7a30f79424508b9cd69a55c695ea497eec38e6235417f7aaaf56343ce96c31624d8fed69c09a598477544a	Socio210@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	27905203768439118510274716852830522845	Luis Cleto	Escobar	210	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
241	Socio 216	98f8d3c7a5c99e957d689f8176b6d15086064c43b3925429a56d0e4d40cb5c46cd211a5798f8453f8b0fc099690ef759842e2158e0a5c42218060de9e20c0ee5	Socio216@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	305061671776838146697948692669600862453	Saul Antonio	Bonilla (Iglesia )	216	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
251	Socio 226	a4cdc2a20b154670195a4ff78cd735fb9903925c5dced07a44775a5731b955d15b1c881a11a6b40a826f1c2da4be22aa3c0c5c9fe922e20b1c785355e04a4f53	Socio226@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	131871494403873969643778301032664903646	Alodia Maria	Postosmen	226	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
254	Socio 229	db3c7f150512bc640a3d55e472d166435247a6fe90e774498c30b237962a7f9115d15a059c9e269d6ec22431fbd51286f4742de540827b418cd55590cd2a1fe0	Socio229@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	299471475490155064530777357095833264427	Reyes Maria	Vasquez  Vid. De Henrriquez	229	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
270	Socio 245	baf64fee4feb42c1b893b4a9b8e649353cb676fc42a310531bd4786e8685f0b747756367c1206396a1633570eb35a1bdbc5c85ed853a0b0bde76fb5778b13211	Socio245@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	96297141371722627961648609104553206821	Clinica Comunal	San Antonio Del Monte	245	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
277	Socio 252	da32ae976bde0d50fa54baa2b9568397ccb48411528ce083f1c32bf3d7d4795a1d9a803cfd1b6b675ab43de57c6088a9513cea9a5dde5002021c3fc9e7032534	Socio252@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	204429406578282954728064400634634258104	Enemias	Henrriquez	252	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
285	Socio 260	82faf62db3ff4a38bb66d18ef4f4fd72ccec6f7f1b72c49aaf60a80ff79571b0999742c2f60d1c8032ec76faace293e76af84fdede1db29dcc9f7877c5cb320d	Socio260@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	35867285021232059387486043501569271044	Jose Domingo	Lara Alas	260	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
294	Socio 269	3d8c530921d039ebcfd93349f52afd1873fb027ec1df2b8d3fe2d170d83fff578686a72f4d4d30e929b3a7a6aed8c2b511482fb7947ebac5fa4842b9106c12f2	Socio269@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	135468912264355143458338046404922334398	Silvia Arely	Lopez Aleman	269	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
296	Socio 271	a49d7d0ac71de455daad74596792b0e6b5dc3a79f4b145b53080fccd4d296a8f240f75b6f53208883ab9ade80bffa43b09736f69713d875f9c914804d50b4253	Socio271@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	255614435980948453845076416890422081738	Fredis Rolando	Murillo	271	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
297	Socio 272	dfa2cebc4300fb3c7c7e608556573022ccb0cbe0cd4a12aed1198de3042a03fa75cde7be9d1a8abbc6dca6d6086926884e38c2115edda4e29ad01cc9b8614807	Socio272@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	216343813657786925211900273245181641170	Jose Guillermo	Mejia	272	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
298	Socio 273	c3e3aaca598926f47bdd06f1617ed0267bca2f3142cbc7c1f29267878bf66290ade891c75e6632529a7b73308df85f6ff26564c2b3df68f739ab4b39db797065	Socio273@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	229387999387351109084889076150943632663	Rosa Bilma	Acea Marroquin	273	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
299	Socio 274	c41055ca6b883a7f541069f07b073a5f19d429c98e5fb54bec6705c565694cfbc8ad46dbc609d83579237e8c2e38018274a22a759627e6b283488f99b532b311	Socio274@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	210994735059234394857502629342682093502	Candelaria	Lopez Sabina	274	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
300	Socio 275	12da682a91505e6575655967b9bd6c196edaa1fbbcac20ca86ee3e2c28a752ca402995d830f1c2979e17d774e1d36ce960f5ec5658b294e9f407772b36a55d96	Socio275@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	290805733214135790074695601217617166231	Salvador Antonio	Herrera	275	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
301	Socio 276	ff5a1d32f119682cd834e3063075f43ffd715af3e2b49c35d6f9e83d63c13f71f2aff81658c447d6f3ff52076ff727a98097c01818693f6ba549c793ebc1de4b	Socio276@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	47059026374506060406826550947478323933	Jose Elmer	Murillo	276	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
302	Socio 277	9b092a068c1cb8c4a7e102b41927120f3c50b480c18b5686a7477e65f58a4bc17407c1ee5fb028dba31cbefae44438c7a745665eda4debabc87864f5e8432524	Socio277@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	276090662734339534619832849268084209926	Osmaro	Vasquez Francisco	277	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
303	Socio 278	047031b02fcdff6d0bb130791adacccaa8882e1bfaadf4198a24cb40868a88993351432a499a3fa6833405c6751e352cb7aef54fccf34fea103149a219d09c22	Socio278@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	65930961473307610542397610348636183243	Pedro Antonio	Vasquez	278	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
304	Socio 279	c4eb406f25389e3f7b7125ab57d61502289d950325a0cd0516f67cac4f50c118f308bffcb199b3aca19380cc4401cd548940665f5f6409362a84fa1a849231e4	Socio279@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	273745896177412769976690599234390961754	Alodia Maria	Potosm De Recinos	279	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
305	Socio 280	62e6c9ef44cf0bd95da3e733146f8a4043885815ed56c51e2f1284827c827cb17fa533175897608e20379f4bf6f146841a31e19d70dbcfd595d692b6b6cf31a2	Socio280@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	326216222395550407163009805661040890875	Maria Carmen	Argueta	280	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
306	Socio 281	412d9272663e5b52ae9c0d9823c506cda17b10dd4c21561dc5d073a32d3385a5d2aa2d003474f64ea1372b0ee63942961c35c51b6186391b242d5deede242c7e	Socio281@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	317971564046852399760617854895720119910	Linda Concha	Alvarado	281	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
307	Socio 282	055b661a57dd194e453baae10eb994852d04a442cd4dceb5eddf710d153ae7ad6da28fd528a3e5bb3372da4e61432ce2aa271bc11674bd9f8774923fae361f3f	Socio282@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	281107819213113146584378333643501047260	Santos Del Carmen	Alvarado	282	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
308	Socio 283	b3209ed732e34e5530be17c18423ef6b8d14065147774fb8fd02a96f89e42f1f6ec9a151a802a3f271d2056a11e37004c47eee1583640fe3e69e304ef0642944	Socio283@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	223713983097741058507288923228076286740	Rafael Saul	Romero	283	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
316	Socio 291	8587942b5d41b60549615528360b966629e9606458574c38388398378fbc54400a1051789ccfb751f143d56f689ddfc24c0cf6d58f31cde775ea56dd17fbaaaa	Socio291@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	107265419228548517376537824562114940109	Rafael	Ardon	291	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
319	Socio 294	63163b1d671e5096202e94421b26131492f8ba4f2f808960442994e2b059eac24916b09a98448fd9fb56cefc76f6a82c1ff2d562ab250661c57893fa22bab4ad	Socio294@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	78147594469701921405900182577323267683	Cleofas	Olivos	294	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
338	Socio 313	59e948bdf92210703b26528d0c334c3e8b20e563c6226392ff904ce639ec1cf4689561b858bcae41277cc3d5d47e73c8ce38dd710ee7c60c24f8d966e81f7731	Socio313@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	329182874349532344920585380750482127371	Alas Maria Blanca	Del Carmen	313	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
339	Socio 314	107e1583a16f6dd2ae22d75ae041bf55acdf369abb561ecc9fa929e4a9525ae9869a1ebf4db32d77387ee7fe3f62172dafd5b98c6f70952f7caed3f8e9e5d189	Socio314@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	333776760635860243271747000463812825901	Damacio Antonio	Alas	314	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
352	Socio 327	0faf57a74354ac15a752a6df47f89ca9adaa1fab83646cd9b818c8b821cfee57fdc979807fe89e51d879682aaab85babf8198cb2a0d798daea032eb4d3f674a7	Socio327@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	141814319956468295491209628011324055475	Dionnicio	De Jesus	327	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	2	20	\N	0
359	Socio 334	bc2ba27e00e88c89c8985a46bc7421df436b79ca70e16d36aefae0c2f1160d9a7956c1f4f30145ab9894a61648fb86ee77a3ee87eec74e2490b22ffd6f17fd67	Socio334@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	137012804666457433397988491660995397586	Felicita	Alvarado	334	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	2	23	\N	0
421	Socio 395	2d9dba49ae34b5247ada3d66a8e682f9534bed9aab334726d88fe0b4bbbab74da82e16bfe8b4c31eeca8c6aea807d55d94292f0bdadad36335fe814ce36d8db2	Socio395@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	259311159387964190526894373792308051210	Elia Roxana	Molina Mejia	395	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	23	\N	0
422	Socio 396	fd8f178dbaf18e5053921488987d9a6a7e3c8e45f89d70dfdbf0da199b37133d2d36864c457f2ef11f4f4a9bf31d32d802d9af18d087bc812a436e762f60cbb5	Socio396@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	291263243030384975292886708043988275529	Irma De Jesus	Portillo De Murillo	396	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	23	\N	0
423	Socio 397	c0633e222a79ab4e981eb35bd02f5a8f7e028de426772942f5a50ae5ae99922edd90e107f18bfaddb4d04dfa9af630e91fe58a2ea9f1c2ded76276caacd412ed	Socio397@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	185065725494211831996015286301233598108	Balmore	Menjivar	397	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
425	Socio 399	138918498ee63cbbac46488bd5a4f27569063709ad116070d79461bfe657681028b1ced95b2177d05de13094885cdc3d7946fe88ea3579c635d424794aa293e3	Socio399@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	60226565491495047505286595223975847606	Jose Mario	Recinos	399	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
429	Socio 403	e2b7d7129348d02293339544e1192d8dae0b01a41399871906e017f9996e9ead6669ce2b17895e51aeb06588f2d95bbad0e5ff1808fa505bc080f76f2a31dd19	Socio403@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	231076241076017683432336165067037829044	Victor Manuel	Castro	403	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
431	Socio 405	25296b953ac9bda2516fc0d82154a28ef18162ebe071a963347a67e0a3e4aee260bafb0c0fab156d5290c229b6ece239280586ad9a260fbf229fb6be543929bc	Socio405@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	339386458883917923439032314145664942456	Pedro Juan	Hernandez Ascencio	405	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
432	Socio 406	fd506be496d26e6fa8638fff81bb298ac4ce550a2f2e948b60b3bf63b93b5ee3bbec66b73ced18372d3a652c24baf4c10615009524c3e8aa662bcd718b954cf1	Socio406@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	194267808820384104688480787717485865548	Alberto Francisco	Franco	406	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
436	Socio 410	ff8bbae257916d03b7daa9c3f162538b81fa59ba7f2ba1c1eb045697d19d3d441abd5086de78a947c2d71092d65555d1e62d0aee5cf75d83550d335351813eb4	Socio410@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	178802929231739726155176846304609031827	Nicolasa	Leiva Recinos	410	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
437	Socio 411	a259a282c3aca603425cfe65a4e23794c2c8f57913e57dc9517fb1e51baffb1e7e6236619bf322ac03245eb4bf925f3583aca3f3926ec7a41e92f5ee25c6e8b4	Socio411@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	274641024578404383246498916859540621599	Jorge Alberto	Sanchez	411	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
443	Socio 417	0891763d76cdcc24007f1eda6d1519de1a09aabef0e46573ca512eaf3d0ddcece64f698ec80653522f76b299b55b7e15c99809306eb9b696c717e35f86391fce	Socio417@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	51605134181634020648032369823453704846	Santos Fidel	Barrera	417	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
446	Socio 420	72303c9854f419b181a09573ef4b56bc80138a6804c508820c7c447c91d09ca5bdf463deaed7229ed55b1d498ab1dba14bd56cab398e2bf526418aef3caf1c49	Socio420@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	287517400660671152571647421172187808879	Tobias De Jesus	Rivera	420	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
449	Socio 423	b0a755a86d46b18dfc518e66fa72c3096c6403afb61ef37b982e7adc17b8df5062cc9d48a521c4ca403f5f67f06dfa4d37ef304989daf3b8f06d5ab4153a20b4	Socio423@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	140840836811643207395019022046251036715	Jose Domitilio	Lara Alas	423	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
450	Socio 424	55a0afc478af8c119d48a079ed9e82d6d8ad9c0594091c7c35f7c3eee6262a3742842ed4dc91fd6bf333a503c123d6b60b2495bdd22e1ebe151d49819d8ee0c1	Socio424@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	73100069970985868234174476064073066016	Nelson	Avalos	424	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
455	Socio 429	667c8a5a769001d2a23cf0cd9f9bb55e65d58f564d3839dfd616d134bd6e8d3309907a22ff1e9f054fc67cc871d36b20c6e45e38c5bec6f1770efe6c2d60fd07	Socio429@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	121927462211894366876476535619904758082	Rutilio	Valeriano Duran	429	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
462	Socio 436	ac5542e1c2c88b75c19e329b06f3d58148762ed270093f0b5cd5f521b71a0f83008e34164695407c030dffd9e602787eff757632e18b19ec72c6870a58e46ff4	Socio436@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	194269923543175810206141988612114956706	Maria Amanda	Lopez	436	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
464	Socio 438	20d67dfa2fbc3eb189cf114accdbe154f6b31311c4af504fca0afea1a5bea40d4f36445304a4e74f7f5da318b737a0053b1feb683aaeac8d53e5cb67d2195246	Socio438@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	27889766955473241722745674751415232302	Jose Ariel	Castro Portillo	438	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
465	Socio 439	be0b97ab8257eca295ad5924646bb122218ec6694d22959df18358b3e101dd499aad59fd0d7778b1fa1b3aaf814e6d4b05e12e07ac959a00f4b9bc15ba616a39	Socio439@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	288340421539012034758045287539865550150	Alberto Francisco	Franco	439	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
467	Socio 441	b722ecc6df9fa9253ae614aa2cca41ac679e230856a060d22bcd608ae5241d1c713dc1bf7f18760bf9435d48c746c49d115952b16e0d0e51416a305765f5e75f	Socio441@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	189216763675864975564591605033880899146	Orlando	Barrera	441	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
470	Socio 444	9ac910baea06e17620377ff4b7a109b5527dbb93974830c04d49996a27039f6e2f5618e6aeff5c19db60c726a6a6050d5575d273904477a8381e12366036c6e6	Socio444@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	225822854849375067564081606991133643769	Ajelandro	Membreðo Veliz	444	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
483	Socio 457	0380d19d81a0de68747265c2f0d3c4ca8c20a9a6700b4c27e939b6a028610957557a0c703d2f9458e062490fb42332664e3d58e98533df1035c1d6c0f791b0b9	Socio457@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	277486319417406309532359023277781681812	Santos Fidel	Barrera	457	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
489	Socio 462	24f51a1c456e69e50602dc71213b43ef7fd895ac852da76d052c1ea10ac1f731bc3716cd0107499d9e8bd55a209967da117e5dcc49c1ee5137689bc266402e6a	Socio462@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	256927937612836040308870005214630258336	Manuel	Guzman	462	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
490	Socio 463	fb72aa353ac890ddb75a5f25a204f7dd4e6237ea1b421c02eabb8aa493bd63dfa62ffc2ffb8eb6aca359711c393b5a03008cd15655b6c91923c1d70f667eac9d	Socio463@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	186814515713984455419025411283332935099	Nicolas	Casco Lovo	463	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
491	Socio 464	feb6cf024106f7d04f9bf0c67be4383d9ed0a7e681ef05d343845c342801d05beae87a2f363513d88ae81785ed9339eddeae6f23861f862b9bc60fe2e2455877	Socio464@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	316629484595022526665637078149785880503	David	Garay	464	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
494	Socio 466	4325303136bb51daa722d832db566c69080541092f5312c3b14c76c88ff9f7e7de6329b15b48ec9550902da32a8d43371b86bb77d27232d831fb6b513a9d1240	Socio466@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	160275364785665693178664735333174240604	Lupe	Barrera	466	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
496	Socio 468	15aec6368d78213dac2943ed3d4c829493b798ba19df8a99562fe1b3e3655e055c4d9d9888f7978750eb50db16a8c4b08fccd6c0e6ced859ff7f371f355b2686	Socio468@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	45184009134769656439353624237041719668	Mauricio	Herrera	468	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
500	Socio 471	53af9a00705dcde49f5e56d25782220fabc7bc906d9c4b8424e11aa598f248941781b3c28aa2cd38a18cd9a7ffd935347dc41a81c9320f7b0162e25c92d78784	Socio471@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	263345218312484986475140670117580593209	Filiberto	Mejia	471	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
505	Socio 476	076e4cbad3e5a84ff597eeed5ac35c08e3ce5548079a2243a0d2bc30cbb23f3111b68a60bdad6fb671b979606dabf2826d0422c0bde2a2c86e7b302aada5ab75	Socio476@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	268101862268443613401967993506534872409	Jose Felix	Vasquez Ulloa	476	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
510	Socio 481	7308828cc85b131431eb601b23e22f25d635cbac0039d0266f44b4db5bf66f3314f20f9b754824c744307efcb2d2fe5357ddd5f5a7fe3e2b793e6b1af58376fa	Socio481@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	170763802155585065347931054826614638189	Juan Javier	Marroquin Herrera	481	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
511	Socio 482	53ba5746c3ebadd28f5de97f6631ad5a1bc4f5e01f71693eb78d2c9df647631ee7c0d35da526993fbc6ae70027feed805250a445871fc63c033fb81cb7de7f26	Socio482@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	37471274299414510993914382024123153976	Maria Consuelo	Herrera	482	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
512	Socio 483	61f8be1b958041449f45c0bcd2e656fb55631b6816cf7a32dfc339f57fc6c3fdbf4743ac7c3554daead27bd6762986600ec056c248c165162d8971a9f1d83c2f	Socio483@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	231893825704582298171916502028179513223	Antonio	Santana	483	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
525	Socio 496	e11eb9c0eb2cd1bda620ae45835c96783569597c31a04955e1a2f4f4b29f70c716c70d41fcfe057f282e22177bdfa7e9a467c8a059c7aa3df60511db492aacb8	Socio496@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	126493477257958999248304945334168040212	Ana Daysi	Barrera	496	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
526	Socio 497	821a6ac84440d869aee9eb23aa978f8ec8a3847dc335e5329844907fccd2d42695951630ea805de3898c33c34fc199d181101ed5111fd6cfd1eea65e1493c658	Socio497@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	309141605085876537383465117974403259079	Luis	Barrera	497	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
529	Socio 500	074464ec9a9dbf504cdf64a8d4489f82a7395d26e7e1215ca31d4c930543549e12e4727232b3a25a82dba14e770f49a192c82ce6ef23d77c457891ff65d430d4	Socio500@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	40817027805496120627808613133635881631	Elizabeth	Andrades	500	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
536	Socio 506	df4b5a0fae648b2896234227216a5296bc96d82acc88730558e3f2c95f177ec5a28b68dfe70a2d11dc6a0a07915b0158bcad335984af8a809524adda21c85a10	Socio506@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	306732223331241069008045640575770480049	Salvador Antonio	Grijalva	506	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
540	Socio 510	cffbb2e8e74f6f7ecc211c5b170bfee9ee8c617467e1e790082dc7f090b9fd0746bb6815d03e8c67bdd20297c4f15246107ae35a14b2de282d11012f506ce3c4	Socio510@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	161687591352429492138541242281521300642	Mariana	Landaverde	510	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
542	Socio 512	e45a5bf14f0faae86ea0bab618db75eb5f95a1d743cbf6418982b97d8d2fc895a3be9104d766bc6aabb35e07a6eb373ca258ca658f6d58bf98ec5ee2ea3a5883	Socio512@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	129295386722638329023717959709112804090	Oficina	Acrasame_ Zp.	512	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
543	Socio 513	21d97460bd408abe3f42ae3f732c9349b8e5122cc36ec778384c454c5d97a61e364ddf556f64decf253061b085c57473a095686956d18d6a85a408f95eb8b6e4	Socio513@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	229541896033452326597220367070865990540	Irma Magdalena	Lopez	513	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
547	Socio 517	bf1b0e32a72d037898164cee00cdeacede2c9348836348f6eb3e29612d4efffb3bae91b55b85705b0d4f60de971dcac3b44c81f2c3f5769318258f13b3261d0c	Socio517@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	21991455815501936171789887062023770723	Jorge Ernesto	Rivera Avalos	517	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	14	\N	0
548	Socio 518	7093e5d5346845b52d62d607c6e2e76a0c804df48ec1d4fe69c2c0975dcb9d434e58f9c79bb4bcba83ea7ccc29dd1141d19873918ea84e4f27e90a76794f728b	Socio518@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	190907802273021276220214149125427030174	Roberto	Rivera	518	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
549	Socio 519	e9ac18309dc22776440458c76c50c0c4d8fc2a621ac79d421a4e8a0c83a4ed053d8d70baa1707f48d9f497c254438dcfa3092b2a7cb0a7d5dae8830a26e0d330	Socio519@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	45131793529296090089939293861635027375	Jose	Rivera	519	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
550	Socio 520	e9924f54bd4ffd9adfa9b75c4f098c219f4f1729469a0715d0533bbe719f36cc1b3b4aea7fb2cb2476f636fbb9e03ed6bf5df06dee0a4e48aedeb8fb8406fbe7	Socio520@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	242522354837320667827338706573039899932	Hugo Ernesto	Gonzalez	520	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
555	Socio 525	78e92369e036a2a944d307a9092500a4c5cf13c6ecade386f918a550453733bb59b999625b4ad8bda85d0995cd20581a4b28608b7c451ded902940a8104cb86b	Socio525@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	2617021274741199177603427556365198798	Dionicio Valentin	Alas Cornejo	525	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
556	Socio 526	7c98a4115e7551052fd53896ffa786e33a1700fb04b6b382d0da4a7e6a885869ed2a4c1d9ac31c9783e4455bd746f9bcbf583ea4520f578fc7202ccc6f38efbb	Socio526@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	33458831303631964337952611631546424117	Hernandez De Jesus	Landaverde	526	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
559	Socio 529	86a4fdfadb4d0b69b26b7d65ad653049f3bf7980f11247bfd85bbe95d98022a8a204d37f4d32867ac81ea440786e8bc88ead6eebef80bcaf6e672f319edfc53a	Socio529@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	321248429664070343057531124904624758361	Manuel	Lopez Najarro	529	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
561	Socio 531	d66fa241490399d47c77db28f56a03449ee16747bac074b446e5b6d585f1c2299beecd625dd4ffd80139d99c2ae3f5adbf0586dac61389dcbecf0edda128d88c	Socio531@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	122633317413681922238477494186708326079	Joaquin Alberto	Cerrano	531	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
564	Socio 534	6271e34e945bfaa15042b1a68fa9e2d1d2d35620b7667ace11d064eb9977fffa407ea37eda8bd253a9eab1c1d586797b0d6ad07e71c71b47f3cb201b8ddfef34	Socio534@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	255988689723595585712648043524616832077	Maria Delmy	Lopez Alas	534	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
573	Socio 543	9f2fffc7e6d07eb83dcef84b5cf99cbe0a8faa55c47abaa68f3d70fde6ec057884cddd8c928dc8e360347d7428169eac29328ac5790674b17c94baf8d7062bfb	Socio543@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	194131678457421224450934544312828387813	Valle Verde	Casa Comunal Adesco.	543	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
582	Socio 552	696f40a552789f54744438a889cd68524ab37c01cb9217a21d763c7836250d0438d4e85aa91c2101e76f0d34813e36937cb85f074f2f183a32286dff78c5db96	Socio552@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	320830724783105891944185683444439485240	Celestino	Rivera	552	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
584	Socio 554	5ecfb80f667e2f9905ad3b8341cc50bef94813a5960d281ba9b870242ee2c561e2ee24e602e68917b6aea0215e119384513074b8214083c1193f3898023affc3	Socio554@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	147909243912138968482784457103525954421	Jose Antonio	Gonzalez Lara	554	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
585	Socio 555	48fc05bf73c38cccbe35c268168bea5b0600b3a610623d6a89dbbccc2add0822bb500e2bbbd20b50f0d3f779df1366ff01e5232c06846b0bd96bc05526a424eb	Socio555@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	172201590357955611270624468440355083292	Ernesto	Alfaro	555	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
586	Socio 556	7f9fdb6b16c2159234d1f7743a4affeee906aaa54a81a3c667f4c64b3783b04b25b62b5147bc7cb74c363603e9b0901c27434c96c79ffc293bd02ecad1701457	Socio556@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	238013152089032678398920625663438745113	Maria Hilda	Menjivar	556	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
589	Socio 559	c0c6135ba8bdbf010191127b743a7434fdf759fe0decd6229373b709d5ccae444a01ab014cb1e07887c44b870afd7e8ea9f92e91383d5f689d3ffdde51dc129f	Socio559@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	179639538802596006797375564766696810374	Cecelio	Diaz Martinez	559	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
590	Socio 560	c98b3708932c070d98de2d04c240e8cddf4c0547b438ce720735f97d432871e741a6e660894be3e916ed2cd932e09017f76953dff83dde35630750b9aa5a549d	Socio560@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	255852830763062231682599386659389216010	Isrrael	Garcia	560	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
600	Socio 570	f02206ec263960833ec6d1d99b91136a751aef46f36c96c74e1c6db2ed7645d1d8bfcbf96334e09ba1464c0f6aa048b28eb456022d6145c99e5ea4cb1ca2488b	Socio570@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	165553611215010056795194454518041386146	Ammilcar	Alas Armando	570	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
620	Socio 590	f17296b57903e487be12812a599d8c1921f3f4134bce4e78b21c9acf52bd729e3e3398ab8bb8e7db768010602c695b6d7789e237bcac722f5995ad200889d1cd	Socio590@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	7900994176072053306656583829126433703	Lucia De Jesus	Ortiz	590	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
622	Socio 592	a78e886fe60f683543186ec6ece50ccb4a6d393daf9a7ff2cbee53e017f4e1b8448a7531163ffa7b991267f21b00215d05712bd985951c37c156aa8ae7d72f22	Socio592@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	259784960128945519329245226201642379069	Cecilo	Diaz Martinez	592	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
623	Socio 593	2a7a2145df129b9aec4fdd0656c0c644f34520727675d01ae6cdfbee54644116a39f6097cddd96ce1d9ade55044df0e113769d7715af1178d62d34c5c5b545ff	Socio593@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	133422889930849841618218392817479825285	Ronal	Guerra Martinez	593	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
636	Socio 606	f7b3f2c27bd8dfa3100589de0ca24f03def273b2086a0ec7eddd78300527d555b8bab58c36e7314711f650315e7456ae8fad23c37d5d1d217b638d22792ff3b7	Socio606@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	238436980490329547451342808672021534561	Albaro Joaquin	Cerrano (Hijo)	606	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
642	Socio 612	70f6a1f050a918ad2fba5b0c3d1fdd10d02242ebd76c894a028a6ef58676003c22ff543cd4bed9cebd9f37989d148a09462d8b325a58f19c7ced8dff1a6c64d9	Socio612@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	237696666315691240206843402512623873640	Ramon	Gonzalez	612	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
643	Socio 613	a3ecf291b7e033ce9524004a4055e08e17f80145415c2fe345c18684114f941dbcf9a3072833dee0dc34206e344a57f3aa3973a622a9725ad6f38e60414de916	Socio613@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	221132422376783599692121475915763898389	Luis	Lara	613	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
644	Socio 614	f42626c2a2c5894cdcd1de21dcd269e5b59bf0e145c0d8f88b8bcc638e1ce34ede2b866b52075f1c20317c98ce773a8c29e2e951e621291b20ec381717cee3da	Socio614@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	232639357266413577805867755838201188453	Agustin	Lara	614	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
646	Socio 616	d7f2985ab2a206f75a592925e271e2bbe5bd128bf6e781ee1649a1aa7a463fa5fe28c9a5247c41a437b2e15de6e6c1867f837aaf67536313da48a643601ae811	Socio616@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	302718369817990499363336303927617928657	Consuelo	Lara	616	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	2	4	\N	0
25	Socio 0	31a3dd9ace3e878194f95b4001ee55e936b5ab39153a35b51ee353dea762b7e29ad0baf01adcd234bdbe5b76e4eaa6fff6cf9eb9ca1c65e4338bb1351fcc9063	Socio0@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	197335305860025593370509864161199545082	Juan Isidro	Pineda	0	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144884
26	Socio 1	59e1f945e58fe3aa77fbc4e9ca4eadfe6a536c54f6a66054f2a7784c023c467aa386c0aac4e23d80711e245d780b9e4b1ea1bd003663ced5ff888a352b1aa66e	Socio1@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	63246047646065929556394307132792752517	Jesus	Landaverde	1	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826627
27	Socio 2	410edf9a0e9de2478c95b1d840fa51987d2972aaa8219898cd67b5277f2a69a913345efca477a0a72835b30aad94402394b65383395d8a3d85201a5b5a6f148f	Socio2@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	231444296028074025575079896006591531032	Roegelio	Henrriquez Palama	2	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823829
30	Socio 5	e1736758d5989086a33819df461e17427da01949e7afdb2484d50037179f518d30e5a964076e73eedd6b0e1c125a813c16af49416948ef2e7157214b397f945d	Socio5@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	45910506804694991049299696723648254469	Efrain Hernan	Galdamez Alas	5	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823545
712	Socio 682	db0948ea268d7a2a44918efef2d420311809535669a6a6975fd368183c438e7c09816c91e832dc407912367988daeb09d999da0594904ad18446d620d748966c	Socio682@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	255126097456878687412000059251305417573	Jaime Noe	Garcia	682	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	052831
713	Socio 683	d9cfd9c1f415bdb232fb75df045737db9b74468156b61ace35fed94babe4b1acc87654b7a179667388034acc36c7da2f87696e273ce209487f43a2a68f8fceff	Socio683@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	325104022142290512634726686055855158270	Jose Ovidio	Campos	683	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	052834
714	Socio 684	35c93c5a72fca4f86011bce96a88fd1926e1bc70375f42b57f6ec61341bcd9277f8a1d8ce82618d96e9db3d1f6f07a4930dffad562654bf117a523b13d1a2732	Socio684@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	47993496674117145885656324523036021932	Maria	Candida De Guardado	684	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826125
43	Socio 18	d3b8a9f02972dfa3d88177372fea8c3c4072e55c935ff5df28556060717e07d2439e227b6237ac5c23d3ed9aafc132a2736a3eb77f1d0250d9d4b498ccd0397e	Socio18@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	90418986023930819502772679424530933007	Centro Escolar	Caserio La Mora	18	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826691
44	Socio 19	e5d1fe09f32604b3c4b72dba40ca0cd13d458451d4c71f62bf08bc0309356e81f4ffd7a13f14ae907182efa08bdfe73179af75b25ceffff944c2710e95816014	Socio19@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	86869335345832774574851250926452551297	Jose Elmer	Montoya	19	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	12-075984
45	Socio 20	dacb5716ea9e0f2471bbea577bf195ef807debe63cb20e2223e3165e9a9a98ea49e10cc010d65bb8b04f2a7ce4316f6571c93bd2be22ef21efdab6a4a008e6aa	Socio20@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	221771488970524271556238967972139642636	Carlos Antonio	Montoya Murillo	20	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	12075976
46	Socio 21	b48251572b058d5cf30631d73666c356a61cc7768738231f13911966718e616b81e031fda09e46f8a970bc9d7cb4c687dbe62983b6d2ef1bdbc7965e649c1dc9	Socio21@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	69555303483628663374361740828568655179	Cristina	Gongora	21	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824694
47	Socio 22	35672b28df4bc24af819f3d14f8af0ce167fc53bedb2155089b140447cd27dc7a39fb3fe2214991a83fb5d09e990f8de88d01701f51b2ce1d2682b34dc6e4922	Socio22@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	200225326698906390722132833936460569788	Ana Noemi	Gongora Guzman	22	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825265
48	Socio 23	d7881b23ea23c7aea2a16e90835a1daba1a35beb340a757837aeca889e6b8b19b8bcc37a943161a504c5ae097478aac1924991aa4850a1fc08a2bb1e55503a7d	Socio23@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	27786461164690342226220987637454083887	Jose Osmaro	Vanegas Serrano	23	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	1444875
49	Socio 24	a7794a37efabb6890b0d7ea52b9778c95abd64983ef40d338e31d99155ac0183dac86995f0a8389e955ceb922f6f976ebf5c73d9871f89a9821e408806da11c2	Socio24@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	154275537416288672965940235155836702549	Jose Claudio	Campos Sanchez	24	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16358
50	Socio 25	2615c19fe290b5075276ba579efe6044a3e42f01b92ef296fdd7f0aad2f1197aa02db1cb0f00440029c797fee1dd3ca9c63d6b5119469bdcd914cd902caa3f8e	Socio25@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	134017276481064100707645313769710166683	Ana Bertila	Martinez De Lopez	25	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144872
51	Socio 26	60158bf00b3a28838360a34e470707084c75f127f71bf29b129d4fe6e8ddef65b4a9b8cfedbb69acff3d037c503664562ef370ef88cee67530ba778e78eb695a	Socio26@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	103512393753976789909439333259304702081	Ana Maria	Menjivar	26	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144882
52	Socio 27	168e0147be513cc886d855de1dc2f82d798322fcd6b396a33ff89024de07490b3ced9a2a4591136a58e10e181c2a237d8391c63287d7a86c0ceeaf69be481878	Socio27@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	89367535194687258934853977605799098489	Berllini Del Carmen	Vanegas	27	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823348
53	Socio 28	c61852b2192ffacf04dfcc337dbe1a13a91a7bc8124859084cf413e225cdc86a3a790d561c7cd3060fec6b9d6ffb8009d3147e31b0afc5a15bff3a990f8b637a	Socio28@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	158844638343813970599686629156908900703	Jose Osmaro	Beltran	28	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144917
54	Socio 29	a31adf4743431f896ae84d8b8b48d72b261551c5319d542caf33f9e87b3937e9d679621ce9dfdd52a56f7bcf70119390de58e0360db82dec58d71b97347ebf61	Socio29@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	325077188468426162964351843044997548048	Daniel Antonio	Lopez Lopez	29	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	052841
55	Socio 30	3bf851d5a73f01ac78a4daf761013fddd064bf67aa25732a62ce4472d1f8cd9df4d593993cf1a7510d2bedb090b3fca6d0abc6fab8e5ec1da5f5fd083278124f	Socio30@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	315982598645759887127366607585056393705	Carlos	Landaverde Rivera	30	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826749
56	Socio 31	437a0894a6270f39195e10e52a56c375b9b3085b36cb9273658f1460ad48dfb74012af5e3c778d24a01486541e1eaed650e6a320650e6a4c92c66bd6b2ad72bf	Socio31@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	261295795352154971323436521598989664728	Eleuterio Candelario	Landaverde	31	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824634
57	Socio 32	6b3b205c3f715e83cadaefa1910b29e90308328142aa8e187171e827b5cc4d9a5a1cbe3fde4866631a75f9c7513d0f562dcb3ce089d59ece2d183306600cdf4a	Socio32@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	153687299648609698637853803332387519957	Jose Milton	Landaverde Rivera	32	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144926
58	Socio 33	94dbe01e1c135409097dd26785c96d698d633f90ea9fca2274f382911c1b8d39f0c6eb6514659ec0e291a626d942b94d0cad783741abe04d473eab9f924f239e	Socio33@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	277523726756307149798564582331706835764	Cristina	Menjivar	33	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2424740
59	Socio 34	55589dd43677c084d59fc0f1d9ffaab69ba7c0efa06795129c9a7180f9ad0f5feb232e3986dc6fd82b6542f0aa4bc4cde0ad654d8dc0b5bc7c13da5b977f0e6f	Socio34@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	288390566339304816725537533597018711820	Ana Maria	Menjivar	34	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824418
60	Socio 35	1413307ee708d0d0d9661b80d4758a3e53031f0b5f580c0618705d02b27262cd8f4c062333dc9a6eb60903661ecdc6a6c1face564618f79357b301ed6948f0f7	Socio35@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	11728019810362229481181816422179251387	Rosa Dalila	Menjivar Zamora	35	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16360
61	Socio 36	33ba21ea0b2e593fbb394126c98390bc2ab46ec24be012bd404d43193c8d675bc3c00a65ab2c43160ffb47d385f02928e5326c3f86b76842c225c248e021a6b5	Socio36@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	58242493061014408869289243349189233569	Casa Comunal	La Mora	36	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144922
64	Socio 39	6ecae61312921ea8d5689b0777ad029f0a93dab585c8dd6ce8199122bfd7999f79ec25df84148826980c1563d692df624c72fe9aa1947b19f5c7276c6f3da12b	Socio39@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	42341633214276572863050641361559439774	Alberto	Alas Dolores	39	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826666
65	Socio 40	963d72c0f4f6a4a768b9f4e2b21f7675ca22af9c55b8ac1a73daf9c340ce7414a44a39d83ebe97494ebbf8ff85c39e69cc5889221420103cc1f19a94e49b1679	Socio40@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	306338230263863820378793076269076717316	Jesus Eduardo	Coto	40	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	052838
67	Socio 42	13eb388207de54f19d96934a42fabb0252d578e410c7875a5759384b083a2b9838979cecffe375944718b9a5811d6470ae9fe933c0fcc16c232aa6fbd049004a	Socio42@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	54693117393924670659932478930728618496	Margarita Blanca	Montoya	42	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825895
68	Socio 43	01f359afbdbf51270069b65cd7ef29c5d5a761dc7917e423e3163ac30e6d565118fd196b6b9eed87b8be29f4cec24d47c8810c4c5e56a483d2f8bd3b1f238f96	Socio43@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	166505847887168246656005505343900422002	Clinica Comunal	La Mora Crc.	43	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	52826
70	Socio 45	83ca4ee43024a2845b441700d63fadc9d0569b5ad82f918dafde4fa4c5e4dd234af40400bf20696b39a4f4fdf4f3c19575add410df5a46cff9e869b7633b6014	Socio45@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	128117134216899639157021323289850171023	Jose Alberto	Marroquin Herrera	45	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824376
71	Socio 46	f1d679fee5a02d19a46cdfb3c5da4a14f17d055bcfb2a5c8bc83ff6fb1aa904553d79d9ac84ba0ba2295e78962e29ff707ac261a92d0c4ef85ebf9141e658eb7	Socio46@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	209788815319954557446145372302123330146	Ricardo	Landaverde	46	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824181
72	Socio 47	6895baf91a292fd8180ea0e079e1718027cfac247550c64d7cfc83f073e12e6bad6a2ff3ac18e7f8b92a0c759470cc105a256b9142e2d8866aa1f0b1ee2fb657	Socio47@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	192583362697680372201932938211166308725	Landaverde Rivera	Marvin Antonio	47	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	21934
73	Socio 48	f2fbbbb0295c1da4da54c1c6d029c85b71bed7618ad5eef06503f6336ff25d4413e596d1ade25199dab3151e7fa0b1f56c1292a3d7e9430a8b6f94b466fc7ac0	Socio48@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	157265985150446937129576469100994817459	Orlando Bladimir	Gongora Guzman	48	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824442
74	Socio 49	c14572c81be5068ae05b398f172e397e5978a5ba595701bde5c301b56d439d0e9e8c9dc86d1e1658eda5d21dbf5d3d48553bf1ee565c0bfae0d38444666191d7	Socio49@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	221026398753978253293105999448123097960	Juan Carlos	Paiz Giron	49	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823746
75	Socio 50	e7739498dba0c0c1c5fd2fc7c1b9ff218efbf05928780f2d3482703c27c72f4a8ee2b25a93ee3bfe967930c9726d3c01e4c6a8a9cfdb6be9d2d1440a88f2ce8f	Socio50@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	170266878505903163858406945817917503443	Bernardo Salvador	Hernandez	50	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825387
76	Socio 51	ec8bf5e04ad23a31c46149bc6659b8a91f5410f55a0e60fbc0a070a8447f83fb9e71a467896f76614f3edd06c2a0b0a872fef97626e27a3a43d2356c53a0834b	Socio51@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	8280287617846210601889686319083785638	Sara Elena	Pineda Hernandez	51	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824051
77	Socio 52	faa3c2df75f7688266df7c333c11c54b1763895fa541f1d7e79f1fa0e1c23d4ce6e47a28b1c5147ddbad02f6859c40dc2a95bebbac9514c097cb605376947532	Socio52@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	57688541242258821949948010440892368436	Rina Guadalupe	Marroquin Herrera	52	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	21944
86	Socio 61	f1fe198e70d266a12fc77dbcb4f2a7abdbd6fc6b813825ee0a5d2e0effefe73ccb9f8c2ce08b23aab6f4a3deab9a69710636dbc4fe6368b9849038db6d3b8267	Socio61@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	317086906926139900079197465990399251720	Felix Angela	Pineda Hernandez	61	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825384
87	Socio 62	06862b766961947e9fe6f457a5cfbe312a8005bfc42c002d2b7d979b63ce597fd8bf118ca63431b98f4f2f6f36062760c622cff3210be6c7148c1983dd0235d2	Socio62@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	4042684547024365671698821487824128239	Rosa Lina	Marroquin Herrera	62	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144883
88	Socio 63	38ed785eaec42447dcdf13a7c166c5dc0a0deb03a28ce329290bc953249a0c1f28f081ce1504ad32a3a74808ae81a394787271ccc49097f090cb89f31aa06d38	Socio63@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	162091914830390243268398380846524711221	Julia Raquel	Marroquin Herrera	63	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826045
91	Socio 66	d8dd2fabc32993e51839aad68bebe3e220d07c97937bf25669e1472d71bef83d9fd912080d5ef5743cf07a54d60d23d3b2fa63a955fe87a5de9471ee68f4fb7a	Socio66@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	207951297311447066156933528604784730610	Yolanda Noemi	Alas Funes	66	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	159450
92	Socio 67	c090e3dd6009bfacb94c0049f60de1d4161e767c649f1a6fa4bb7d2d963c7e7b6f847bdf848a796d819b6c671945bb5d9e098ab130e3104f719a65a5d9e552a6	Socio67@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	308928123658775029721031300960767883170	Francisco Antonio	Landaverde Garcia	67	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823673
93	Socio 68	5a4f72fcf4a3373aebc98238536c2635f06b16bc1759a57d1b40d0eff894f862f06b481cee964ab5cea87287f621a03c91861a1b1d11a4f7ed8fa552e85a7804	Socio68@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	111700527357865229084755458433682337301	Marta	Hernandez Sabina	68	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825455
95	Socio 70	5076b7a35335dc7b6dbfe085b1edd74e8b18d0441e012c629190229216134fce55c8328a66b64c4237ff04d852ab269852147b781abbb96c875d8b8ccc4fa8f0	Socio70@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	60984150495799725367581886923571476717	Andres Antonio	Romero Santamaria	70	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825857
96	Socio 71	3e14cfd905dfc9d453f130f2d4c4bbd50cfc817eef9ab206a3d90a60cdb5bea84bb80502f2f35bcfb8fb563e84bff11e920bf4ad832301bc571db08a99d84c45	Socio71@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	11559129906978291212852947905673814668	Gerardo	Murillo Calderon	71	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825054
97	Socio 72	50a1b63c88e16c1016d757ab88bff7ef9ba5378660fc9badb05c05012246b4c9028051baa43b1f99e9f7913fb39f5abf876d6723c6f92f3b42a1e26ddbab1898	Socio72@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	78355271949542846376312640087512242624	Francisca	Rodriguez	72	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825857
98	Socio 73	9b50a4d1fece0448f01d00c8c141b0fce629877e4b15618d487773d894a66a9496cd86d91bb6c04e1ed9f1cf50a00fa7bcf5d648b27bb5b9189c9c0e96fffbf9	Socio73@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	271424797255235969025144075067922118300	Nicolas Orlando	Alas	73	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823653
99	Socio 74	5924557f2fc413a8cbead359f1075f0078717a0247f83e1e3436b86ae79978b962bd1819f5e753e920961e2fb0ec4a7ee0b97c107172e6c4bd74a7b573a55510	Socio74@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	339225539548623787307523498661652740435	Pedro Otoniel	Rodriguez	74	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	125096
100	Socio 75	803425a39bdd66ae689eddafb7ef2e17ca89a6b784c41256aff4e846b6e17f44b9c27f216d58747cf7da925a5cd0e6eeba79a5f41579c2a1d43d107417c8b8fe	Socio75@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	120210020884010631511846926773808027553	Jose Rumualdo	Murillo	75	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825388
101	Socio 76	1a438d448a593a28d0077bae477148a3a3c9829c3e41b93a6d695eef382597e451178ce4c416af4550ec3a583caf875d43b405922d1bc1161b9b891003dd2ae2	Socio76@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	72580293551236931536159452625434590003	Juan Ramon	Guardado Guardado	76	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16500
102	Socio 77	1ed296b3cb17772dbbabe3b68fa22f0099800dfa3e9777815bf7e72503591c204204d62374daa60ebe488b608dc8cafa2c0c882d9de8f539ad0206e864573b40	Socio77@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	214597012838637390336377581081864775951	Leocadio  De Jesus	Landaverde	77	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824105
103	Socio 78	9360c230d65bfb7682310fbc60b51d97b4eed7dba308e61248fac939fafc5eb1440637617e0b2431b2b217fd279ff0b93e8587b096087879da278fe4e9e40cf4	Socio78@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	115713919292624846740103525824332735608	Yolanda Marina	Landaverde Rivera	78	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16497
104	Socio 79	774d6360fcd9e11bea82a5a563cf9ffec6bcd661cc0d1daf7185d6c33b9ae567bf92d1b3e8be61cd2720407bfabdd118f9fcbe362fd6b0f70f491734730777c4	Socio79@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	66790083889042022979574658034626802931	Jose Alberto	Montoya	79	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	23292
105	Socio 80	85c24d257ff8ac2a3b0e48b93c3def5d3328363017f1cfbc2c40136c8414faf687505d457f087a187c00e59337eec83a8ed94ce194414104216dbe950c84fa44	Socio80@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	233044135819916804351505392410016250494	Juan Ramon	Guardado	80	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824880
106	Socio 81	86459b9631984bfa53e4bb63dc3db706718893e5c64b672313ac7432dabf0fa95d54b0c5ab4ff06576f8dde491134848e104f10e731c4571d91e02750e7057f3	Socio81@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	197657311368395870426638064305370404690	Antonio	Hernandez Herculano	81	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	21937
107	Socio 82	da9db0106cd3e6a0f1e9c8b5e98e105e686299688d8005dbbcd8cee56b4163b441c34c5c25a0e0910ad168493685d2cad79e68c495de3c31ef095131fdfde6dd	Socio82@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	40665958994572495014148800926365592008	Ana Silvia	Arevalo Molina	82	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144873
108	Socio 83	4c7d0114055e6d0c8482efa890f015c152211235d67f33a02eaac3b37429410dece0c56465ed21f8b2dad010e73762a52fb6f57d2939c51a19222aa9c4dbbd57	Socio83@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	328276047391185945865369355196725950208	Rosa Gladis	Montoya	83	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823435
111	Socio 86	b7b9c1118301d143abe7177c668496ca71795a7822489d737d2ff51c7679419f127fa76b9a4a06fa13e31e555de224cfdb0962af533949b20aeb1d7fc569f3ff	Socio86@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	22206915662055522508537644011030897746	Aracely Del Carmen	Landaverde De L	86	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825722
112	Socio 87	fd1158f8fa972471c019b0575a1380e411417dc91f35f420fc5cac37ad80ba8e6448f7754403425408583acf493b63e3d2cd384f29e1508a6e6cdd40514efb7a	Socio87@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	3947155801826322534986254525538767522	Blanca Luz	Arevalo Ruiz	87	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824395
114	Socio 89	bda12a5b78ddd0a55e086847f5e0713ba3b2b433fd5af90183eb100b28a9b679ee7ab251f49808aea0f64dfbbde6c2fa31f408cbe36cd843e6958440edd754df	Socio89@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	176535753495974347856995032096575999094	Rene Antonio	Garcia Landaverde	89	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825613
115	Socio 90	a65deaab76af65d0b5ec4d4a1b75f2af174f11c0c2fb586536fcfd8fdcdfb0e3708f1488e08955d4afbfef1d7757bc4aa87d056e1153e8704b87bae62666cab8	Socio90@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	96358243383775073698234266227244968120	Luciano Julian	Montoya	90	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	052669
116	Socio 91	b44b6720f1261fe994c7deae29a4325088676caf41f98a4ba8c2f8a1c23de1c40fde33dfc308a8b18618d6c3a61a9069ac39f6a1d0aca57a4ab05569023e693b	Socio91@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	137772980280229423048294805573500013888	Rafael Antonio	Garcia	91	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825785
117	Socio 92	c1d21903949c1edc68a1b8d4cac7ce567d15a6d7adead1be28c7135805feaa0138898fa5aedbe448c62f427f3ea75bca9e146725ac0bb6557c80cf2f4fa61d91	Socio92@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	220879651844662850711671886776730555052	Inocente Del Carmen	Landaverde	92	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825904
118	Socio 93	d425c08a77ba1739937bcd53af710c636efeaa41ee7fc88b3538a76741856816417ced5dbafe6f8f406c1ace57ecad93978e9231cfecf69334da419facae6985	Socio93@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	299471582302779963539519128040509445137	Miguel Angel	Batres	93	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824216
119	Socio 94	8a7d985bdc863e42d38c68dffdc012a2ba157eee71675c7219ec2a9c9df2c2247f37eef8ff4fae5d6c04ec8d843c256edd8e11b8e29960c048c3bc3519357057	Socio94@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	292533304855450225232244286775784758717	Jose Angel	Montoya	94	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	120100920H
120	Socio 95	2e90ac200537b6328cd42c7979bfbd10084ef53d81d762ece91de8adcee714792bb57b51487aa619693bcabd99b89ee7555ddba2a5e10ad816f682a75874016f	Socio95@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	94782912454236584655593488458223387982	Andres	Escobar Escalante	95	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824024
121	Socio 96	02e20dfd28af5fb5174fd925016d66ef1472b061cf80b01e7162d4777ffa82f9351521a91900427cbd1ccec58a3e5bfced723725de8f8c91efe85208e1c7f895	Socio96@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	124961404790392796311045790864469389302	Sosa Ovidio	Miranda	96	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825124
122	Socio 97	5abc81acc4f1de5e6bb0cebec184841e867bc8c3c15d71bc9edcf5f71aa0e19653758615a1e8c700d6fc06abf2cf4508f1c15fbab886249c26e25940e4375961	Socio97@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	133425343832659376746831294420090461684	Jose Alberto	Nuðez Alas	97	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16353
123	Socio 98	4a0368d9631510031de0793470e87bb8e8d7de2654c8f66e75ac388098a78ce696fcf927f78715fb97cda35ad714c738e6c3cdaf1cedc33eaff51ac7f632fcad	Socio98@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	128458917149736907387840298693368808617	Sebastian Octaviano	Landaverde	98	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823464
124	Socio 99	d459af308a6979fbaca3c70133d9148316dd86ff3f83b4068b027d80042641e16f35629e501edbfed25221a48a41a8c994249586513986da7c8d0c6a274dae74	Socio99@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	248371310857093678081558796998047068239	Carlos Rutilio De Jesus	Castellanos Z.	99	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825154
125	Socio 100	8f862f94a5853381c4d2ca8aba30bf0a4523f197a640658fd286f3098ca5c725c1c952180a2291df8290edc9946ee09e738d2a4b56e0a9c18a5615e7ab289d81	Socio100@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	866560196819838989831596343926379501	Amanda Marta	Giron De Paiz	100	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825154
146	Socio 121	987b6ed2d1b59f45d871086b5b13f7e94c7423ad6a98713132bdb882c10a605bf5623ba36401514ba74793ce3eb1ebc50e9b648855b9a6e7e6f5f09b89f84e61	Socio121@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	17757823233358714604613617792737921329	Rolando Antonio	Alas Galdamez	121	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	144928
147	Socio 122	3de0fafcebf72fe670514036e0d9de884e4e80db338665989be87709ce9ae0b56f4882f56a994d5e2b4d2b92fafce11662a28102ca56d27a769066c3490e2360	Socio122@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	201015546305874922451716034207990635999	Dionicio Valentin	Alas Cornejo	122	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16379
148	Socio 123	564994314c801bea311bb0f363f95de1c602eb1f7024459aff539f79634651c3ceeb3b5cc5d1deb2de5f38db25409b986b8fbed6e24ffbf6271e81c285aad610	Socio123@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	266397438851456837020465623895572969431	Nidia Nelsy Del Carmen	Galdamez A.	123	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825257
151	Socio 126	789db8e9cdbef92e34ace1abf5af603b40294da1df647eb28d35062e37025d9c1da85efac14cd49a7c474d30963f8897dece221f862ba3f66b6078cfd26db881	Socio126@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	162914744476004702472708024386634118675	Jorge Alberto	Acosta	126	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824371
153	Socio 128	66c872846f4d8f7f876186c33afbf5672111cf0d1d1011af3d2a45e5cb572090f5d9c075752c27e2fd5e12e45d9a6b22a68cdb036f3d303a4afa0b369e9f83ae	Socio128@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	161363254987740989000379781460856621204	Patricia Romana	Arevalo	128	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	135097
154	Socio 129	a96c875e08fc7ce1074f50e4d1b7a9b92c447c792b115513fc57c8c077c99b6d6023bfabad935cd5c54f5077095a15a655b9310f0cb4c48ff8f7c7052f64e4dd	Socio129@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	253278828046695118093881339268488181801	Jose Manuel	Rivera Lopez	129	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825526
155	Socio 130	bb2392447173586aad7f9fefb13175ee2033d0fa8f1c9be816a83a8a25c2c0f895f393eebd2fc54bf7ca16731f83dd0403beb31a52d8d014d197f0c68d8600c2	Socio130@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	21630215443577812419993175442618971477	Lucia Luz	Caseres De Rosa	130	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825863
156	Socio 131	eb98a5d4a244c19d2e991917bfab89399027242a4c1588cc5bfccc3fa6ed484a838924000afd5c7936b8ebb149d8d87f294d38555a1d99f2d640135e44185c7a	Socio131@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	87367201771175924998938424290386899679	Agustin	Galdamez Alas	131	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	22195
170	Socio 145	2da4de17b7b71fb9a5ae3267b90bc1ebb267c94c9d87512c42dd9ea90c10c2d408a13008ca8326bfeb7387ed0000d25b5ad9eef0ff0c1d74a368b4a8868006fb	Socio145@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	8630755755092429718070334069654850081	Leonidas	Rodriguez	145	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	18	\N	22187
171	Socio 146	cc4e93785ac157a2181de260d80ae1a12914227895d9f72768953997541bffc02762a1a9b60d720025629d2e250650add68910d6f00b2f4cef853d2aa778265c	Socio146@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	9958691760679755791656045930404219905	Jose Anival	Miranda	146	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053823
172	Socio 147	15727b63e4cd5d9287bcbd4d0ca12e852f8c4cf07b212e881b61ad0eaaa2d3eefd880354626f2eca72117e3d0aec1dbe9f937d57d74ae20373108e426aa6b5fc	Socio147@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	90502911878631170861406439218576144165	Rosa Lidia	Guerra De Rivera	147	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053281
173	Socio 148	4d0c56cab06cf0551949f72d85732dac7d77b1bf576757577b4a71b67217d401d4e9c52e376dc893da3be2be32995ee2b3ac9ae91eeb7735306019c85974f0f2	Socio148@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	238705540242453865573153414565037819010	Sonia Janeth	Alas	148	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	052837
174	Socio 149	bba37d53038f8cdc56e8cd7139ae7e68c6507a93df4e62174916d349bbe4fe91d187edd903fdd1af26b5003a4398b4985a43171b1432b67a9cb9754e9c96bfb7	Socio149@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	248848016986354048942882878789987356450	Josue Alberto	Chicas Roman	149	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	12075983
175	Socio 150	2d23ea0aab7b101bd1c0ca32bf66d795c7869a28ffd9ce23492c21636a0604996c330c21344e6ee9706fa648cab25f42b7611d9ee6aedf4cf4f4640f63749cfd	Socio150@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	28967627396021984463780046319810187633	Roxana Yamileth	Fernandez Vasquez	150	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	219649
176	Socio 151	e10f768040cf5e3388ef2aef91d24874f6e5afae6d747b724bce48cc15ee89b72c0ae5deafa16e5805e9f56affcd5009025e8c062a14de5ddeb42c41e8eb6679	Socio151@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	302449688023477142715552112784215107648	Benjamin	Lopez Portillo	151	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	22201
177	Socio 152	9d87929158da7e7049fa60f67a862933071eeae7a8933b55cfee496b06d8aeef90c27ea33bb1dbeb3e0f9d1c495d6ba3ab52e2ed1e5e8c79f8d0fd48ea1c7d67	Socio152@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	236266908032186607404488603999286569303	Osmaro Anival	Hernandez	152	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	21933
178	Socio 153	6eab8fdb6507ffed97d7c9ac30aab0032ff149a0b4b90fa821aad5cf01a95bf607e427f88f04b59755f6b7f7cb947fe368b4acde566306285f6c53dd5747aab3	Socio153@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	265716728599592858957412858814796884686	Obed Isai	Martinez Canjuara	153	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	018721
179	Socio 154	e3005d74f0c6e76596a1245a2c3372be812f3d5efb196d10738381359f2c0427931521b7db74b6a117b9523f027c839f311c65ed14b10bf1107a008a00f1e384	Socio154@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	15737752483377010130171469493092402353	Jose Elias	Erazo Valencia	154	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	219693
180	Socio 155	bc1ddad87c1e1cd73e32dc50d26e2dc5ddc0c3135ae0dc4c1813664ac99479b5722b461aec3cab899ae4c56279fc456bfbb5feb0ea035761578ff2ae7b0b1bcb	Socio155@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	243804626908267829612020681525340223024	Pedro Angel	Avelar Recinos	155	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	21939
181	Socio 156	5a2070b57fbae50dbcc5bf0a864a6b820149c5062dffa6b5075ff2326c72e8bb34798f909738c992dd1b93204f635e4f8a3fd8bd3acbbe40df3e9a5ee3ee2d57	Socio156@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	326580295608464300563228010140008667831	Jose Armando	Vasquez	156	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	018721
182	Socio 157	36870024959a658d8796ae9d1ccf4471cd12d8bd971d72b0b6bb83f1d8aa80b4473f07a16906ffe55d541b0bc5c2cad89d9ec86f1dea01bc5268bde7686549e0	Socio157@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	43241738919616333643815645662110446867	Rosa Yanira	Vasquez	157	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	2823276
183	Socio 158	54c337754ae74136aea62596f7fe9862107d9a1f5977f094af43ef887935963e0341ff967e9c39845f6fff1c00d72fabc9f5ae7141949105db65b08719220547	Socio158@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	278581215621496851389765274212200025284	Juan Antonio	Erazo Valencia	158	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	21941
184	Socio 159	aa9141197293c8a2175d8a70f271d93bdaecdecd3aa10d0b28d480e9272e9fc88bc15547f6718ca32de481243b6d5dfe23462aaa58c50e71966fb304a804e4ae	Socio159@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	235904593016554525222597421665781604794	Reymundo	Gutierres Fernandez	159	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053259
185	Socio 160	56ba08f53ab5d1de15a67a7e827ffa20e0a4df0f263b927563ca4b92f03a3d4f8395a6e64157ebbb6de1caf457c33d1653ddec9eff3c882b9b7343f07d7e251e	Socio160@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	18824619410109227318494720640536367704	Concepcion Polidecto	Quintero Ayala	160	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	219696
186	Socio 161	6769ad08fdc3d6b1bf47b0281c72134ed46ce34684cece3a3df2e1d7c4be2d64bbd31250ff8f3551cbb1610222f47d12798f3a04b613a7df3866135d01c5ee72	Socio161@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	27146399494964357415949849992561682401	Noe Santos	Benites Umanzor	161	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053280
187	Socio 162	d4d2e2d201ef0115d2376ca122d8df63458b8af711a478fc7b602036b97083f2190e00b09640baf89f3501ec1a4838fb6023d80dc1a78e918760c1077df65153	Socio162@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	45993861362492418983849936940489146437	Francisco Javier	Martinez Leon	162	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	219700
188	Socio 163	152ff3ebbd26f825c45596b524f28c84c4e442669e961afc8381291da6fba922e1304ee6b19b909e40ec0d0074fd21767ec3a362eb09a249d1d33e1651ffd6c4	Socio163@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	125817763248502894908486016181940345944	Pantaleon	Hernandez Hernandez	163	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	219708
189	Socio 164	b88837f1b600c93b49e555e06ffa1665b388cda9337436098915dbb3282868c2f4c0227abe9256aa3cab25189ab3bb30486e3715f219f3031702beab4f155b47	Socio164@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	27262614095570730328112637855843546494	Jose German	Medrano Portillo	164	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	052836
190	Socio 165	44eb10e36d778027660d3556a5bf7173f4e01eee17401df3c2e6643b713a19741f7a277517497f6f95c9d710aa86346a28baef9f85ed524759f3eac478d1ee99	Socio165@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	238265458696996844655502870915713808239	Rafael Antonio	Torres Cordova	165	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	052659
191	Socio 166	7cdb3486d7c0a71796ea2d1ddf8978fbbded88493b140fec07dcb22135eb4a5de62aebfabb66da6aa38e0c996df32598a3425ba96a7e7136b5e697cafb066d44	Socio166@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	334790456070615258286856865303796554144	Blanca Irene	Torres De Rivera	166	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	12075992
192	Socio 167	8dcdb7af7772e4e28be7299ca885f0d7748f008ee197cfa04f61d9ca89e42123fbdef03faafb9ee8c30a7babf1ea7b58180f16f5bc6d8ba4d723c9e44e6c20a0	Socio167@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	113998938932078596272002265225900575726	Estevan	Avelar Recinos	167	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053283
193	Socio 168	269529328497dd54185b1a2eedf189ba6729e4eb0591c6670e9c4c31d9905997aef1ae8e493efc034fe7eceb75ec31202836845f4ee988dd4069e23d7b2d1540	Socio168@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	218032444176738434668780316230720649802	Jose Adolfo	Martinez Leon	168	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	173487
194	Socio 169	87c85e3ce5bba55f27d6ff85dd4c17c5b8bef1e625b7f8adfc68f5e68e34f4fee422abb288d8fac94ab89d9be08231ae04f0b10bbceaf7f21bfb1630c6a5445c	Socio169@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	336786410395311985276646860473815019670	Jose Alfonso	Garcia Coto	169	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053828
195	Socio 170	28a38f4856ee2a5f1af016ec29b41125b6f6976d2be9570667caf56ca49262215889973ad5cd045e79d925c9c5e17c33389cebc8b1b35d74b96ea04ba5debf2d	Socio170@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	93616472220114035439922590832256728336	Rafael	Olivos Lopez	170	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	18	\N	052668
196	Socio 171	1369e2844bdb6410ec618ff0cff3bbded8f584dd7547175b4a699068e5fba0ed5cb99214f91ae13f5b38f67b9f2084f1d0acc925eb8a287d209f1e666720846a	Socio171@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	236730947659536986675647587035280895376	Jose Edmundo	Galdamez	171	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823357
198	Socio 173	d73f45614601eefcdec52f68764a4ca1e47df9cf6b4fc0e4194279fcc21df4f7ba819547cb4eb843121287e43309668b4cf23425af75cee92874ad61de654077	Socio173@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	96599122925039618480290083017799872021	Beatriz	Recinos	173	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824807
199	Socio 174	1939b024db8078af42b5334c45d639c8deaa5238c1b32415dcfcdf3ad23bc2ebd9522ec75bfc0bbbaa4ab169e10111e9eec879279183f25db80a45abddd2ec9f	Socio174@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	322140445818140577102306118035261874507	Pablo Nicolas	Rodriguez	174	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826300
200	Socio 175	8dcff5e77b375e26ce5003bfe487de8c994d01ad95815d690ce2f8e5380ff11557de7488575c41f17868c9168ce37f0ca66370f75dd728f8bc2c2afefe6c8bf8	Socio175@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	157745799768781585095914771393067651488	Jose Joaquin	Carvajal	175	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823258
201	Socio 176	e84b3de5f4a121b03bd959aaae8254c2a1c76c696e94ef48fcc924d796a873d514f308696c0d60093430d33ddc64e7215cdf73c6531a2bd89842f72dc417c594	Socio176@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	69093184620701808990028997062389172608	Jose Antonio	Escamilla	176	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824638
202	Socio 177	5ad6f166dca887f274acc0581f3063b584266e0918b7ca951d6de9275074ed1d5c2a99b25be796a8b799e57f41d1494189551f81421c4101580b552f84d34c1a	Socio177@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	121799205548284134775726495396564627953	Luis	Montalvo	177	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824330
203	Socio 178	bdfb2309f42bbb7bfaa543a3ecf2b263f17a79a5990647a52226cb5d3895cc4fb222dac08b04e5c08a453305870eb867ca0d4ef73750b53638b74a44b83094be	Socio178@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	264295240167737224544679060787681110155	Magdaleno Antonio	Montalvo	178	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823327
204	Socio 179	e2ffb387c250ed4e0327742f5b8ebc7e11b6ccafe1cc45e7762306230892c2f9c7e1b73eb338edb9b7b3f90bafa2e10b394bbd04cc67bc8224182ab12e33e569	Socio179@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	266137123194397455859982060467279021870	Patricia Isabel	Olmedo Alas	179	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	22190
205	Socio 180	84effa03efbc7d81231e4bc169783034fa4089b9fe17900ee67e78f3a7b97cc34c2d35e07602c6e6417c57c0ae5e22ce260e412363cee6ba00590b554bcd8034	Socio180@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	39534903063498059743087648596974090493	Trancito Fermin	Menjivar	180	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	21942
208	Socio 183	61c7f1c3264835e39ef231b6d425e7cd7b8d1fe59d38e6fe4611cb584216f4784bc8f60c124ac7a7678fb270720764994e22d188172475f5f2e97308a32ae5bd	Socio183@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	39660863563983899294598136332108354801	Noe Ernesto	Orellana	183	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824388
209	Socio 184	6c36a20d14a6e249425bb4d85ff1fa77d868342304700391ff201b64adc0884ab0d6c87a6b98ee36b651bedacec225f1106c40a71a6aecfaed3303a9d9ee1083	Socio184@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	257274371803741387125517203203762659998	Nelson	Galdamez	184	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823690
210	Socio 185	31e1d99cf8e0517e16711cd91c40febb5fa7fc8c2b7d17fc10ae26bbf173e43fc012c98d4770907f98920f5fe7d17f6d205fe08f394a77623923d8b69399ccc3	Socio185@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	216181968802481726039558673070391372426	Rosa Vilama	Carvajal	185	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144923
211	Socio 186	a06ff09d972fa0406489666343c09515232ea7160b20d9bbaba7248e7b7bb360eabf5965dd6c9a8b370c08e963ea0eb247eca81196df1766a4f171fd5603b4e6	Socio186@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	324765990629714728090271450358296821170	Rafael	Casco	186	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16380
214	Socio 189	49be525cc87d4cc577c015d96122bd0dc8a9c83d6a29af892595de5212798c3d0aa76a4c4cf1781b998b180cb2be5078b5e356c73747856247d9734b2ae14abf	Socio189@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	57982035081611959373646847607790369556	Ramon Humberto	Henrriquez	189	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824589
215	Socio 190	2a50f0e74f36747ac983f24ae697654ddc95369d9da6325b0000286438813c78930cd14dc52d49e6415f30198dfd23d15dbfe003a97c60cdb13378bc510f6e3c	Socio190@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	37282012195958744338982051486675040888	Marcos Antonio	Carvajal	190	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826157
216	Socio 191	0a9969b440473705d022e3b242e6ae1d9fec4f61b4fd2a33e2e2507c00bdcb0adec3c68ad581de000e39bd8dd76ba38f5eef712374ff2b5e65532b8805841f78	Socio191@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	187054037303167914143080582664319595164	Jorge Alberto	Carvajal	191	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16372
217	Socio 192	255cae0c196a2ce90a7ae8ccba4d0e360b161d438cbc2c3f7d7073cc36e3203bd653fd60fea5aba234415ed382d8f97ca24899d21cebaa5f9d14e6a2ca74dae2	Socio192@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	283274255905027519825335346726042305734	David	Henrriquez	192	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824131
218	Socio 193	fca7ac509c2a025a9b9d6b59024f2fe4397e8a065a2fad858887edf53cc3745c0cee95e150fe1c7ecfdc721667be454299f32f2b9e4eb4cb106ee06fc451292a	Socio193@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	151954126185115696757152533206484035185	Jose David	Henrriquez	193	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824940
219	Socio 194	55afbb601203e1329debf7f56bc7a7961d7a3547b0b7a27962e8b17fb4997a9eee14df7cbcaa70c5dfb9b35d8682ef7c76f226812c54e8fa4aca4c6166bff961	Socio194@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	289452285954193523070308010907042628648	Maria Aurelia Dina	Henrriquez	194	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824073
220	Socio 195	b6537d5bf8d187b14928d5de2670cdcdcf3da6cf94b38fb712d14a88c867f72976ecb2ec59cb0a0226047af073e1f0f536b5588c92077ef59f1a2ceadb34d571	Socio195@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	240100496940375907538835594466808519222	Jose Lorenzo	Guardado Henrriquez	195	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16376
221	Socio 196	79cc53b91b459645549e5aca4cf16ebda548010b3fb68f3a911a630601d6df6cfc18fbb0143dcbdb81bd73fb80ad34dd534ea7a438ea885aa283c1938fcc84e0	Socio196@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	66495656120924102697361447513870562820	Regino	Guardado	196	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823330
227	Socio 202	3d7ba383b51f330b9f5200618a186ef109352a8ebb6488d91b5b7bc7c9bdfc1cba8b030b8737f82f3021b8315c28f09063ab29d85e6c71197885d8c331d3883f	Socio202@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	46713908646375857290459761942814634321	Elizandro Reymundo	Vasquez	202	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823731
228	Socio 203	6d52df71de33e2b55180b79cc4968795b986494243ea3daac1a340342ab53355d4cf55ec1fff78d4cf8eeee5e90054e2e4dfd3a7a558141e1aa70f4fe60cad74	Socio203@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	194554941485702384190443229679949685881	Reymundo De Jesus	Vasquez	203	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825197
229	Socio 204	15187c12e763d51310cda8af8dcd44cab179385fdb384f574eea332cb101f64fe0d4bf9a92eb417046f3d8f946c9e302caefe6d5f00cfc7403c17c8421ede774	Socio204@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	189347744211167595109095978048297446007	Gabriel	Gomez Rodriguez	204	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823857
230	Socio 205	069e69df56f6fc8ae77b7ff9e6c8bbbab3858660c6719c79839c6edb098604562b73232606f447a175c0e77c7d783bbd24df88cb71dc55bc79f6dfa4c2ef7f14	Socio205@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	80835859275883002961578041239982300896	Maria Dolores	Andrades	205	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	9159445
231	Socio 206	40ed710411e5199249a995ca8bacdfad50127a1d61c63d50e21c8ae31c6ffed16941b92ccc7080bebd13ec13f31105d6114b98bbf8350a146e60432555b912a1	Socio206@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	286521829584012546362152354152381545543	Isaac De Jesus	Alas Andrades	206	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16374
232	Socio 207	a0a4b616ab1c43b22064bb743fc810d4b20626c949e4d301fefbcc5eae2f303a94b6a8be16d275dd9c050b2b9346af4398ea7fd078616c754d4f91483f3afae4	Socio207@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	179424846931542611404741290173362290483	Eladio	Henrriquez Recinnos	207	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823510
233	Socio 208	8970a91ab8fcd41e7108f4204088bcd1bfa40a2737b81e3a529c4a6eaec8d62543145731366cb10021607b4085efbfe077ef41988ede0920c22983acbdb035e2	Socio208@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	223696998154718496253150076061493070530	Pilar De Jesus	Quevedo Ruiz	208	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823751
234	Socio 209	731a4d7572a7f5c0e86bcaea7273b6a7051e5f4990d3859a0df0145403a83ba4692bbcffdf306e3cc2d595845f2145774c7dd78787cf61522de361a06661b6c7	Socio209@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	207944244209065302179162139324057920537	Ana Rosa	Escobar	209	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823817
236	Socio 211	5d76b7e00fb204450267ceb0286ff580ab9543c20ebc343b70ce245bc38895c0616bfd889b8ed9754f4cef3bbfc9c8e3f6a19522aaa0130e51c089f686d5defb	Socio211@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	61644915136998995236921651977094485846	Jose Heriberto	Escobar	211	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824999
237	Socio 212	aaa279e2a24cf8988cce91d39896a645bbb4bc741d7eaacb3f46ee53cbf72a84af687dc8f11b1077271c2af16019dac2af0d141cd1af2a223af78e85b7731693	Socio212@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	86060262915110760996470881070338201541	Sonia Yolanda	Murillo	212	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825088
240	Socio 215	f2d46b22c79cac639ec45b2628891520bffedc363d7b962d73ad126e37eb1cf5d68ef8a3bbb762e65a64fff31f2fb4c2997e80f3fdf455e51314b22a0e5251f8	Socio215@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	104352203837086705381365242340428639787	Berta	Mejia	215	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823712
242	Socio 217	59df1d28e9f28c2af038504893a761cbd8b2d35ac2b6286da7100d528cbae48bcdf826442ec17873730d72a747a7afb25df6f08e51f54ebd9dd68cb739dc679f	Socio217@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	132799266385882910110796325325040963581	Maria Carmen	Gomez Rodriguez	217	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824741
243	Socio 218	009a85047ed7d08d67faf3668c6d9e2f31033894b3b904b43874ceaae9ed7917d7e44051936adeb5c8626e11fdff51547a75bf3f3417bcdc37410684f46f645c	Socio218@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	295354072800755374880394703782927613004	Ana Gloria	Miranda	218	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824537
244	Socio 219	37ed01296a4d31242c20740c9ab5119534b2358448370f9f8aa338a63a6b293a86ad5eb8f783f50b87f63f9ea7d7a5c0aec1985011853203a1fe2e5423933052	Socio219@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	290561931371669072912000329319711425369	Teresa De Jesus	Murillo	219	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825148
245	Socio 220	f4d1ce30980daa517f161096d5d6158cf5d8dad4a4b120ee4973228221a79b85b57a7d49125e3c6eb8bcbb5b869bfb257748b278d5c0835764e9b5abd99bdb50	Socio220@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	299357756910970288123573608562607022551	Maria Cleofa	Oliva Castro	220	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825174
246	Socio 221	451d5bd9391edd55b25b5a395664896a499a9af43a797f8b4b118849fb13bf05b1e5d3a439d21defca5653e2211018b8b23b647d2e82d46b10f726dee31a0e1c	Socio221@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	182147295485017168918711937704976550747	Ana Gloria	Artigas Recinnos	221	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824476
247	Socio 222	455e1f66a703a239f9cd4cc1aa0a832baa91ff90839c82e841db2161a0a0ded8cd2998093144e911d3edfe602f47525cf4ae83457932ad1cf235d522f99272f7	Socio222@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	148237578217791672281819647219757683209	Carlos Anibal	Murillo Oliva	222	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16359
248	Socio 223	28b3dfdf427361ef84c8107aae590e46c0224db88ab3e0965a35e50fc002297fa7d52c6d2d824d4817a93420acf6e0f3685698496b485a9269c7b5f962a90332	Socio223@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	29353592449349638758188981602467119904	Julia	Diaz Montoya	223	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824757
249	Socio 224	e02ed98fe979b2ce6e97aca79bd5c13eb576bb6ffc448646fb27e3113a935ee827c07b4aceca9ab63b36f2b36775062daec8db82ebc720b38fb0c0e4e8926759	Socio224@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	158405490428474534597745430403618264224	Alberto	Vanegas	224	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823556
250	Socio 225	a0b3e51fd5f682a3735a2f63795890e5104450da24972bef18491d0cd1ff34194cd38b61a1495426e9df4d836c42520518101c29e8d5496d00078a33c59cd9bb	Socio225@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	77727986978911114952302011454089943097	Jose Ovidio	Recinos Monge	225	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825073
252	Socio 227	8bc657e0ab9a3876177c53f602f56a4a76af8925cb1032d07880cbd8e569cf16f211571771eb2874f07a783e8557b8bd49270d1f98980aa3e8688ef9549ec265	Socio227@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	205142570884302683725926829353512857710	Jose Dolores	Recinos Torreres	227	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824480
253	Socio 228	da363102afa19f2a4880bbde3ec31bdacb2b8876d3b109936d7ce1bab58bff421676682ca51267320d2098d2ffc61e3e1eec03fe952db4f37478602f94253441	Socio228@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	35762095435424880169008215373045179000	Melida Beatriz	Henrriquez Vasquez	228	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	12076092
256	Socio 231	30c2d33885591fa219cf45740cf11df5b22ecf6bac42346f36488a08cfb7478576823e32b17059e0c1bb8118ebe18ae574475c92af2659cc5379e10bd4f62a7a	Socio231@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	158350061538640870911844822881986053420	Uriel Alberto	Artiga	231	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823535
257	Socio 232	369660607be8fb71485e927829b2d3108506af747aa6e896bbea2982878675700bbbbdc759468c2eb54be7797ae1225ccedc6e42f9061966a331eba3bccddb67	Socio232@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	291977363636688916584602854934379535066	Jesus Alfredo	Menjivar	232	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823368
258	Socio 233	4e03eec48eddb5d59edfff778ae694e23d4f0ce4243ad6a10e24fb6eb48730503267b532dd202b45f7c8e2efbbf4fe928092bd4dfc0f7778c057d38bdc3c3f54	Socio233@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	276943558993071342809957424337629780250	Pedro Antonio	Vasquez	233	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826148
259	Socio 234	a0fad8dc9e96c925b51bc9641137dd23594d7aafff7a23d57b6a042cc1705c65db204f6c38f933e1ca1664c5408adad098b82b2e8054b61a9c42ac2ebb62801a	Socio234@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	71466045727771842774398936111487522192	Felix Abel	Henrriquez	234	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824909
260	Socio 235	524404638089d7102f4fa26faca5bf8b9fe78b2fcd3d4249ff682ecd132af7c79807150539848d49ad8c1535fc7056bf83e29265673fa1f8f86880ed08bfcad5	Socio235@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	186745417198222294417978781945297719048	Maria Carmen	Argueta	235	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	135099
261	Socio 236	3301b3ffc4b5fe607e7a8391f0c353482e3a6439785931f23440f40b80655965cd26261bea90145e6cc0de6e3ecb358ec5978ff18cf835f37970e579e1d35d1c	Socio236@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	60298750899465717694083076096944648942	Manuel De Jesus	Orellana	236	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824
262	Socio 237	86c6f73a151bace89fcff57872aefa9ea292f87ffd2dd42c328a8692959eb13474e032a637fc7c5489b2f4b9be8eb7de9b9bb4822ec179853aaef3d46caf6bff	Socio237@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	173157718927798684138151920764629663653	Angel Maria	Lopez Escobar	237	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823404
263	Socio 238	07402646b8c3b68c9e1a460ea5933f36e1da24aa375dfe841c776dd084d8337749056479e195ebd046eca688e0153dc226bde4db8c1cd04c5af3c03ee826f6a2	Socio238@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	325960417106028994684403658596950544594	Maria Esperanza	Orellana	238	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	159448
264	Socio 239	5fc10c83abcdb3a49362dd9f677a0c6b09d6a654228152856fcd9956d83fe7bce6934066e6988cea123804165cc061f30f0258d5fc522a327998a5b71a18cbd3	Socio239@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	139389536048966715009254529419068548606	Blanca Luz	Arevalo De Lopez	239	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144916
265	Socio 240	45a95ea49bb2a537e9949247782afd0e89c8dbf0f9d9b866f9e5e66e022bf6029eba2c7d2a5e68931c9d975c2330ed3dacfed12f718380b446729d38cdceb042	Socio240@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	330742718791682954759618279637523982811	Maria Ediht	Guardado	240	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823791
266	Socio 241	f7f9c64b56d9607084daf2f285eb452c7404f5c40cd5c026a8621be60933243831aad13b8bf12153eb8313d2d30d29ecce8197ad300f77f52bcd210b4b950647	Socio241@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	185720623377124660992658200571814421904	Oscar Hector	Guardado	241	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	159441
267	Socio 242	2e01747d1056dcf2ca9ca760f9e3563c1f7a699784b7c064c06cac089b678121fa7fba7f0a8ae879e3c0cecff30db80e42bfa18376759f1e739dc2e0eee8fb26	Socio242@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	253248667504669220124711909727622098699	Luis Antonio	Guardado	242	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824472
268	Socio 243	593553f7e8c4e3b9e3d6cf3c7ca4e9aa321933a8e86491de515ea6b50939481279286b4538d0c69601bcdeaa8df437b337a463c15413776b21a4e0bc04b19cd2	Socio243@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	165007560837491630211599895103575310292	Jose Vidal	Lopez Franco	243	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825136
269	Socio 244	79e537aa164822f3d12acd0d19685ce25063379cf7e947d626763ea8dc58fabf51c8400afb00f1e1791b8171ab6b0c0895542e508ed78452956df6607ccd7c4c	Socio244@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	184951077451177097075715770300555026643	Centro Escolar	San Antonio Del Monte	244	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	052828
274	Socio 249	4c621df0186d91ec198b28356c45a20bfa98170d05a6aa25f4c1d4bc4065bd1829a8e45961982598ec4f9fe1d5d2d5fb85bc0c10bf139aef0f746c8d5974ec03	Socio249@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	198249572568690047704878755429628653487	Juan Antonio	Santamaria	249	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823349
275	Socio 250	a60a8e8573fd55a00d1416125ed8387077775e08f33de004a830524c8f202796333d89f2525bd54e7f11ae8f3b10176c82a9cb3398f24b8fdb2dc9b3836c7b01	Socio250@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	282309608229282622508941927286793743892	Maria Emma	Tobar Landaverde	250	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824146
276	Socio 251	7a25738a7c4d1d1442d2ac48c2fe4158343e971416405237b0d4623053553e1e9cc6d9ce02febb615629f6b6ac80411664a67d3b190b89fc19aa7cebb38f21cc	Socio251@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	285512992019137531096220956639059762975	Fidelina	Menjivar	251	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826972
278	Socio 253	644dc7b00beb36e75712a4713377045b43d657b26f2b4e478ffc31a30111a98d5e6432d47427d80d7d280ccba7e329f505697563b8df06fc1d189c325df25d3a	Socio253@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	78750973667310509860036828919954247675	Juan Miguel	Henrriquez	253	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16363
279	Socio 254	05a0da51d1e8ebacc27746f959064e11e0b6396ae1f3fd940caaa06123892f203b98bbc67be6fdb5b0adb06f645a38f2fa9e6d0a09a82d344eae756de36cd0ab	Socio254@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	118605018939087399134152293302831540217	Jose Alberto	Barrera	254	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823448
280	Socio 255	32aee718e6c8c420e1464a45c5052e606d37f03c3f2214622c3c477be776bed51f7b34bc659f688bac64774e9104e48228c0dc3bcdcae390c227273bf2c7cf84	Socio255@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	32543468322790782201123916721244733089	Jose Alfredo	Carvajal	255	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144915
281	Socio 256	308e286dd7470e7d5f33b79e85517be070e703b7f8e4e3ec07682f7a6d7e3982ff32d1a8070203829ba8a594d02a31c9f284d98a0ed1241bff88e7ffa7e632c0	Socio256@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	78299625537544297881401176118463817796	Selina	Giron Pineda	256	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826287
282	Socio 257	abc91c26f947e62608f1835422bb6f5922b7ce4e74bcb93c7f9d1d843bdb250bbede5c04c03ac6e40c23a9effa3f2faf1c2af5a6b928b6696638cd357be9ee20	Socio257@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	90267925403503355663407562176277281481	Quevedo	Cruz	257	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	28244779
283	Socio 258	7b49a628eb9c61d40c1d6b3d06323e651b5fd26d7406f70baa57f538a81f90d8868253637845e9863368f28b200152e63153cd3f21f8f2316e8f61bd59f82395	Socio258@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	247622977235597625964198751968165639209	Olaga	Vasquez Henrriquez	258	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825133
284	Socio 259	9fd0d3aae3fc55e77fb5ca59be6ade920c3624adbce6a28019a076716226c11a9ed9a5724f6c419d126268190540dc9105e843c8c611a4900ab0bbe98bf72c5c	Socio259@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	77779973236883940635231352360871880637	Saul Rafael	Romero	259	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	052842
293	Socio 268	1949d4f10df272d8460d902cb9aa59609b3bdf35590de2fdfec7d7ab3c77c857fe4217c159975ceb6ada480abee3be828f3a1149f1c45bec2176ed83534c5904	Socio268@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	28805990728654667079307384206418632104	Hector Antonio	Menjivar	268	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825087
295	Socio 270	76008441634aadd2a94ce44d0d42667299448cee85f5cb39c1c4c79674707394af92a99017e62a02014c054a4c79e5bba70821fe2bc670784fde88a11b4899a0	Socio270@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	134739852753161578944245844451552925161	Manuel De Jesus	Gomez Rodriguez	270	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	159446
320	Socio 295	1275d725ffe6cd655ccb9e579f6f7009f1f7a9856d5cb3aa1e35f2c913c19ff07763ae738a0699e532cbb84c3fedc00407716b68c4b1fbe17a87d48d6e0a807b	Socio295@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	297282288991732049463374922197238815105	Valencia Maria Isabel	Olivos	295	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825506
321	Socio 296	2291205333708412feeb507902b044bd646093a4e006fef938e01cc7fc4d4c9608357b0b14ffcfdad1d47c7183330c67c205428e8b7f0fee19c029cb5882baf6	Socio296@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	143462193832313256995480637612155198919	Jose Antonio	Perez	296	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823204
322	Socio 297	d007dd5ed59240cd244ef340c914aa852c60f0581ca423c409984bc62b99a50abee50c6ae07f66c7a202f004a41d37d28472539aad19e81ff3310418539e861e	Socio297@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	336225346815118404392058021253137852782	Victor Manuel	Murillo	297	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824352
323	Socio 298	5be9dcd341fc4d64fdc8fff61f73b716bbc6f95332b4134852a4bcfe00d4e0d306752d4cd5b14705e953b6a98738894999cfca85cfea8a44b9fb272da0e98727	Socio298@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	205589168197823359589652036644278648918	Maria Antonia	Bustos	298	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2323351
324	Socio 299	d0386296e563096ca505b6ac313587584c4c858aa30c802ca9d43176f793fb16ad7755f55deaf0f18585247962ad880547ff642274d3dfbe14ac4ffb755bd2b0	Socio299@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	147878987762740053725200344406489868428	Cristobal Douglas	Romero Menjivar	299	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824212
325	Socio 300	ea5d724977b0f882fac15977793790367ab6178fa7cfd40c4d250292f597c9149eb248c4fb7d680189cf45576e13383b3ddc7f4dc8fb36a08e6fa2bc34eddf8d	Socio300@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	250974038284497625165036915073756701239	Andrea Del Carmen	Alas	300	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824152
326	Socio 301	6f5bd1734edd20f465852106192bc06f42372aac51d72825ce6ff107411ccc0a0dca93d4de78102301a3c9a2d2da5d9cf221990c643c661dd14d07baf432d582	Socio301@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	241190258870206802238672795618940268923	Reina Isabel	Ardon	301	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826559
327	Socio 302	da3b001a4e2314b26dae55a4b7ca05c3a15241c6a4949c4fb6e54ff321efcda04943a3768098355f21fb58468e2838316846f0b9d3c6a4f6dfd753077b6c3040	Socio302@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	254186211040015475451423774171904370458	Hernan	Flores	302	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	016378
328	Socio 303	3dedf48de12f5a741c060b91281fc840f4f3311044b16aef33783951eac3eefb22b8b9f60f14297eb946d71f2f4edb6e1d8bef1a4099a6ad809a52a807879617	Socio303@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	59912528983950669612295196943632708283	Avelina	Ortiz De Rauda	303	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823668
329	Socio 304	79d820d8a086dcd0694a0bf62a78c96df064ca8604c5336f6c036c40ffbbe9c2334c5505387c9a3ccfb1eedfd46790649b709a46cfd6a55aeb11b0abfa215941	Socio304@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	196164446566370350748017293181849818600	Luis Armando	Molina	304	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823385
330	Socio 305	d6e29ac0a786f1889edc1b0c6572bd7400e6750c1a91b6ba25975628a7c6d9bfa372f8c4aeb46ba2e0067c56eea96ebc18367c36863d0616d52d42398ad0191e	Socio305@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	255659537602549257063997354423183802483	Maria Angela	Landaverde	305	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144929
331	Socio 306	31bdb6a121ee8a66bfc20fedcb4f60ebc474aec092d138408357ec8692fd2c371b3caa29f397f3a894764d9f2364e4a48dd02456cf23c42556fbef8bb9d98768	Socio306@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	208547522462258790630680913256332609331	Alfredo	Landaverde	306	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823374
332	Socio 307	d7e3993baf4add686590410be281ee6b5490b99962fad404c26b8ff67c1cdf9a543fe0b94063cf045e97f33c07b61300c89e75c189fa2284038f68cd276408ad	Socio307@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	13918144261405653074381443414570843673	Maria Emma	Tobar Landaverde	307	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144881
333	Socio 308	72f611dcb0ab3d2ad1283b9966465c30b233fde95cb22113646d39b74095fa625f01b38a80d51920d9eac566daecc4117fed526131f9cb0f5c0d299746598c9d	Socio308@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	314515836102864707551793251785083540411	Santos	Doralicia	308	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823907
336	Socio 311	81fd6670c18d624fc9520b9e30f02edf083e1350ddaf2d8d14318e75b7c9d003563679005ed56c3eeab9d584cf93b365505811f96ec618037d73300112c808c3	Socio311@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	228789597348382127525423365703129210902	Leonor Victoria	Pineda	311	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	1275991
337	Socio 312	a972e94ae957f92c09ddc8e43ee76b66a9e805672a059779fc43e7abe056387e8de0a53ba7615ff7ce3ee8d2d360c2938a606b0abbfb6a7788ee06bf6236445f	Socio312@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	300333349480020647758466719566335732717	Maria	Grande	312	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826467
340	Socio 315	c91c15e50b890fc204026188f2a32e17c68826456c573390d27594fe870fa4fc798c002d1877328d960107c581e221265679ebe7d7a5211e4800b0dca8cbc261	Socio315@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	137679918370158094456948452515661010565	Ines Eulogio	Ardon Alas	315	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825622
341	Socio 316	0312eb6a3ae3f796d4f6183075a683e53afec0cdd47633484bbe2dce95521fcba5e81bbd14efd4746229f4289bc84a59c5c812ada4f8ca39698a3193d84736d1	Socio316@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	140008708841741119355952083707277113712	Rodolfo	Tejada Menjivar	316	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825726
342	Socio 317	689afccd59fe06d1fce9da19ebe6161fc87808185c7f47fd355fe9c9e33f9b1517af737a74e62d1a62faeb828f3ddbd2134ac86442b7fabcb69be2ddcf258b8c	Socio317@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	102898689384399608564079591419214133885	Alfredo	Cerna Giron	317	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826934
343	Socio 318	6ccaa3d20f19d43a1a611e1fdb250aa815f74e25a76420142b955b61dbc1f38530331a9a31cbb7d3a876488f193cf3149443b6b9b4c6c0e2ea5e722bfc7f6ed8	Socio318@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	175309121880362745558115387458612190625	Hatilio	Hernandez Domingo	318	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826814
344	Socio 319	bbf2c8fdd508d2da910f2af0c61fc70c9bb191c0f7850ae3e851ff836c6303eaa7919ed4145134f23d47bf129c098200f06b378625dad8138f8f16873f263b2d	Socio319@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	160149243170484548273364468380482306419	Carlos Orlando	Garcia	319	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825955
345	Socio 320	a273935650cf667e404a7338f7d7487479dd3272ac1f54e0965d048d55f0b320d1793b0b2b635844d6a4d3f675c8e6df3604c5b74a7a5fdc8cfd74b69480a334	Socio320@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	275147871274834273164724056313100569263	Jose Cecilio	Rivas	320	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825994
346	Socio 321	f77f5502ee9a77bb6c25f9ab77e56aff6f073dfebb2829a5a2a7727070db8f35af5e37b9a80d5a6f24e36701028502825e6c2b8dddcb7aa1957a44b698dbcc27	Socio321@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	40007912898607604901403111965406250471	Esperanza	Villacorta	321	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826707
347	Socio 322	23335cb00d335709cd9dfb767455c5dfa4ce2c739ade5f76da928c0af6af1403e70d9732884a742cbf90eac5b0620ba75bc7f422c59e0653010a761992e8d5a6	Socio322@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	270729315786457888372513987706011181911	Pedro Antonio	Guardado	322	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144918
348	Socio 323	02bbb07f7bde87c9f1c83bb273cda7710351654d7a9db57c0bd74ea349354ce56a737e40dbc3839966bf514947e990852692bc0df6da94960b180a873e2fd1d1	Socio323@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	175782998846228003976839430877982782456	Candelario	Monge Aleman	323	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2827074
349	Socio 324	b64bb43700d573541a2f3f39837a17eeab8f23591fb531bdf3dde2fd612e4c7b05c12ca2f215386778e37805fad15675c5769c87946f1671b6da9c7fe5246a64	Socio324@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	208134204642049893110353371731201302695	Jose Pantaleon	Enamorado	324	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826253
353	Socio 328	e9c8a5a209dced6f43c8e7f774178512156ee8be0658588f4b9bf636635a1ccd59b267a928034a690b2f0e3f7fce120b488e387c63d8b72ddc1be096ef51f02e	Socio328@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	201395192149011624863700924197557481738	Francisco Javier	Menjivar	328	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2827105
354	Socio 329	ca8133c0a41c599b6fa2a2ae4238407690029883c7cd98983b8e88a2410fbe582671e2b1a425bfdcc8e67dab58000e408d57f29bfb2ef62754ba5928555919e6	Socio329@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	97610842693441270242593480411455172231	Armadno De Jesus	Rodriguez Orellana	329	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144921
355	Socio 330	86ee0ac7ff2b89232f23910eb69a7bab829e6acd3802abe3ea2f8c79a6ac71c500f3d5086037180d08949b44595a39ed3ccc6436ee3e52b2abbc7217c9fb07df	Socio330@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	50795493237208680443258893643335528096	Marcotulio	Abrego Escalante	330	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	20	\N	159449
356	Socio 331	0f1664766e908915b1d79a28ba1fd3b0f6a031b09fe44ea0c2d5f7d277528188f43c5dc5aa5cf087340aa4c847ce2e44de70231f1f99698a39cfbeb7dcda3043	Socio331@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	305267474506121688360329563551650713981	Luz Amparo	Campos De Maravilla	331	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144930
357	Socio 332	1ce7c8cc8d40d94c53255d5d7d89b65dc2a5c8ca018ff4e52be7eeb57b2f4a8d494b7aa6214ba8bdd4038c21e66db7630a37fa7d5110699355c779d2c75f4dd4	Socio332@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	331723378919880651034448757491863597949	Valeriano	Ceron	332	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	1590904
358	Socio 333	38721ea0d0a75a5033c06f29b345e6e89d873a6c8f32f57d42d9747053b671edce87861c264183ef581678177be99dcb80ef025ce8f9943050f5cd113cc3356a	Socio333@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	152289909873561622002304896953044583350	Elmer Alexander	Alvarado	333	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	144886
360	Socio 335	fb4cd766a0f32478689028f15ad19636b6dde55024820435144aff03d4f32ae969c3db5bd2ef807372e4c93515dc5107ec3f52646a4c6ce46153a5d92c4506ac	Socio335@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	156815709684039563457956435568522949440	Julio Alberto	Caðas	335	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053879
361	Socio 336	b41976991035037ffa657b4002a522080794b5f7ffc1a950b47de606723d7e0a85a4cf7c36aee1a9a5e798c67f7e3c8d150bc4e594be775e46e144148b9cc7cb	Socio336@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	196575021207664378886254740186802819914	Jose Carlos	Alvarado	336	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053819
362	Socio 337	f0bd10095f38fbc445127eade1656256821635835d82ce02e0c02cbf1832ba75add30b5ac05ca54d8db4da5a8c7a32b79de132949bb0c4cfd44b63587b82a583	Socio337@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	225756188128869834404110588820615418351	Querubina Elizabeth	Rauda	337	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053830
363	Socio 338	cfedd435c7e0fbf9085bc49c042a2eabaded60be7b49680e45ed1127df8eceb9f69618a195ca0ee62dac49c1a36084715faacbe30be0bde5588aa321e3fe3012	Socio338@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	107406538410221359784830233018159562724	Dora Elicia	Guillen	338	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053278
364	Socio 339	cdb733f51f8fb2da47020da567cfc10ad89e0184955a14e197dc4f71f859625f49b7b8917d1d92c9b9bfa1f11e613c1a88a201294d60c751764d5ae7fb5f126f	Socio339@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	57788443768831156262420276834638151369	Maria Martina	Ayala Alvarado	339	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	719993
365	Socio 340	dd0d81d41eb00571380a46034aed87b7a76bb1ba52a7ef08501247dd354a9a2874b7317b272db037424739757c68f2f814f47247a8eb560d9450752575293ab9	Socio340@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	84013893362915469967925480273408411484	Maria Luiza	Chavez	340	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	719994
366	Socio 341	e8c0962d97c5e4fbb527e1ec89a57acea0c69fbc09f7efef7a30b02af03f589f5d97dc760784e38b746799ae4ee6d42cbf614640d938a1a2c2288b02236cf819	Socio341@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	67071638348886326601241937313840750921	Juan Antonio	Chavez	341	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053871
367	Socio 342	733f5f41c0baf7fb58e5a5bb45af4b02dd3037bacf695fe04ba839501c96b7fa9af046a2910944512ea508acc90b1b77ec8048775e494055e1b29b0d11b8f3fe	Socio342@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	248896910863787533593855737149829351434	Maria Lucia	Caðas	342	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053880
368	Socio 343	8a62431c8fbf937faf26a845a79c885932e4111ad9a53c80311d0088025f3c2ef776c91164626f62add4fb83a1f95816aecaa88758eda552f8c0c43081a15e6b	Socio343@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	177246680879520052918313360470749316008	Jaime Antonio	Landaverde	343	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053812
369	Socio 344	447780c4633884ce9804b89d68a0db4ee2b06427edad90880c2771656f3adff6d4a3129deccab5a71e56f8a1ab47a15168c0f56c1837e0fbd69ac73b9655a1ab	Socio344@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	276234724575858869365001525951272724631	Maria Delmy	Ventura	344	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	153811
370	Socio 345	7a9db4bb047164cc10dd0c4f5e4d4382a592e02fa2a08b3d6badf6afb48f14ad6cc8a997bb05de65cbe5b8d3d2789f480b5da658306297263324e39457d29ca2	Socio345@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	302370802003622080527887799099520484965	Jose Miguel	Ardon	345	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053820
371	Socio 346	15904be5fbd8e70d56b14614f5a52bc84a6bd54fb9222dad1ff6bc8c5f6d6ea8abff80dabfe4471e39580ddf96cde7631ce6fcc39015b8f69b0a61ea7e17b19e	Socio346@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	319038058281740616199071845429850557935	Antolino Antonio	Ardon	346	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053813
372	Socio 347	849075be6f519a8d45752e26b44666e5ae5424d8a8090fc0e0ffb3a2b23c30594d62faa7a7566d9ea6e90c20b30b85a6fd9f8a7b3cd005aad21a29ebfb20d611	Socio347@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	12918557713281742227294191734734348794	Alexander Alonso	Ardon	347	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053814
373	Socio 348	ad628fabd9849099590f3151fe0470c909658b1dc49019df1fd79dbffd2c7560311deda69a592fcc5011ad85ec0a74bdc282fbe788375875330e797704ca7225	Socio348@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	281266076822878241933694478571392879905	Melgar Hatilio	Menjivar	348	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135053
374	Socio 349	7a692870442e7bfd73f591c89fff6ed95002be7567dfc27c8d49e6937840968f008fcc91f3a28949ec5eda2710ce68f8699c487cf1b1a4c37fc22e951d3c076e	Socio349@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	147894069854641605802200369052054359087	Jose Armando	Ardon	349	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053882
375	Socio 350	81f699b98ba0219b90bc14be85c29050671a5f2dcf2cbc6e65aebc4ef6da98c5c6e5b24bc00aa318a48805b35cae53b2b9a22dd83a52ff21f4436c05a8851e69	Socio350@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	14937310208903295575444608002466368057	Jose Isabel	Caðas	350	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	719947
377	Socio 351	4a6f1bd620168352fc5404119bab5f86c99dc55efbd361f7f606274bc033bada9ff5f18a03e8d5899898e15fe152b7cb6c35a86f12228b2361e9e78ba627e0bb	Socio351@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	27061883147312571970852841320755284925	Miguel Angel	Marroquin	351	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053885
378	Socio 352	4bb37d9e44734c23911877c3be4e175e59a32d1f262383c866f387d099fad02a5f0c3b0a430ff2bd2f1aa4338f5907d298425e742ceced85c915e1b9a994325b	Socio352@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	328991522562598835035440537368272941819	Maritza Beatriz	Mejia	352	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053881
379	Socio 353	7fb08629d03f1c1ab2cf1ec906a0d15cd51d47cbc2db61f064bf67bf2eb3dfdb418cbf0a156f927b5d061c9a8f72f041b2406fae7f9be1c67fc08c726f0f2cb8	Socio353@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	116317320813896882498559009632383793946	Jose	Landaverde	353	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053821
396	Socio 370	b0defee96604f432c5f4d9d897796cc7dd1676873e163e343945cc2621f3ec715d0b53895f278e2521b2832f248d87e7591338fcd44aeee75c4f11fbb8d7f9ee	Socio370@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	70014778170603006775426032326454006511	Julio Antonio	Lara Juachin	370	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	16370
380	Socio 354	9ab5d303ef036375cad5533c77af5f738f350dfd22cc0c78c1ebf96fc60b6e6009d0b1d48011ed6029d41f651f46a12c099c4d80aea2f7164477d4212809cc71	Socio354@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	60327861366397854071040381099537654753	Centro Escolar	San Pablo El Cereto	354	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053875
381	Socio 355	b62d9cabb661c022c4aabf45e485fe1b6fce77b52a2788f12cb78b9ff0377d32e8d5986f80ef0cbb684f69533b04214f0e56d01616cf013f48994b5661d50ef6	Socio355@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	53215584447737849206928981376828132452	Mauricio Antonio	Juachin	355	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	12053822
382	Socio 356	7a93c6270b97b5e56b67ae5dfae81745e07a707b3fd0bfb8fe3a7e5262d0ac5d2ecc86456aa8b031ae7f64f599dcb23274aa9c673e7879029be5801a5390491c	Socio356@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	266428987810468072053647575183837212042	Sara Elena	Hernandez	356	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	7119986
383	Socio 357	ec233ab9f01998f08d7571146b9ed73954abc2113a0ec5718899ef05f3443e052e70c08aae114c8249e90202d4053910abc14e159f9b45edaea677a5bdc2f72b	Socio357@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	25076569428097929017284786264847689413	Jose Antonio	Caðas Pascacio	357	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053826
384	Socio 358	9dc1a388ff78c9da96191ab000bc0ec2338177f9f02127689e941fb5fda9cd6498f7694e38766c9fbaddcae6c653bd99fc3767559f512b1a44b5360b2243eec8	Socio358@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	54565366071911778777230043592677893673	Jose Antonio	Lopez	358	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053886
385	Socio 359	c72074964d61661945cb082d6dbf678fe0c0bfe2a430059e15758e2fcfbeeb70ec582eda72fc4f36289428494c96efbbe2c6ae71ea16200c2fd5eddcfb2781b8	Socio359@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	9327150456849103552466795259349283097	Domingo Cruz	Menjivar	359	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053825
386	Socio 360	3db27c84f4ce57432cc4ab4a21d3b33fab10a2560e48117b93d4581b1edd053fe1a1b9886b9b4171d7b0375e774433aa0a545412f085c3d69713fba9863c56e5	Socio360@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	127755028833917301570282500580570158798	Eliazar Antonio	Hernandez	360	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053824
387	Socio 361	8e0e13586d436734a8e595f23c24c9811783236508031315171e0d12787b5d22330d85955ec7922dc68494602661e9c2ac8a0dcccac8ce7b1d22184825b1532d	Socio361@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	149456543480965968281073097034155117708	Angela Del Carmen	Hernandez	361	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053876
388	Socio 362	8a3b18b31bc1bf189f4a98ab4047a01bc6fc1fc27871b9bd2cbd0d971081ad14b23f70fa28ee6a733720c32949c19958d76f513aedd507f9774a840a0221ca30	Socio362@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	161741251102262734551792173903762503132	Carlos Antonio	Hernandez	362	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053888
389	Socio 363	8fc523379f3a2fc1434f2b6c442c966e9203f07796047057019c82622a18ed55799dda56ba49607d2c9cc08e12179a28b3951929c962d0b5ad5594e01b2c4300	Socio363@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	136239277426100134187757250949806806653	Jose Milton	Ventura	363	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053818
390	Socio 364	464073049db774cbbc01b17af7a6de8029341046c55a0b7f4aa50861c9a13bea0e7b1a77814aa8dcf65ab39b0711d4a9b580ffbad656a3a3610df183ceebb4ed	Socio364@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	295245349203062154305981701072599911733	Jorge Alberto	Acosta	364	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	720000
391	Socio 365	b8ef7291ab6a9ad59781dbdd817a4ce09a04d00b0254c175289813df4e506591169468bfd9154a15f056473a87db8e689104b91bf5e089a8d95d28fef15359f2	Socio365@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	247391422694207641892889043837270766575	Demencia	Aguillon	365	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	051906
392	Socio 366	f014ea530bab21c9276096d85ad85a05704257af26cd608e1bf3a1efd4a0d69583c60b28b67d4885fde548fc636c986c16174ba94d45cfdee8fa0299703bdb8d	Socio366@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	231410207648560596533007155112145224229	Maria Yolanda	Ventura Alas	366	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135051
393	Socio 367	0119cf97913f829e54911603d7f9e28c5652ce14a022e802eb64a2bcf46ac97182b4db718d23044fa3988d5008a64ee7a389ac45cef6a36d57c735e81fd5ce2a	Socio367@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	183933768839981223358501410394073408291	Leonidas	Rodriguez	367	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135070
394	Socio 368	a34ac082f070ceaa5349f33747e3bdd86f6b5bc22e6267e6a6e8bf2aae7ac091e18b6c32667b81edfef10671d061b4abd10a870cf1a8bfe779666f489fb98617	Socio368@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	273553160370476977659390205049553719968	Raul Arnoldo	Juachin	368	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	7404
395	Socio 369	95b77c9c02b1f5076e6edf88060536ca0fb86e5ff518bc52679650eb143fa86db50566ce9bbf3a522af6e6c49e4dd065fcd79f069bfcf75ed2f30f3138f1840a	Socio369@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	146565149664467878512768683316795298855	Hugo Ariel	Juachin	369	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	076094
397	Socio 371	a144852ef5919e48f9861a3f7c76e2d90827bcf4d099fe239a1168609a48ab140f19f63ee37dd03348a7cd9ad91f7f08cb84fc6c0a7c28d4a3bf33ee24bf14f2	Socio371@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	98988948214168596855279348478745303076	Marina De Jesus	Ventura	371	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053887
398	Socio 372	22e95eaf97681a63ce988409b2023057d5d1e5a20fdcdb14aedf05a5b134e320ed942cd0b7b768a5ddf28e0fed444aa18b1f2c0e83e4fa9dd7fabea1b9962cea	Socio372@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	310214138042463482241650418745206355043	Othmaro	Ventura	372	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	22205
399	Socio 373	00a5eeedfc094449756e4f4d1d5160f85ecc9798ecc204ea96d28dc3b2ceb0dcbb3d7a9fb1f5dc2ca45cccbc0a8eff7a09586e792e43c3ad3ef918567bada80c	Socio373@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	272996989815944646986842868881819594415	Ventura Ana Vilma	Ventura	373	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	136012
400	Socio 374	00fe646cc476acca520287fe08c11e410f0904c4a03eb13294c0d6c80730d1e99d26ec7d1aa8cc004e30955fb8a5aeeb6ee54c7f2c75988d6cf0eaa73e034e87	Socio374@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	294248743937090335873913535198674526760	Maria	Zoila	374	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135052
401	Socio 375	a31f5d2eb08a1ad33d78ddf2458e47a46512f677834528fc73442b8c7e13adb702dcbe9a96cabb786c0047de7876653c1bc5636a970a32f52ed5f02c6246b6c1	Socio375@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:47	127.0.0.1	323153987700973269730177323725279248279	Yolanda Del Carmen	Garcia	375	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:47	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053889
402	Socio 376	8aa501305a4fd468bd0a679fe5b362fa080963c6d874b5f8f17a5d589c0bea68ac7e6c2afb8666d0e22a0ee72e984a6b3d505706a8cee967fe4cc1fb7c6aa0c5	Socio376@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	766868459554643361905857503583453483	Alfonso Orlando	Ceron	376	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	22203
403	Socio 377	5c6964bca6dcea2c2c5103ef2743ac0cbae2afdbf1b21ccee347497c71053f3da73eedbf730a47bfcbd0877979fa8f68b8e242f09e08c4e34ee901db85a14d00	Socio377@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	340136191482270758969762171565603562117	Jose Rafael	Ceron	377	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135057
404	Socio 378	79f200b68f173399e2a8ebe7633d504768705ffa1636663ce253c3957b40e6f3d5520c36fd0f9b286208f1291d00e5432433c2033d0b02f3e5e03c08dea0351b	Socio378@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	171050444564196773846179668976018399143	Rigoberto	Ceron	378	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	720031
405	Socio 379	572d1552fcc6b8b1d6425061296192f016f862ccda0b1b47f805ea72339b726402636b9d433e639e9406677621d0df57b35a7f1948491fa64e4687d8140d0b33	Socio379@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	67328346231995944011543849138269890956	Jose Raul	Ceron	379	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053284
406	Socio 380	c7599dc7c562f4c6297fe8459d0eb60f11f9a5ab2afd850b0257de13f4a5027c3454afa78a2584871ecc20664b5a2878c0c476511cdb40477d462939a05d3fa3	Socio380@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	98206301084642025890534724947262164805	Martir	Mercado Sabina	380	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053286
407	Socio 381	dd96dafbf43a89983e919150f4ccbd3c6b98afc713a42828d7c97f9cbc83a3f822dc130b60c3470283320c5dc36bdcdbc357942c236dc62af2b918c385003365	Socio381@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	303060856575235641517641244419136596763	Jaime Alberto	Flores	381	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053877
408	Socio 382	31da9654a7784a7a11c25f65489027fb19676c73734af1f9654c97a185b1df3bad280a329c217c95556f5daf9e52fb2ff5c46a394c4c78139102b60f3c13cf10	Socio382@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	227459985512098785873715641576039067687	Wilfredo	Acosta	382	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053872
409	Socio 383	d1b0b5ce4a575dcf3ae047484b481d2eb19749414a21d737f4285884e985f23394c1b8198346f1d4e1960e74176130c77c9dcba82fbeed05200bc19dee68ffae	Socio383@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	157193175704116823476286742982081822037	Rene Antonio	Ventura	383	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053890
410	Socio 384	ddbd750dd3f50d90021b28163e1fb9fa6ef04abfff4882b4a732ad92aac8c0dbf3e58ddc85bdd3aeee6e3788aaf0218ddf20eb5169693983e89320cbe4dfcc00	Socio384@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	33856892081384143592185581166098287529	Leodan Antonio	Rauda Garcia	384	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053817
411	Socio 385	8fd6703130313372e6ced90bafe5b8935ab982e7e818fe60b07345d41fb43bec1fd226b41e798fb52f515c589fe2c2f3d53a199414a80ebd16a8bfeab115217e	Socio385@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	42002164876143903877002532737729226684	Orlando De Jesus	Ceron	385	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	22206
412	Socio 386	77fa78ace3cbadd8c7d7d8304468065c6684615ef97494df4a937f064b76a2ce68cd846e30fa153b605c0139cb0dbd1f25ca816890b8b3b2d0828eadf9caaf40	Socio386@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	164730775320789423598248739496820515621	Francisco	Lopez	386	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135063
413	Socio 387	3728b34480d270233f1c523e6ca9680f6a0441b9c6b92b2a959f748d1c113e558ccd47319278df7dc44d792ceac4e9f6cbdf721dee9f051b5bcef6597273bbd4	Socio387@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	294862945482963762797689529438755780750	Rosalio	Maravilla	387	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	135058
414	Socio 388	a0b9da6d28a077867150ed70566b01d4f89f9f292b353b58a4cb1e69b660bca54ab3e7ea367801229174ce48e8bc486b87f1c948114d3977540ace3efbab0b2b	Socio388@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	289201262502382082788121605818527380708	Maria Amanda	Flores Rivas	388	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053279
420	Socio 394	6c7f44073a67323da09095312aaf85dc3c2fb083e38ed80c2e4b93434b3f0419d16ba457025e4015df414cf469ffe154d7bf1e3fa7c780702f8cf9a652a2fcfe	Socio394@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	248636479712156720756152365738291694142	Luis Argelio	Acosta	394	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	22188
424	Socio 398	750f31a1bd011a215207cdcfb35ed22774e31b3b0c31f027ab42448d02d88ac0752af8e1ae7553bfcebadf8a27bddbd18f25ea5b76f6c7cdb201901348d647da	Socio398@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	191895740901636581114455110550436181212	Maria Josefina	Menjivar	398	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824632
426	Socio 400	0e6771579e8e168866edf98f201bfc798cbd827c680a7382ca6b1aba9b48b670942a02bff4f7baafdb4c08149ea1956e3dceae097b2aba9cbaa711638341a6c5	Socio400@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	223713388336196657724054112124230319701	Jose Mario	Recinos Monge	400	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824744
427	Socio 401	22bebc94b945f62bfc362f62f75e835f10e20803324fc4827cb002e9e3f2c3fcc287f02ae57520a6753a9469deebd5943a2f62adb29d101a9b4ed26c465a8892	Socio401@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	231073681590530553977062664187786375380	Amadeo	Rodriguez	401	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825932
428	Socio 402	19659a992f8d3f6c3fe0e10be2cc7dce0459dcae401d87906537782c5dc1e87d62c896efb4c63d1e729c8c245d94dcde19e603c6091be052023afc89f3a8fed2	Socio402@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	254287174057254016600882509687813463887	Isabel	Leiva Leiva	402	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825010
430	Socio 404	b7974aa8fe31b977baf192e45fd245cd180ff07b6130695ca8077d896da56ce052c4857b6b155d266f45199be1ed09890c21e304d6f7e0c13bf0689b5700af7e	Socio404@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	291262002482055048095142777209346723563	Elsy	Landaverde Lara	404	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	16369
441	Socio 415	9a8af24ef106731d42c09871198b8a29e5cb54a7f4cb4414c96294433dd862113399baa200918cd704cb48ccc4cea11dd3c9e8e7c5a8c8f3b6565fd2c9f3d872	Socio415@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	183045265643244388942092493545256875060	Juan Antonio	Ayala	415	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826234
442	Socio 416	2ff172ab809d0ff22b773bc13ea44138c09ac80509b4a3e2a8a245512aa43d0dc4f18382edd158557fb2cc0e10876309ffbbd7fb7c79ddff5f61e7acc2ccc60c	Socio416@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	122623620659126325569757749034473260285	Santos Tomas	Ramos	416	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825125
444	Socio 418	6299899e4f80fe3303708f2b25a8d60b20e34c5dac8b1a7afe017f89ed3a0128796c3e22180ccbe6b3b2deb09859c13fe720dd702278e94d07af9ddd5a5f7027	Socio418@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	340281665064602053255676602182264583612	Sonia Cristina	Leiva Recinos	418	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	1448871
445	Socio 419	6e01be9e68dff72322faed00415d8fc9d1c6b3c57f0e7482d04f714e087e4d234f5adae5eab6ab6f19ed0f4a986f90a77655b92d488c860a33771cef9b873bc7	Socio419@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	35222751452505744124929730261698668811	Josefina	Leiva Recinos	419	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	1
453	Socio 427	9606826be6ff40d214506a5159f72f1caf30f3dc1871b3e7079fba46fa63a86a2dfa1dc320745de3a1c0513b6250243713c1ef670ff9629fe04a948206167f4d	Socio427@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	258640120649508307776154789255293321159	Octavio	Bonilla Ramirez	427	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824258
454	Socio 428	0b5703aae30ad41e64948fe88c0616dbee3ab6ed667ed11354ded95f1317484b7df7595614c44e8835a0ccecaf6b8076ba574be84cc713998db12d5d04cd42ab	Socio428@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	247647951680275429788815881514739267428	Santamaria	Clarible	428	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825195
456	Socio 430	2cc78c51438a8b73986eb2e2675a20ebde3731871c933cca43dd8b844b57f2ff88441055b9bf4285c9836db872c94fa1c24dd02b5b29ab95b6bdc777b8ca9a0b	Socio430@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	327864571955568218274144619900925786925	Wilber	Ayala Mendoza	430	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	159444
457	Socio 431	be36e0f4a2cc1f2bca939cf3d354f25de9c0050904e141614d18e2a47c1fce69782b4e8c8987db5bda2d08cb1f34b18950c7390707f5d1e21a4e651f201fd572	Socio431@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	68798842921908932389131786805014139568	Pablo	Giron	431	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824950
458	Socio 432	3c8e11a18deabf135a993bca164c3d9ad227ba26c48319ffde901952fbbded6e767a90c2a28616a892aea5be3efbaccfed10eb15bb19e489c66428ef9cc4ce7d	Socio432@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	263211955406279665723730730253623909855	Gilberto	Hernandez	432	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2823821
459	Socio 433	9d3f148286f1b26a6484bf4422e8b7f95fcc7fe046635e5d0b741b677f504d4dd27d61bbb47a124015be7a29d5eee0256c2c80051dee7ec6e1aefd333028f395	Socio433@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	115581223545960833515032492193851050746	Carlos	Gomez	433	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	144877
460	Socio 434	d08b1fc2beadd709e9117060d22f7133006bfb3cc6de237ab5da4aa0a91460745e2b3e5b4a9f4dc16896032014568588751351597ad908bf5a533d61a1209e99	Socio434@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	188002577609037484474885725220700140799	Agustin	Aleman	434	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	135056
461	Socio 435	7d94d3fd9c3255c8291c04701c4eb50de42fdf857882bf1b2f6dc98f4aee4e6636ad9427f4d4cb4e37509bfee8b6c53c893a248d1de9b5d5f7708981fc882e2d	Socio435@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	165727719327707009880920268020732925474	Manuel	Ayala Portales	435	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824413
471	Socio 445	19eab7145e7a54f86c992c0b87ce1020aad048c07079773aa2b70014c53efb2760219e458902ac12d2fc91561c09fa7c113b8edd42405e1531a4c0229508d54b	Socio445@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	45151663740281754028460626219086611276	Luis Arnulfo	Marroquin Herrera	445	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826084
472	Socio 446	5195013b305f178e022982e56267f8bf378cb1bed6460baa2e66c29c96505464e54db7fda46a154bb423c8790b0aa815fbb514d07560dc33c0bc43314a23ea8c	Socio446@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	262780622093247865975797585310615064515	Juan Javier	Marroquin Herrera	446	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825023
473	Socio 447	bc7a4f6240f0902200080bcfa6cf41a6b77afce65ad695a8963ee772bcb4c552ca3045bf3ed775d73df9d93406d5db936b3d8db563271f6251984d0ff9b851e5	Socio447@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	185235021095745956762662362175122456321	Angel	Rodriguez Corvera	447	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824046
474	Socio 448	3c42c754eedb4f62e51665877269ec8156093ed48a167d285582cdce2fb2f43fd949c4f41258095301a83dbc5ca058fdc06f6bac6373d7eb50c412ae05b40fc8	Socio448@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	139118132872261876579932389152649021168	Sofia	Guardado Gonzalez	448	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826291
475	Socio 449	053ff5271e19413c38998eb54f043620a699d06bfe33b94e4814b81ed4ba1161421c43936174c818e9c25f668cb7872d02fb29fdab58783e645cc2da7dc5fdba	Socio449@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	207353171221545121773325700698263721381	Elmer Antonio	Rivera Chavez	449	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	12075995
476	Socio 450	89fa6283662dfdd91f8b6f77c085f6c4fc1c9d897358713088472353ca7f201b4e8f8d5609f4a4b1f99f234d65dcc96e2f60bdfb4ecac5d268bfe11d13f72332	Socio450@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	308242027260999806350668327072023098374	Lilian Margarita	Silva	450	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824239
477	Socio 451	7cc1abd6b5f602dca1ab466dbea78283eeca42a67e4f9c1b1914c1ae146b1edb32595f51d245ea9eee0fab2123a5f92a1c49d092c79ef82d41e232582c47467b	Socio451@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	118826997667068519271929239772900281532	Santos German	Hernandez	451	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	12075994
478	Socio 452	ef2d8c3e463a7b5b9b66927b5b1e7a28066333f9ad772c5400325404d2f9ab12f0bdbb45117588ece718ba61779425c0c645466b9b7d94d6935ec2209acdb99f	Socio452@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	61587962863095290646733602997351983535	Lupe	Barrera	452	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824057
486	Socio 460	599ec32bf6f35e2f3b673eac7e987ada964e0f3a778aaad2665ba1ee9c5c62ca67739ff7c663a1fdc19eaed59bee1f2dfb7f6de50adc772ca210a66fe75771f9	Socio460@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	273978234966953697874555262041117144928	Rutilio Valeriano	Duran	460	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826332
487	Socio 461	9c64ae81ce1f271b4db6ad12490ff99f6b809df780d77c117693407d0f93e49a50a919374103bf8bb04c897d5b913e3ff1e6e58a90a0cafccf2c309486e8fdea	Socio461@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	157286247244934133397515637729986100118	Mariela	Ponce	461	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826165
493	Socio 465	0edd834133a57a18cc4f5c0fa9e2f0f691379bc5ac502b9ebfe19b498b396a5e769998160863e6ef0b607c7bd63222d2d5b35034aabed05007e4c50379e6b6c1	Socio465@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	254343660795005261922850043267099603581	Angela Maria	Franco	465	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2827104
495	Socio 467	e13a534712b96895bf3103b45e8b2a2ca884d61de7cd7b51fb24bace7a4c193294df27494c63b8b452b284e9d7564da56f2c5535e005b849070b7498e0a33ede	Socio467@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	231755825341490452223399828015103452760	Jose Dimas	Grande	467	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	16499
504	Socio 475	b1853a50dee4a9aeb780c82e51e72c161c66f6e561e344304d271cfcdb1286d87473542952cb9f7da294ab4da20c4e922cadc39591fe044ffcaddfd499ec944e	Socio475@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	29013553711436869446142564154450058136	Ana Cecilia	Perez Rosales	475	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824492
506	Socio 477	2717814e3078f5a61c7340e8b7e58e1234358205e36f0710fec2050b12b1ea2434fb7d207208e488d3ed1809eca2c0189ff54fcc47e7fa316f8ae35fcfdf98eb	Socio477@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	167337589205377105055220884223473806728	Jose Angel	Miranda	477	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824561
507	Socio 478	ddddcf117057446edb1aee324b2f63ff7d64f852305793c18bd82fd0d8e339b0a89b94f395753341b42a1b8d0118f6e30b26fe1611f580259f4fa8873b958af8	Socio478@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	292830254801903297898096243786443439747	Tomas De Jesus	Cordero	478	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825155
508	Socio 479	db215335840c142114e5774e800a401297f601d755be5d46444bf57b4674d4dc7069d7d3f18028bcc874e80cd310a65cae6bef47a67da1a142e44191ca767814	Socio479@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	215288828004884040804220507258449438375	Guillermo	Castillo	479	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2823828
509	Socio 480	d4ea5ee526a0d2de617b44ff0bbbe79785e39a499ee48e4d16bb9996d3529f4cafd55f89c7ac3fdb8549975ef02f3c86997a3e92ecaeebe68a11c16cae8aa6f0	Socio480@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	166317219738377555499252398228770861209	Maria Consuelo	Herrera	480	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824428
513	Socio 484	d4055cf3f90ba14f39ea6af9f4d2c81c1d0dddfc0d56b04fc6b000e201e52018d8a17f790eb9ff9d22769de23bffa031382cf5d3ca2102875a820e0fc6c986c6	Socio484@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	146434126713960879345885008312922687774	Ramon	Rivera Martinez	484	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	21936
517	Socio 488	8701846464b95f217a1f5791a505383e40ca0e5400dec7d8ecefb1593bd6a557087aecff18d6f028b0c9099876f8217e1dd6ee5b3261a72e06830f73d1f00104	Socio488@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	52542452683981287575188654299080546674	Victor Rafael	Acosta	488	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	19891
518	Socio 489	6515597518275f6799a967c7d43982d3fc701db769a619b474cb709860c719bb90ba7785b8320786d7a19c5b79085a55a26a73f874efb20336f44ef00f330424	Socio489@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	309807869947985363837713177327236087087	Orlando	Barrera	489	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2823339
519	Socio 490	717cde2b31191a67864e22b93c79b063b9c65876770815ce5f42e4c25162fad28bd26032f51138d7e4e41d48eeb2b622f720b7eee9e13bcf46d223fc4d6cbe71	Socio490@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	228948293537944030677495607216740769491	Gregorio De Jesus	Acosta	490	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824079
520	Socio 491	9a003ba4ad42eed91ab1d877a53eaf648fdd5aa273a3bff0d3748cdb3758f8f140bd189c9dd97f547b6de3d6ff3086bb3e564437cf91e6efa3ed073016a7183e	Socio491@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	273980655556662627185077640619228643555	Juan Antonio	Barrera	491	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824001
521	Socio 492	d20892800ff8ecf85e57f47c56a2c9757b8ed94ad465bfd5335e7e19f954c0c5652c553f1366256734a2a9bdefd349356bfc547a7b4d363c80cc5374b43d634b	Socio492@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	123095860006375025469316506577059069778	Maria Yolanda	Barrera Herrera	492	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	144876
522	Socio 493	dad42e34aa18e8ad7629a8333b10c9a1a31b057b190b4630e58e583e7abb8a813d6fd6a9640f242fc561334e28570f31f5702c18c19958e614517e9106a7d129	Socio493@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	268669333578109000234570178138346144126	Linda Concha	Alvarado	493	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824203
523	Socio 494	ef4ae95cbdf26f16c27c8ce6afe5dd2c4ef5c98477f99a5fa9cab6f42682bb011c0078c5151fbad6b1288e04831f039e51dc7a4a6c39a017851e467fd2242cbd	Socio494@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	181069961240347327003139890981895997662	Santos Del Carmen	Alvarado	494	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825864
524	Socio 495	97640da1044a5da94177c46198347b6cfd8288d41f0a892906740933ce11df809f4fec2d934e6d00ed2059448513b6055ce31ee06080a1a9627a2200d5776744	Socio495@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	272273961305752841607142511623846359451	Carlos Arnulfo	Monterrosa	495	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825108
527	Socio 498	4b780d6fea53ba5a3f822da03e062409fd26a16959d484ac2c7f15e86583d08c5837c1eee927006c80fa6282f6c2c4c674532bfaeec14e5210e57741b1fb5208	Socio498@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	244112764693174366414639391963007033301	Jose Alfonso	Duran	498	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2823893
528	Socio 499	7f4fdd501041b45dd78fd145b51cc58e29acdb8aa32726d91c11256be84f2a7812e9f891896615b8bc11277ee8b2b1395185eb8ba7ffa9bd66f34261dd8cf3da	Socio499@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	46387041420522647330870411564410083937	Jenrry Leonel	Delgado Mata	499	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	16361
534	Socio 505	3506533736db28c187fd2062fa44783abc3d31f33ffee17fd48e462311ec3e270c602e73c5ed6125a607f1eec5d8815e3f3fed1c50017daf64e398bee6708091	Socio505@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	274906158006219955978413336195748956866	Froilan	Mejia Menjivar	505	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825778
537	Socio 507	e7433e94bf4de4ff8b118fce9126cb7a7797a13ec5523e015bf2f0302b56002eda880f850631c3053ecdce34967c6eebc142a1c5d14775f5764511815b645be5	Socio507@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	92851588790975109756910794789059629481	Miguel Angel	Hernandez Bonilla	507	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824530
538	Socio 508	03e56e0e83780f177141a5e4dab59149f065373a2dc293eaf0fc84c84700bc7528a23e11d7a0e7dfddfcca5c142792bd8d1ee0a8d66b8120c3ae9f558c12a47b	Socio508@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	52942247370706692510371304311101515687	Rafael Eduardo	Rodriguez Santamaria	508	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826199
539	Socio 509	a565f492aac02132df777114aaf7d192987f29524df8af8577e4fcde47a20d7e12138d3c46d8ff6b99b068947efa4c101092fd8810db59ba070309ca09c334ba	Socio509@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	331229749091792286424522864510529682127	Carlos Antonio	Jimenes Burgos	509	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824825
541	Socio 511	d1fe8c46a44d0f0c2069a5986b4183e08f625952dcac561143ca0171302741113f1864c2d63ec76a32657ab4ca590ac9d25779d87905b349ccfd8e3f987b21aa	Socio511@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	69801942298724690669796155107928305805	Jose Alfonso	Duran	511	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824886
544	Socio 514	c04e41c84f56d47a3691409835f19f0e59ba8ef634781afaf32adf940cb1248bf0a6a4d413f47be9a589c9b123a0a5ab5e32a69865095896941219a3877027bf	Socio514@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	17112682076123239392445583393234090414	Rene	Rodriguez	514	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	1
545	Socio 515	2370a215bb17471280d01d032e94eebee16fc84f0b3cfa94a9b3ea7618596340e0f082acf952bd917a7a7dfe5e02f4afd20bcec537e4a7eaaf5ebb788d4c8226	Socio515@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	225698362894015215054295093500008200298	Alexia Beatriz	Argueta De Rodriguez	515	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825887
546	Socio 516	ac184b3170485422f446a831521a6e1d115cf55fe7d274f7c59bc51341ce20bea7c803cb852070af1b61b75bc8c0c95d0499290d9f8c98ebb7a04645b8328499	Socio516@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	158959626809255844097091675127573847989	Dolores	Canjura Alas	516	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	20	\N	21943
566	Socio 536	330edcb850ea790ed22525f4c7930fbbbd3aecc8e220bf955328a8397524afd8852a1536c171291ee311ce1319c579fceb9f3e0a3f295dff198873a7c593cb81	Socio536@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	170628485292998428417951628247517792134	Manuel Antonio	Regalado	536	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823364
567	Socio 537	6d18824aae8ee59ee2ca67fff6f1b1090cc06a9139319a0878aa0b9c45447effec209930bfc39b5ebadadd9e12847e24691a74226b94784a3db78a739feb885f	Socio537@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	178269779200949404860922986898090222130	Feliciano	Pascasio	537	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823865
568	Socio 538	89c3871dc2e449c880a455b489d59b0703b5553ff442039fa3f118c4504c2ed59aaca7819f793c4218584a8369d46eb548d7b6af020ba497a50a8574340f5626	Socio538@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	259687706317915306089112764612173954612	Maria Luz	Avelar	538	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824119
569	Socio 539	55955d0d930178c86bd552608c9d2e0856a4bbfa415be035648c24b34909be51ff2edf0d66b45acfad803c5bdecf9da1cfde0c2174ec63b63e5aaee3f62a8cf1	Socio539@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	23614449259467409836424584869142854485	Maria Del Rosario	Menjivar L.	539	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823159
570	Socio 540	179686e454d207799310bac93ec466f5955efce82a4f6d03dc7447e7c444f4c8ebb25c5403a797ba2bc3fa120e6870d2b1350a6556f273e8c714cfb0aaa1d9e9	Socio540@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	270611690203364520673882143671879547212	Santamaria Delmy	Perez	540	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824248
571	Socio 541	41425edd7d7177e2c16d719f5a4b3f40bd668384b67fbf3c256d74f391074ee86700a71a9f4b6e02070bfbf91a0c2e05559e029e46e025ae6da01181f44634f9	Socio541@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	319941417427459284843647538868889237993	Jose Armando	Orellana	541	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075990
572	Socio 542	e9024bfe343093056c45a9a6cab81fdc6817133c8eac8bee08502630f1cef9ff028f7c1ea33d4a337a56acf4202c5254bbdca49d75db1f0f4a6fe6437657b758	Socio542@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	194794730481195794286219331303501482906	Reynaldo Baltazar	Ardon Casco	542	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144874
574	Socio 544	994fa3ba861531fadecdb17f2e2b57fa3187234af49347873cd08cb1636db0104422394f4f24dc117fca000cd3fe93e491a54941f22c38d0495c1d329659b675	Socio544@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	226046361778018675124071084437990170712	Isidro De Jose	Alas	544	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823407
575	Socio 545	ea159d2a38f038f8973231a92bd194898fcd46407be417743521af22e554eab31e0cf224d26acac8f0c295370e22f4cfd63c6bb77bcc6ab5b4220c26600476bb	Socio545@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	93176562684580933785739037219194346282	Natividad	Mercedes Olmedo	545	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823583
576	Socio 546	00ea5f73e33049ae5808ff9f594ed6d5c871fced52e1650ad302c19b466affc869a964ad2a12ea660e864030263ca3d8114492464bff6ec984901a71f3a66ee6	Socio546@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	54230726171666978481100392200038725470	Cecilio	Diaz Martinez	546	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824628
577	Socio 547	3ab203ac0f1d89ed146594276f9b89a0fe13797d879bb8a902ce55673321647095a33521adcc3538cee5038a4ef3c5a6895b3f68c7b5b8e1e8e13af2145a7855	Socio547@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	315867870692261849277177329120508455206	Jose Rutilio	Franco Lara	547	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2826844
578	Socio 548	7b70cc6dbb9e28152eb58c284b115aa9324b65b9435f749d334434cfbda90f037407711ca341eff5b88f29bfad5e9e0ab2d42594996585bd95aa9bb2b725a0fc	Socio548@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	247917791887703424612032536100389805595	Jobita	Avelar Alas	548	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	22207
591	Socio 561	b8c23ac30f759767358623e429d2fd0842bb8490a9cf741407143196827ad26fa5f431a033540f63ab32cfdf45499299f06991dd9d00e22618735f06b671ce2c	Socio561@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	312295953451760434672889334638649880358	Juana	Alas De Pascacio	561	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824999
592	Socio 562	b521f683c6f12d735bd7318742a81c671bd5e0eddd63b85bf0c0febc0da49e90e5a4b7d93330186fdef355bc0bcb7cb28eab62f2fd0d4611b6c98890a1f90cf2	Socio562@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	106221119154670057328440978356511021995	Juana	Alas De Pascacio	562	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823280
593	Socio 563	4ae939415ea696ca2838584b1dbcc6381e719c15f871e4a5cf221a95341cff4316cd9bf9195467a9db0bd6c8b490664bb9b7a7d831b7585608b924112112c4ff	Socio563@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	218192629150744007487002225075725873257	Mauricio Antonio	Escobar Trejo	563	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2523541
594	Socio 564	cf348eeef879463d4721beeaa99bcffbc373405d6812029542216214689bf26a0264f773d275c84e1f44b7b541df8b198fa0a195f3052705824107b9b89efb26	Socio564@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	231441326547387371799425774408089142173	Manuel Antonio	Escobar Caceres	564	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823774
596	Socio 566	13fe60fce06fa10d917f22d525e23f46c455aab7baa3ffb165895453dac3a7dc7827a575462ec74cfa3e6ebf2b67fd1abef861d8a3dd9262e3c489cc1097ffa4	Socio566@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	130855003328280058932619154136878152290	Alonso Ernesto	Olmedo	566	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	16375
597	Socio 567	af461c7204a2231c39553b702e34a9b0aaebf4ed73726804fa42d118e7c00bbab20b162ab3369574a501f005364e9a04256ac066922857b4ee3e46eab4bce58a	Socio567@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	227789952903245718612583244588839541626	Jesus Pastor	Figueroa	567	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2526767
598	Socio 568	70e5e373d2c86a033e45bab1aabd13f90161b3744d04408cb6e675aa8a8d30a26031cb38461d79b715618a481c01027e8e0519eed59f75cb19b24726e85a9817	Socio568@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	271781508396761605840331836977530621584	Samuel Edgardo	Escobar	568	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	16352
599	Socio 569	fc2c357a9b9441a01b9c1c82da1f0afaa5ae9f6576a71040241e413863d2aaec7a20dd85ffb219e58da892119ee0143e92e32628ffedf0e517ee86fb42b1914f	Socio569@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	38763444513967805178795813664951383900	Jose Oscar	Molina Miranda	569	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823284
601	Socio 571	3e21b29eda15cd42f836a07161b650e7fe9e01fe156478fa5c31148f115d77b923191d88a31712b53c26b194fc89338e885b57a9bf72987aafb06aaa5ce2a3ed	Socio571@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	65848315742321993587226805781397013776	Francisca	Landaverde Deras	571	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2827125
602	Socio 572	17a3645117e78bce170e778fe9e7db294ae59d57b1ca5bcaefc3aeae7925725cbbcde9f77c737556ee15d371deee5b877de71fdf013ac58ac5e9ca9de4938bfa	Socio572@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	125700428923313274330376806338738302102	Juan Francisco	Alfaro Turcio	572	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144885
603	Socio 573	7803422f1bf8bc5e292c96119f8708b1b99f2fafd4599e14554cf6c022f5c84200e1c78d83756adbaed7d4d6a01b345b8737c163ed296885b9eacb018d51b165	Socio573@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	225347986593961748291977025874838550806	Juana	Alas De Pascacio	573	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824576
604	Socio 574	54ba85c4853c4e44041db38a16eb5b8d9b4f7a5265be760c3bd00b2faa4f999d886170907d335fb64c790ef73507d4c3c0eee868b1a53a674c0f4e1a50d95057	Socio574@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	216543581372725954060709763386509769614	Feliciano	Pascacio	574	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823809
605	Socio 575	682a28bb39df84d1666b6984520fa0832c7f9a66efb2c0c5abdc19db4b4ee332d93645dd25dbb2079f87687307fe282240d7b5426328ad51ade63f2640e30c70	Socio575@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	268388898223749568301144261350377803175	Rosa Eduvina	Santos De Moya	575	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144920
606	Socio 576	2ec1d563246a24257f98866797059dd441dc0f0db701b89e3d36595e1f5503d7550ac854aa7a102eb3dd3e6e114d6b117e70f49eef8dbee10259a26a2d8a95bd	Socio576@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	64421809980693034974646915498777722376	Alejandro Candelario	Landaverde	576	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2826797
607	Socio 577	36093cc1088aec3c5cc2dbd4281ed6814ffafd918d607032c41727ae4fcc298df22752f53e8c7b8e1a82f569aea7355be247dbef0e8502533b82861086f92a11	Socio577@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	326187661809765048825847458027586182539	Virginia	Ortiz Lopez	577	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824030
608	Socio 578	c4ee2dcca105ad787103ca132e526685789baf098a04b31a91a5e57c5997c7ac67a95a3c41ef3df60283f90892e7a9e67747c57c91fbedf822aa23cb95b21900	Socio578@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	38827578469906193186843976909035351579	Lucia De Jesus	Ortiz	578	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	053285
609	Socio 579	f5ca4a1efae8a0394fbe533f09098855e47606736a1cee1e7c01d80731a44de4e96dbf9b3b74a0a6dc65568c741ade69f74b916cd46f322a2655d7fcbf612418	Socio579@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	112440270503608061389427681298056729448	Luis Francisco	Ortiz Soriano	579	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824151
610	Socio 580	52fba7854a0c312cf93f280e67d2ef477d5d91a787c87dd87e0268f59db04156f742a26417c2bed09890340bc987dd3252fe7bf2bfa0c5d249976e76d24b4b64	Socio580@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	233949892128321266374413152560454015124	Jose Saul	Pereira Alfaro	580	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	15375
614	Socio 584	001b9cdb8f5e438ac23cadd65b1df7f5c4171b7b83fb3017e6204907e112c641384b27aa98dbbb4eeafabdd42fb11fbdce03d76d4ac88676415221d7169f6b70	Socio584@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	34785647550642642259418810088559443959	Maria Angelica	Hernandez	584	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823302
615	Socio 585	2518dba706a30d65fa6d99c7117a913cbf1d48efa93eb9de3da5077cf749c5628e5d05a343735d8a56ad90aeaa8101d2f2d4f8ae5a397b785c0b06214d6ef52f	Socio585@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	21806199901066452204348991644196380284	Noel	Lopez Recinos	585	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823650
616	Socio 586	562fbe80b0a016f8928b3504cad92cd4edee5606824d7ada38562ae3f29ac238e2bcb114fa5273d3463813c0f8f77855f90d83b0a7681c5a6e1464277f51a327	Socio586@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	128498729791896580069158088108035422442	Cirilo	Recinos	586	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823780
617	Socio 587	88142c79366444c60a907b085934423382f715e499a6c0c6a3da7c845a2977a9dc2b0d49dafbccf698b4aa055edde3251bf16d11ce83cf8ab189c8ba96c8b9ee	Socio587@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	170192894579469022447078192476767546119	Hector Manuel	Vasquez Rodriguez	587	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2827080
618	Socio 588	47086cdf9b7c7242ce0d67fed5134f461e1ab0a649ef44de5c3960b7e676c5e46b1b7e48b855b44e502f808c00b3679155e52a009c65c8c15680a9746ad54ab0	Socio588@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	44732852896769848134376998051074823209	Oscar Antonio	Sandoval Alfaro	588	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144879
619	Socio 589	c50b53fbe074e10141e74cb19cde87a8c4df21bdde5ae740b405a00322264d58f6d3227457b712103297d60d71bffabe318b4d2fe909af645880fbb5905b1d26	Socio589@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	306975013885548073324748528917202907616	Jose Antonio	Morales	589	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823168
621	Socio 591	d3cb492a071a2e859dd7c12138863e0b45ddd30c2925e82e5d4186a4267d34561ec41e544e0241e9a67ab5fece4320bb8c456e6b4b7840dea32403004db2d034	Socio591@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	225952032945498639621400414800922801817	Filiberta	Perez Mancia	591	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823814
624	Socio 594	2fc14a58d338c263143903f8c154debd9ffecbf372348fe0e8ab5ff4a4437f008020490a54fe43d9c373145fa22a5746ccbec86e5db56924ac0a1bcadefb5797	Socio594@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	199935685631461306249458091386374391849	Domingo	Torres	594	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2826406
625	Socio 595	194ab06436ae7027bceb42f2c6ef085e335cb46e448a5ec2a16645eba90c1f64f8753d382a895880b1260f1dd7dfe1ccc1454710b7d1db53bf50b1f97149127f	Socio595@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	276134208507859407573285768228455494019	Angel De Jesus	Garcia	595	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823901
626	Socio 596	ae587001f59b45fb37c50cb5db275e264a89e7a27782b97fa3148bdc35fa75fe73ce7c9c7c0f40723b699fdb6f111112bf6fbe3d2edf76bd83b3c59ea67c751b	Socio596@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	281860144380466625256331181365768822744	Francisco Antonio	Franco Lara	596	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823266
629	Socio 599	22b9744d5137a4e01ac3182586b22431cc18c1bbf2ac9bc11cb165e28e54ae2ecbf61b8ebf181c7f2b9b7e5bc3bc247e4a884006d8927a46feced27dbc876896	Socio599@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	250715988225177605093716440758286364799	Juan De Dolores	Landaverde Quintanilla	599	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823423
630	Socio 600	4fe1ad24d9154c7181b4c051e37eab78d702ab351729f8f6b7c9bfce963a91b96830428a91bcca03688e74f8307b23b5e025fb0a977f2c77954d5b7981bc3e18	Socio600@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	262076982885419401580635064875932228872	Daniel Antonio	Gonzalez	600	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2825001
631	Socio 601	cd83775fd78aa45a91d4ae5e80b2e1dea7f9b1b4ee8989ea2d2b6ec407380b13027598033f903c411d62f3c551ed87f040f5f9950197bebe2e259171b8022a1c	Socio601@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	113678331418688864576360447493651057435	Osmaro	Arteaga Menjivar	601	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824096
632	Socio 602	d15bf31b927b6864b2c650461944df045aa7506363f33b4d18300ece4d14c1e4c9a26c13f973a967e98299e07d0c45df77d6a5470c431958e969e6380f851fdf	Socio602@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	14616038694143979319683637561007606148	Reymundo	Gonzalez	602	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823803
633	Socio 603	3cfddca70663dee59fa3dfd1743222b638694949e2929ef9bcf11914da37b005aac07ef1dd188eccc441eeb1e0b0028c2978e6e9070932c1fdf4796af3f4619d	Socio603@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	77895732895166243301316040943807088833	Candelaria	Alfaro	603	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824179
634	Socio 604	11b2365ebe2110e57d2b009e3e9ae9eeef6289f33d66323d1b9746e34898b0fe40dfa0c9481faad8cfc1d849f0a80c5d1ab277ae1495ca0b3c3a751740784c01	Socio604@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	63959377503988091142858593618876892641	Silvia Nativida	Gonzalez Olmedo	604	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	16498
635	Socio 605	5428c711065d3d0c3de678c61bfa49f662cbd1c34fde5a8b7e5af2cf9564fa4707a3d0e936b81eee5a76eed1327c6b147fd8e00443e03437f873643f21ba95a7	Socio605@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	55036083197155671682948477381458553892	Habraham	Galdamez	605	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824364
637	Socio 607	201addea34da9af473a0abfce0c044f503c723fd3079959387212cfc6d7352f9f1d0473e7d63508e6bd7461b07dfa879568bd7f2d5d6e3f26c2d93eb1de7995e	Socio607@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	31674989693345610864406200567088080745	Margarita Antonia	Menjivar	607	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	22198
638	Socio 608	71a0829ff5d496b6e5faf57d9be3a8b7e7ba6ae7d4f7126b879903be5967d5990a809ef426422020622bb010caf7649c9c972b43d285b037d76701a926961f3b	Socio608@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	269969548600215810943739967185235503692	Carmen	Hernandez	608	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823325
639	Socio 609	82ff3d3ada339d53820fe6f9c515151e4ec8fc44a1adf5d82ffa5347cc12c636309370341b2951da233461c0f5f65f7d0e9ea84841eb12b42f942546c5de2aa4	Socio609@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	175999727792197433443455109656660777823	Santos Omar	Hernandez Menjivar	609	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	159442
640	Socio 610	49405148070be6c1155d5d12b55c864f1354dd35bc1e642ea154ed50235491ea14411c7d4e2f9cb733533ede7c75e7c95a180c30f83bdf89ffa5ddcafc956bee	Socio610@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	88372072146307988607363203503030656776	Ana Maria	Menjivar	610	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	053268
641	Socio 611	14f63e33ca58097f2362f710a4cd3e1c7771fb818b0078ea92c731a7a58475aa03778f672e2d13e97041db1d45d8d91fa8a535ed6298b1abea7b0e7392579c26	Socio611@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	268548809567199181758235643143258260616	Rafael Antonio	Lara	611	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824088
655	Socio 625	91e8666c8901e12440a7e34555b9da06feca8f95107732baa43a42c23931ec2ca0f16b4dd8be8d79ca4b4038c78e4bf1271927b71ca9f367a9ef9a77033c1fd6	Socio625@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	4903786207727761948553999552474274292	Ariel Amilcar	Caceres Morales	625	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	16377
656	Socio 626	270d9de98b071adc7a0c817aea017ac37ee7fde56cd80e8a344d681140a69d469b62e3aefdb1e5e2c2a5fcfd20e0d9d67adf9f471045864e522ab97831f7ada4	Socio626@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	181415808678937179528798325882652774061	Alexander Antonio	Aleman Alvarenga	626	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	16362
657	Socio 627	e7213767fb832bbebad68a16f537a7c2953c885b613f394a7bd8c8331b5fb339ab24d5a99af9feb61b95278bd1d3cc0ca44853c296161f1ac39c3f4e653a16e4	Socio627@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	270894117259287990473096884409653002876	Sandra Patricia	Garcia Montoya	627	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	17	\N	1207091
658	Socio 628	0441f0ce41ea30a41ce0c2b9a4b599277a2187dd511f510cb5a31df5a0b93754dd3f408a5cc7c765018225aaffce68c11f20023383f7c93397f66091c09cfde8	Socio628@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	284863756114543686572371596209547062331	Jesus	Rivera Orellana	628	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825078
660	Socio 630	ea2f2fffdb49908384fa49c7a0a089cbcec02b769ee599dc06daa8848e217993601e52583ba22f10abd96bfe4f318e9e4bdcb43d0af87150cad4676d968dc3e0	Socio630@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	207948014677964970371752792529231591322	Claudia Angelica	Vasquez Rodriguez	630	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135067
661	Socio 631	2d69b48082a2ab45683d35184fdd577af6c4752865d24e79c98b23865256e095923ced7a8ca315c8ba97f81761359c8ef98a3e07046481878bc35a1e1aeadf94	Socio631@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	326748881798430652428298338136647355668	Mauricio Antonio	Landaverde Leiva	631	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135061
662	Socio 632	c3d438c4e07894bc29e8b6631924c7c4e7cf0aa2a430aba9cab4d27b939c7ca79a090a0384c68f48a67cfd6dc11ce677e1992a1a52e410b85ba623085b0d3602	Socio632@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	204038619415616075960075586183914274494	Neson Efrain	Cabrera Garcia	632	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	13564
663	Socio 633	a428df2146f49f7e899c11390de86dbb92dd819e27a89c571929cc0c7b4a2ac745ff7b1b20072dc5cee601d014feff79b4c1e26d1bc9832b3d6d10bc4dc9864a	Socio633@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	165232944871815811964204766610662475089	Carmen	Garcia Alas	633	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	076093
664	Socio 634	d4fbbdf083fe808af11a4827926c236b792cf476ed2e604df8b441e1e11b7d3f38425b834f09aecdc3061eb6a37d0f776a3e22f2d766e55116561d69537d7596	Socio634@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	62085519717139020265152250209094829144	Lourdes Del Carmen	Castellanos Zepeda	634	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135068
665	Socio 635	2e4860c68e300394b26762fbe2ce8629d74fae3e8f5fb372721ff0473fc1926ca70fa292ae5fa28b99996ef8f9c5f00373a09f0c3c77b8b59da153c66cb6d1f1	Socio635@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	257069368447941708855762217143393927224	Cruz Yoalnda	Franco	635	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	052840
666	Socio 636	8df8bb8cb4c2c5920554169b879c99b64f1313253e322aa53812880bf5078c5a86bce386bb023f46c1a3465052ebeee892d1e82d098900b184271447ba854d51	Socio636@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	203996109198711646570326117032604698275	Neftali	Sandoval Morales	636	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135066
667	Socio 637	201cc8a9d1c76645ddeda03f1db402a777b4b6871164997069b9ec41c247199e138f4f1e56b1a5d8379ec693fb30f53e7f284dfb8e317d10e3ce04957d68a9df	Socio637@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	96919326806549416366445777509193858941	Asoc. De Desarrollo Comunal	Valle Verde	637	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135100
668	Socio 638	60dc0e415d362480eb978f37857c75537d84277a463584fbc1aec97587c530efcfb70dc6cb4075307df6580d714eed87f19aae7fc4cf59373bcb98acb24dc328	Socio638@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	335149732413197527286817517785195919473	Virginia Lucia	Escobar Rivas	638	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135054
669	Socio 639	97b3a8139808a354678c103ff7806d773ec8f0d25f37bbcbfe300f22bab05a507612d5f05d1282b295a5daf2919f0af2f466e95439717a5e17fc079f69603612	Socio639@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	277833680675914181222950191259442358373	Lil Marleni	Vasquez Rivera	639	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	20	\N	135065
670	Socio 640	a97e32ca63ed6e1819e7f0822eb2c6af9f09646b31fddd4401b6d92b67ff7123f6d90856696483e98dfc56f5a6070f3e601235d910da53c0c1c587b2aa311850	Socio640@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	292033147191109367134154308889101254384	Jose Emilio	Gurdado Marquez	640	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	20	\N	135055
671	Socio 641	da51e91876c3b0f144030684477f7ee52112380d2c71122d535d32c9b0996faf083eed7124df6f285cb0244c6a7a44df6961faedec09246a9aa08a994fb1e09e	Socio641@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	263034991027946370319057250977852985380	Wilfredo Antonio	Molina Alvarenga	641	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	135059
673	Socio 643	c56578ea1be9e5559d5b2651f65ace55d24a0107da9169b88d77870178e244d192168e93aced139462e0e0a1b97d489cd6db29c775bd4723a0309e1ee73ddf04	Socio643@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	248349470640730663459821667494928313967	Jose Antonio	Gonzalez	643	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075979
674	Socio 644	db87808fe6d827672a47b4eb508481ac09c12fd058129061d4827a81a6fa2a999e8d25c188f18f5fb52e37febc31bf519e540068fec5ee7e9f26e1e9c106909b	Socio644@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	305262717093677328601967322229115378498	Jose Roberto	Extrada Avelar	644	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075981
677	Socio 647	0314ceb50ff323622bc7ba263f8539d887e37f7c80eedda03931fd62632357336f5f47b087eb001986659fa13dad1026fbb3d6748fbcc94fd510ac7e4e31618c	Socio647@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	96667589356404882313749159151560242682	Juan Antonio	Sandoval Morales	647	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075993
678	Socio 648	30aeff7264e5058c752a4dfc369d3b8410f4ae3e226c459ab25e10d42037426636976e42d3fafc3b704db2bf2bc8a192f7cad5511e56dd7ded2918ab711d28d4	Socio648@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	185713941694558897053869570693428485957	Santos	Maximiliano	648	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075977
679	Socio 649	f0175a853ce9e3d5a6658c78288e420852ade9468c8871bcc7bd7e74a599ff8ff2b2b217c18a565cb6024ea0fc67781ac40e991df415ebdc29c9bc5a3fa30fe6	Socio649@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	192424361474313303547570434880919512680	El Sitio Zapotal (Cancha)	Adesco.	649	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	12075989
680	Socio 650	f490725cc69c24ca69cb9eb6e5dea1c6e5cc3362dd329aaee490f520217632067e82556bfde09574ccbd9a4be2b397312cf7d469d5229e98cf6dd2212accb544	Socio650@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	279653507943806256695418634450796594760	Juan Carlos	Rodriguez Ventura	650	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	23	\N	12-075987
681	Socio 651	b6c6f33c3d781dcc15932abd41c10024f86f47fbf7d035f24074ba2fd0cb471f28141cf605ad762ee9de8e115d0b49e206e00366b4fd8deb191594a823e4db12	Socio651@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	18726404411406889157461624013367223979	Jaime De Jesus	Alvarenga	651	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	20	\N	053827
682	Socio 652	750019756cad15be519d7494647fa21c4dda1054dd787a35fa25b59db48ac9a22fd10cc5784393135398913b5a1dd449402f194e7dc84a83c843664c5a37ad0c	Socio652@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	326798781374609232138212424008399366721	Efrain De Jesus	Barrera Serrano	652	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	20	\N	053816
683	Socio 653	3b3f0c45f0c0dc7b5ead6ce6d4b235af4ac20bbdfb37d4bcd2c1c4b694aba6c08beff887ddbe643e1792c48545c83f61a5cce8f7ee430f02cafa0ccc4553b2dc	Socio653@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	105217111393500546469365544856143972978	Mateo Antonio	Menjivar Ventura	653	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	17	\N	22199
684	Socio 654	00e6fb618645daf28d0c9790fc28539b5bed399fd5eb9aab85837506ae102277745133cc78b19321435c59955bd90b33f7e662387c03109c2968990cb31f75c7	Socio654@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	129571685847262815605053986576516823992	Agustin Antonio	Santamaria Barrera	654	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	053258
686	Socio 656	7e52db1d2c8dd1d7de73b424ef94f66c8d67a78b63931fc7174e7c8bbfc037a13a72bce2d0fcedc80cc6dab635e3008110dc7184d1d560e5eecc63c67bc8732f	Socio656@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	242034351711742223693672108086906721712	Vicente Arturo	Lopez	656	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	052847
688	Socio 658	066bc972c7848ae6458d667e9d1a3ecf7e0ffcd0817be7eb1a0f953eaaedac4371573dc1a8a192ce85c7b2eb20660444ffe430eb8cda0c8ab72635074824c341	Socio658@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	81024748492670901311878293141147013885	Jose Alberto	Mata Moran	658	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22200
689	Socio 659	a48c33486d70f66dfce89eeb202aeb3573bd3ba42efbbfac9843f9941aaf4300c4f454438a64e99ae0276b44f1ca840fab30625c98508a8d9f86ce160879d8df	Socio659@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	16777610869235229952911246375910852971	Santos	Mata Sandoval	659	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22185
690	Socio 660	85bd5442b80ebbec2309ebc987a39a61b5a32eb46557ad4045c649e379998dcd1a7cdbfe85a33ac02118a1c38c7a0c8128bea6ca2201957462908f3a21fed6dd	Socio660@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	144505765120700720378857590870060302479	Beatriz Arely	Lopez Alas	660	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	21940
692	Socio 662	a7c47f4e5c7265128af90a38cc9dba5661a6fb0c5114cad714594e18b2a5400a8a3e8ddae782602be3f1e4ecc97cb2604e58b5fd9e684a01cbc3f550b913d7cb	Socio662@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	29302774604210735314368010025184313156	Deysi Guadalupe	Cabrera Valencia	662	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	051909
693	Socio 663	db4651e3bb6925d39003a7aba662a49acf60bdc001eb7874da72c1c5f35b994dc3b099496a061417b4cd164ebca247c88179719392433014290475276148881b	Socio663@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	178849463993891386696994135286958824294	Rosa Miriam Del Carmen	Sandoval Moran	663	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22197
694	Socio 664	7ec9b567b7dd3397b137972bd434d7f3e1ab6a2dfff8518588469f9174fa74bb7cd8ebaefe7820a93c891eec3aac9bf5a3676af8e4235db6a44653bcaf2664a7	Socio664@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	250752556384598894234456466983131054323	Hector Antonio	Aguilar Cartagena	664	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22194
695	Socio 665	921dea5eaaa2ff61b5d54ef62d40af05b21ba1a9c6672b53a8085676c3ddc2136119d5f6136c3fdd702cad306804f549a6542e7e1fb881792cc580ab1060bd83	Socio665@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	17366063841924419622585010132184175462	Mirian	Palacio Lopez	665	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22186
696	Socio 666	cd1e01afdbb0f485fc82dc23eb6d1b4bc6e259068b750d2ae9e0778e24632712e283a0bab507f68b4e43e5e9dc11ee50eeb49a87fedabf455f0663779756713d	Socio666@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	123082277025082169374551912956999788483	Veronica Maricela	Moran Mata	666	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22189
697	Socio 667	1ab00240c0730926889e0677eb72d45af87d0efc2412c836c9fd1882132db6e2869b5c547a1214ebe322008a4fafcd0ca13ca817723fe17f06b309312e8e4aad	Socio667@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	117313244533703487318109901442592926743	Gregorio Oscar	Barrera Santamaria	667	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	053269
698	Socio 668	14fd4683a92e203c87fd32629e31dccf358478726ac92bcb0e726827e3d0ff248c88c6ea406e93043913775135f0e4abbb41b3094f12a2c404dde3eb8cb6cbf7	Socio668@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	201877279412785988987237603069666622650	Juan Carlos	Santamaria Barrera	668	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	22196
700	Socio 670	ecb1a3a24c17e049dfc578dd571019156dbe943e6b9e1c477ce584be9383c5880f92d09cbc3623625a88cdd57daa3df70f4fd2b61b9f8116f5bd70ca2cc67e08	Socio670@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	100928872270277911642876205568687040651	Nela Antonia	Ortiz Lopez	670	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	21931
701	Socio 671	c5260b5c14054b35d1d5b48cc500cb6cabaaf13ac552b8f2cdac8b42d2da1386878c0563ce331fc7f934d9b15f9cc02c66071804c7d12aa1b65e7fa3005768a6	Socio671@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	258641430540245807187784366301126115911	Alba Margarita	Cabrerar Hernandez	671	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	21929
702	Socio 672	bd5c48abf5e49527fa508b8dc0aefec506b5789164085fe675431ddbaa6d0916f224cbc921befd945e5f2239f512e9b08bc1ce3f05bd5a689b2109c706f3af13	Socio672@mail.net	Ingresado de bd de sistema heredado -- [suchi] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	168181990892439437119615718732488055674	Oscar Arnulfo	Galvez Orellana	672	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	21930
703	Socio 673	d0d6574bbc57ac99d50263f766424b28f7e190cb5040dc881eef065f98c6dcf646c7f33d1f830fe49b2a9821b972ac9f9ebdcb432b277898cccd5e0423a0863b	Socio673@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	231850237886226234105197023185615978487	Dolores Elizabeht	Mancia Ortiz	673	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	051908
704	Socio 674	8e469297a33d36ad2b3e9e5c2ea0af6cadc9bae8702544971204d7802dec9aeaf635b891fc97d8ffee32b4540ebc7a3f67e752ba580c72a5474a012e2e8bda7f	Socio674@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	265523394228426587478855481240484567421	Rosa Lidia	Erazo Valencia	674	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	052658
705	Socio 675	1e4aec34596c719d14331ae627f3a6b6b65e614980cb8e1d2c6fc4b93ed9462fa44c136ad14e3da193241b7e231e8082ef63a12d9f25c506e9c1b7810469027c	Socio675@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	314271798052314270964461172701139495697	Yamileht Del Carmen	Avelar Alas	675	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	051907
706	Socio 676	1068f07ae9cddc4cff315b8d74d2c754a24a715abda54778ad1c18a04882bf8f25d91c6096f99ba65a381f110dadc932fe1e5b1fbac69c3f0f759907230f693e	Socio676@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	48935043903016058607759041431363864198	Wendy Xiomara	Escobar Erazo	676	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	21932
28	Socio 3	df6df487b5b51877fa02be94e3a629dc9a88cad0fb6e8b4947189d858b388731fa7aa5a208126fc82a2b7e5e21fadedd2a721fd0d0869d105f4f181c9875cb5d	Socio3@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	306594072636502100527089763132284344019	Jorge Alberto	Casco	3	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
29	Socio 4	98d0e97771cf781b38a437faa58656acb03ac246ca0e915db0bf36ce759cb965851c1a9a8144f137501a647c76db731acd0acd87b2beaab4bf5d4b421e8cd065	Socio4@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:39	127.0.0.1	285470615801085783422791717096110427720	Jose Mauricio	Guzman Arias	4	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:39	<cuentas><anda>0000</anda></cuentas>	2	17	\N	0
4	tecnico@mail.com	7fc4739fabbdd912cad7c67dc96652f2fc44028fb35ff6e7b76450ff1d848a9ecd72b277bda5cbc8242d5019835278395a7e5505fbda62ad99bdb23f82578237	tecnico@mail.com	ninguno	2014-11-25 09:57:36	127.0.0.1	147696466216548575021795550455560405830	tecnico	acrasame	99999999	2014-07-30	13.9348379999999992	-89.0248990000000049	\N	3	2014-11-25 09:57:36	<cuentas><anda>0000</anda></cuentas>	1	8	\N	4
5	contabilidad@mail.com	04756535b5413f6d6d2a110196b7585581284cadb87bdeb07580fcc658af54777f01ae3546430de350fc6bb4df07dc63d5efa3191c6700e38fdd30db0b5f1796	contabilidad@mail.com	ninguno	2014-11-25 09:59:09	127.0.0.1	200960810456296495593447961494924475697	contabilidad	acrasame	99999999	2014-07-30	13.9348379999999992	-89.0248990000000049	\N	3	2014-11-25 09:59:09	<cuentas><anda>0000</anda></cuentas>	1	8	\N	5
6	directiva@mail.com	346dca801c85e9a34027428e42c0162a021d13c2db3560bf84e66ba88f0e144d763ffdebfcd7d0316ba9a05215f399430405517c8cc6a3ac747f6aecc5e27107	directiva@mail.com	ninguno	2014-11-25 10:01:26	127.0.0.1	110728886280568621789141001399083416491	directiva	acrasame	99999999	2014-07-30	13.9348379999999992	-89.0248990000000049	\N	3	2014-11-25 10:01:26	<cuentas><anda>0000</anda></cuentas>	1	8	\N	6
9	Eliseo 	0fdd4396fe4a7ce03d365372f995e25dcf6f6eabda5abb857dbbd5490b13d770ec5f33f54adaeb631fdb00f50e01dea98544581a70628c2599c82904b45020dc	acrasame_zp@hotmail.com		2014-12-08 11:24:16	127.0.0.1	69658587425938495397771206025326759830	JOSE ELISEO 	ZAMORA MENJIVAR 	79876583	\N	0	11111	\N	3	2014-12-08 11:24:16	<cuentas><anda>0000</anda></cuentas>	1	3	\N	9
3	administracion@mail.com	d2d0929226b1382ccd0b8bd7499b2a9ab8a1fadcc453d6ab26dc27e1e88b71576ad7843fd0ed421b8a17d2bc195853a302b8e241fc9f4c2201f040372de5839a	administracion@mail.com	ninguno	2014-11-25 09:52:58	127.0.0.1	276002987658665757195485346985704719560	x adcion	acrasame	99999999	2014-07-30	13.9348379999999992	-89.0248990000000049		3	2014-11-25 09:52:58	<cuentas><anda>0000</anda></cuentas>	1	8	\N	3
32	Socio 7	a0fc9ba376ebcb61f228d748f7b530c119ce4be7bfec03a0a32d044b98137cb04e05f643cd9f872a2e63b5b2d270a1401e8046b397c19d6ad799b1ceafaf7827	Socio7@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	24416618213679307342443223201047260472	Rafael	Montoya	7	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824397
33	Socio 8	1dbb9d6b87cfe05c18be7d5f924a7d535cba52ae5d7b389121b9a2ea6036c013a81e490f741ab731cda9d16f840bf0399d35766f1492fad06d08be4adbb16287	Socio8@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	289305480180983790608316141826741539971	Petronila Josefina	Menjivar	8	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	159443
38	Socio 13	e3acfdc5b122eaea9e8cbd507fdf83c9525b5371d34a0277b5a4c000ad587eb93261e515d7a81c7ce401fb41a2fa1c7e0d826c595ab5c74f6505fb7da45fac2f	Socio13@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	152829855239191404209251183665957064216	Jose Orlando	Montoya	13	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825408
39	Socio 14	d3a047b1b80e923e3dfba4e380798b729fb991ab61d580de194bb7e63cb52f1ec37b768c4e1e4b1382675f2c1ad761ad660676d07bd1834d5006a9bb41dea9c9	Socio14@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	84800388569084571688273147183270565174	Pedro Rafael	Garcia	14	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2626236
40	Socio 15	6d24e859fd25bc235e17a2a57bd0514478941f748f5161becbd65c2df17bd37449b5c0165e3e5a8388a099ec2b2d88d9dbd403e0d33d5966421448928abe2d05	Socio15@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	336354043274900587868320898259619649723	Maria Carmen	Menjivar De Garcia	15	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823838
41	Socio 16	3eb12baf4dcd00be5254788b30c0327777a0e982ba9fe6acd53ecdff7718d7ed53d0cfa3e3af0f6bb45861970476ec42819af6d6dc440a67b8f4a65f698f8bda	Socio16@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	1180172972429596075340301381248536657	Gilberto	Landaverde Alas	16	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824574
62	Socio 37	497e0021965801db69560e8441528ee45dff465a0a12eed63b9c3c6e833f9c1b8ce1cc0cf4f22d3a844d4a09ef10a9309f6bfd9f38a233e896cada5d292292de	Socio37@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	161300921753605855817351207600753862879	Francisco	Landaverde Artiga	37	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826623
63	Socio 38	81c7c6d618fb2dac0cba6971d7b6d6c8faf88992069605572e6df41d0ddde3139d6a0d21c35740fdf5a1e40cfcc38fc1bd8e92a01129d3fc2e104579aa78e8ac	Socio38@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:40	127.0.0.1	224846401942869405605876451813246843678	Jose Angel	Serrano	38	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:40	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823830
78	Socio 53	e1b7f29e0aa7cf954b3568159a4d0cba45f2eaa0c7b3f2d469d27ddd2b5197047e7e6c80a8e4184b3a540ad0b53ee3558ba55c959161137dc26d8b2f2cae2f28	Socio53@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	24872416167940049152597299227702804330	Marta	Hernandez Sabina	53	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825746
79	Socio 54	ba540e2306a5bccce20afba5085f204dacf25c99c5c9b288b108a8381cbb5bfa87cda05bc3235f4e66cefa776208cf2c4f58e2bde7d4ea60a116675ff9116ae1	Socio54@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	179964332650609851155450476950580859182	Julio	Rivas Martinez	54	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824528
80	Socio 55	fe2b8e43808f1b121acaa140954a007669af5b0af1dc33ed38294c18813ac8543c815818cadd9b908fa50fecd152ec4da4e2e0693a7dabad3a50b465e47558ac	Socio55@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	155924236294437156394515559816682464513	Pascual	Orellana Chavez	55	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825078
82	Socio 57	2fdea6cdeffdad74054af33b886e8836f66dda86784e6f1d5023e5f9b9949e121031fea53f0cb37c5716064e98b448af5855bb8f148f5eaf55d58f06d999582f	Socio57@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	230189543915161115166937542115973651726	Morena	Alas	57	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	1
85	Socio 60	0fe4d18fe1da49dc328055045aab7d08508af127726296f20de48881917d314d85659ab496fe9613c790eef01eb3d08750e57b0077f87f8e0e536f5a57c92e9e	Socio60@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	144585928599907308449913182251570729446	Morena	Alas	60	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	164495
94	Socio 69	830433c142fb8b3492223e2b8a11a0214bffbd1c8748ada69d5bbf07cbe9f75674e503d690a78995cd1b2f07b713c35ccf72c3bb6e6ced6061e3ac855dc98512	Socio69@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	89646392727948732308113985572678268537	Raul	Alas Rodriguez	69	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825348
110	Socio 85	cf6eea6f808050483aa254ab1c1bbc665bd5974c26087d7751699e28bfc8212e8a49dc83f8d112577e4fd3cc0002e20f6d9deeafae6a0f195a42cae582658155	Socio85@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:41	127.0.0.1	97999642316146385716898755194180122331	Braulio Antonio	Tobar	85	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:41	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824125
128	Socio 103	a00301d0a12990911bb578f3d07834325ba322e2704b9bcca07e4751ea8053169cd5a74333e8be4f265c9691c802244da9ead939dcaa8ff856b49c52f1ea894b	Socio103@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	339434439390991692835812950909447535034	Evaristo	Nuðez Ramos	103	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826937
130	Socio 105	6879414aade2f2868ccdc9b9372526a155de01713db5dd9a4ccfb2acf64ecacead584a6234d2d26ffe1d916624cda7b9af541f3ff53214997bfa9ca9f9f48667	Socio105@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	50002798352988132027827710836562801985	Jose Antonio	Nuðez Calderon	105	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823866
131	Socio 106	8dfe274fa7bd01a7410e8b71056f9b22461fd122a715788f2681ac93736e8cf6293b6467ecb0017a21b05a0a216334bf3e06bc8dc4cb7545c6447bcc1ff4456c	Socio106@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	292356237530806376173794919731964522150	Luciano Apolinar	Nuðez Ramos	106	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825822
132	Socio 107	9acb1d37abd1349ba6e6c799e82ee526f546e2c84e6728747fd62a7bf7aeac6fc29906e31d944116118ac28b14f5001ca53d9315862e4dd097dfb0f24562f490	Socio107@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	74612251346800255680900325129651925070	Blanca Hilda	Montaya Landaverde	107	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	053829
137	Socio 112	36e478996e3fb7cc0c9f12d1007c3367c0030080cd0e76b12ac6c9c8ecdea7325665b35f17e2919ffcf68f57d950b0360497c9c0687289c5231d84e66361a4d1	Socio112@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	186970351504951392839107922096967941335	Isrrael	Guardado	112	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826052
138	Socio 113	acfd83b375956a97fe3220a661dd720a08cac8c9a54621dcd5c702938e388322967cc62d9d8c51186b6adbb8bdf4fa72cdaa45ce60a607445a0c989eb44bbe8c	Socio113@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	249925747894845156010289174730544821217	Teresa De Jesus	Landaverde	113	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825038
139	Socio 114	7474f71ccb4009da3e5596023a6cbb8087ea1d14b65f2a430147ad402e562e3f2587b7536e8c007cce478200774174005850b7aef51ed191dd01c27c7e13a263	Socio114@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	258120037825402626105933191388098536763	Luis Antonio	Landaverde	114	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823633
142	Socio 117	014a7b069f3bb2665b06624bb7b4d5abc63ce6c11a76385eb3b197476322a893b4db1ca30a2537eb81144cbeae9973133d093caa3a19321a748d95c7c2ef2e85	Socio117@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	150525275239761630763880581980817280958	Martir Secundino	Landaverde	117	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824600
143	Socio 118	6fb7562aaaa69f8f1627ad552d2e74bf906ec3736c4cbb1730f708c19942e8e8a98b4522a4227d51e9c8601c6414ad3e4512c3a5b3c5aca876104392735f9dd8	Socio118@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	123023540893775377323904890375006852640	Jose Alfredo	Garcia	118	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2827068
144	Socio 119	97fa33d9eccb43ef38d8b208e7a06816198b52a1d2039069779a828af1bbc21c690e3bb45fe07f5fae5a8a2fabba65832eeb0c4fdf29710a8016e49b2a7672ee	Socio119@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	202674905043714480174963801178998408890	Juan Carlos	Paiz Giron	119	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2823477
145	Socio 120	fb271ba1cf51351c7c0cbc1790116a809ffb908bc5655660ee0f30d47abec59f157a91112556a133dfdec64fb3a53be373770a048884747f553c52c4a2ef6642	Socio120@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	196904283936539667551281009173164199186	Jose Felix	Vasquez  Ulloa	120	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	22192
159	Socio 134	2ed744845bad124c37b3002ba359aa0783b7baefbbc9b3fc0a933fa49bb60c816ad548da2f7433c15fc2fc44f2d81bb23aca0d7c7c2cb0ff32c0e5d51775a0ec	Socio134@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	73322026319833014130435395447316411779	Jose Luis	Rivera	134	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16496
160	Socio 135	0fef241c23769cafe006660c35b3fa7f92898f37bc289869f19bf26d7fa844432c8a28fc8c4a109766b65b362ad89d20f8f92bdbee50221254941151271ab69f	Socio135@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	198461121464002322118604162323418038231	Saul	Pineda	135	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2825796
161	Socio 136	28a06fbeaa2ac07c7c6fcc94af0ab5be6b603f7bdb6d05bf2b1a34aacd890cefcccc8241801d59fd0491ffb9b1f286649f2be3bb3aef2529cd4b42de3aeb382d	Socio136@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	278043369262870807759709433126428220718	Carlos Antonio	Escobar	136	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2824691
162	Socio 137	88728fb7e364c21094898bb280601a084956657e6511b0dc259d684d0329c843814aec3c8760a6b2cc0d3cce8996bd2b73985f20f54af85d35e0df5914dc10af	Socio137@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	280906614609857511125969535172567944457	Ambrosia Del Armen	Galdamez	137	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	16366
165	Socio 140	b677e9c56704d700a21b225be883ffe974cad1e967f5553da79747d5eac1318ca3ccb48b04c5e1836f01e6a5eb57dabc8e0baa3d14b86c155199a8e4250bc935	Socio140@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	297450198630755931159451591182189837330	Jorge Alberto	Lopez Alas	140	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	17	\N	2826036
169	Socio 144	798bdc55a50f503b0cd1be60c8ed48c772b37ef892db22bd812faf32d7af370fa3c363acf2eaf2ff39d34935a22f0cb3dd3ae28f1b22cefe064660d92698dcfc	Socio144@mail.net	Ingresado de bd de sistema heredado -- [nuevorenacer] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:42	127.0.0.1	51447070412160474794317445538861462527	Ofelia Margarita	Garcia Lima	144	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:42	<cuentas><anda>0000</anda></cuentas>	1	18	\N	053282
206	Socio 181	aa296f1c72562ede7b2a35d1c6e84f48002c27ab59cc64a25ed076b8c8cb0214bf83bbee4eab3d4b9c6f923408757c0409b3ed75048135298cdd5c57af5fd1cf	Socio181@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	92836742448031258839687634691456721650	Santos Fidel	Barrera	181	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	1
207	Socio 182	12aa2a2d59f60c2114795b493621affd31d3010d534bcebf75601da1046c0b97e11665ae69d9a9e70fb7f66ccaf9b0ceb64a47313073a72a28f275834a55c1ab	Socio182@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	83626434342903337804233411809403708347	Jose Lorenzo	Henrriquez	182	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823223
223	Socio 198	25b366a9cac68aeb30fe9b53cded38ab30ac8b2f63ccd5808d77e3da1287c0d787214383f07c36908dcb483fb9bda40d49a4c9369928fba434ee5919a3a97131	Socio198@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	85971152068103498698229841222182097666	Luis Alonso	Guardado	198	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	135321
224	Socio 199	0fc165f756447e927477067b757826a6329cdd5db802c7572f9b7a7e23beeeaf8355ae6873dd28ad7151fc68aa32f9bd729ad648b1f28529141e1a9bd1796f4c	Socio199@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	34851335850318426016464750030088725619	Jose Mario	Guardado Henrriquez	199	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	12075980
226	Socio 201	27c4db5843bc08990dc43fe32d5851b2733f97a7f3f697fbc6d6763081974eecdf90ca0ecefb8e4fa558721ea82f7becb5607f12f3d930fefad0907510acdea9	Socio201@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	120011980383379893286656334537224041944	Maria Rudencinda	Mejia	201	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824255
238	Socio 213	639f8658702689e79618a00ebce4a102a2d88753cb8daf5fcb91b12f2c19bd8fdf2072f3b5a78bbd080f6ba46f2cdcd759dedb989c1e0dac6d0f250e0db29a0a	Socio213@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	126528863659923771790376631766818138260	Romana Marta	Hernandez	213	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824144
239	Socio 214	7e8079fa6b38243837124738abce6911398d9650023daf4d72b1a6ef9ee8b0c04fa9e271da40a1910167a9257a5b0d968d25a2774483f2a421ea58efc5cace8d	Socio214@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	194496339562359898301255171723409309995	Ana Miria	Vasquez Henrriquez	214	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824938
255	Socio 230	7ecd9d5c71f8998dc07dea6ac2c2864250629d4789850466c3adf0bac21b8b42d6a5bf47043330c3c1518ec213de2b21c157d3e9636db0fc9e22c85cf47975b1	Socio230@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:44	127.0.0.1	134013222772729701526365216547424213188	Francisco Osmaro	Vasquez	230	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:44	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824368
271	Socio 246	0bf22ae36080720b1d730b57328e53564ad881f8c9c111e7b6c14f69d2aededa23a1253a08c7aaadb34d98248cf03fae9c37d11e98c843157b337dc4e572caad	Socio246@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	171121067466519086008578088130068951202	San Antonio Del Onte	Iglsia Catolica Adesco.	246	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16356
272	Socio 247	e686369586a62b91667ca6d0d06805ea2c6a1b4813e96bf1ef06594000162fcb680a919888ffa0ebf2f498df595d3e91bd87c2b0a02670a4c16739b11c0a146f	Socio247@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	324533758439856794792179325937887342032	Candelaria	Lopez Sabina	247	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824953
273	Socio 248	e95e04c46513e44d7ef82aea3d2730bfe1b56b4104599efbaea3acfed7b959d5fbc30092c6df0918bbfd39e7e7ea4d00e47397c1efc98c414c37db4788dd60ce	Socio248@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	230435907394641365999353038746652191174	Fidel Alfonso	Herrera	248	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823796
286	Socio 261	522b7315bff2b228423bdc4146e075e8b2bf83e16df927bef54daa2019bbe502866ad9d7f72517cedf0a7a27824ebe8f29aafa0328a111d0ab3691d814b04423	Socio261@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	16590455107474594639997483345759970889	De Jesus	Mejia Profirio	261	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823994
287	Socio 262	fd7502e3144b8f0d90d9bfd441ae0596e0fb8061d39f988b89ca410fde1ef70fe5fc19eb77a95f4b4c19ce4fdf1e9e5d0c7524ecf81976e4c38d4f558ccd7a1b	Socio262@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	133180338583428397309149891439494847245	Leoncio	Garcia Martinez	262	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825144
288	Socio 263	740787b8810dc28aa42582528e7ba4f8f082126f5dc6e9701ed6a2da8dbb75dd59ab4559f262797424bebad707ad93c7939c86cee4f71e87ab6f16c52151c6e4	Socio263@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	142638890257608045332578406510118022549	Santiago De Jesus	Mancia Cornejo	263	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825217
289	Socio 264	9d85cd7d95a3745a48dd4df05b5272c0a3d1673fca826fce6df99d7321fc0beeb08ee86f1985db45066a4d31de0931461cefd7b6103673d5646cda35829ad97f	Socio264@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	279676476937465334850404796736746382935	Santiago Antonio	Mancia Montes	264	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825309
290	Socio 265	2e51114afdf22c9e4228f81b51c5e9fd2b86237f9fc19e84509d508167345324f18fb815ffc56d2edfa58c19c8f050eb1c2922c8e2a86bb8d5df7603b72bbcec	Socio265@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	86243396431470990879701222834873026533	German Luciano	Sanchez Navarro	265	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	144924
291	Socio 266	60166e01b81d88b1093523edc726c202a9d814528c7a316a813009f6ba0913b22d1a87daa5c9489ec5b0726ef7676a330a9fe3feb78c65a7b685a3ad658d4784	Socio266@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	19817098747743518204827237458721881730	Arely	Ceron Coreas	266	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826453
292	Socio 267	18f300b836316a42bb637678a6d70a84eb62260ce6116e8bd24fd18a55d7ee2b885e3386e5aabe772a83482241ecc12c1893580eec5e1dadf30e3723490c8c0c	Socio267@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	288961771661972713688204636948581226302	Dolores	Torres De Bonilla	267	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2826578
309	Socio 284	c2b522270f88995501dcb2b1d4d6dbd8b127ef3de9311a3e1eaf7353c6c11412a3e450dd107f8488f2b2829201a27b0969c1ddebbd08f88ff9fbf9790159233d	Socio284@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:45	127.0.0.1	39644883501456057602916378910785352443	Santiago	Diaz Villanueva	284	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:45	<cuentas><anda>0000</anda></cuentas>	1	20	\N	041298
310	Socio 285	1c83e51438526228c0d046b4caebd1fa482ec59b966259c7d4ad5b5bc88ea7db4d468acb0f2ea6bc3c8181b2425500fc2db4c9416e548f4249b487b0b0604414	Socio285@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	122008298744438939546373149181474034528	Luis Antonio	Mejia	285	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16365
311	Socio 286	c48c44f0f40eb860127c6bf5b3b17eef9b82fc04b5ea5edb9f1289f97744a9e5e8cb079f65ef59e3256441d9ae2b259b2197810df98a88288d33c2b3354fc5a7	Socio286@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	188831089709739233516736512345074760263	Berta	Diaz	286	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	16367
312	Socio 287	20a55830c10155e1636695ab8d2fcb80311b5469eb63530c96c5fd4910f9b783de0bba55d61678089a1d44ddaaa42ca7835235560444f9bdcd2c8c066e7ef627	Socio287@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	147825712355235807357136020386871330812	Maria	Felix	287	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2827135
313	Socio 288	819ebd7349a7ca5506c379bc40e2256313ded27572532f664918be1b8d4e4aef0258282c42a11faf8b98e4e1203cb91af6934471a5ca4492853976b5abf05482	Socio288@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	255139465144561671727956456943450741054	Pastor Antonio	Diaz	288	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825118
314	Socio 289	5f97263605e927fbe150039bec46319af74fd2ce65e204ce62dcbf38d79c04088be4744da7c854609afa2721bbf3ac5a824e2b08b952ff6c2b6db72c4d358c31	Socio289@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	191287726571304416586867438915894548981	Gilberto	Diaz	289	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824053
315	Socio 290	cd141012cbf5c3ca6959eb63d825505559239eae0c0a3dc26bd6f15fa1c8da88bcb562d41ad8c096c488dcf8f1679f33ad414b7ab21b1fcd2ff72af76f956b50	Socio290@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	16189320599616996111489302807290773737	Jose Luis	Juares	290	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823449
317	Socio 292	05201148eaf2f7eedafc7745565309fe4860eb436811c17b662eed545ef2091ed00355deccd8a0c2aa0dd9d0cb83d4602262512509b1767d5a57a9c44b6865aa	Socio292@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	61641175294549175658750173666504083418	Ruben	Guardado Guardado	292	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825585
318	Socio 293	4818000220d84446acf27833dc33130357343b406b6d827f2db1e3435884f55bbbd3c8ccf1b87625c6874e9fe4b675caa2d7ecb77e7fa5d9c884acfd2d02c5d8	Socio293@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	151126352060495414950505655259531322256	Elmer	Murillo	293	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2823680
334	Socio 309	03ff151c2ce4b372f6743f4b9a0b7a509e7ad02a12ba09eab50ec133ebce5c2ef7c554f4bcc59f6226c23778531cfa16b25f4a28ed8dc38c2fd77c67177039bc	Socio309@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	35932214369312127790350685788635301737	Andres	Escobar Escalante	309	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2824212
335	Socio 310	cf3391991c010a2c958d76898e2ffe70c9f7084983a237a5534c08270334fe9e7498257d2126130ae988157e349e93ff74b50f6ea0c55963eb56cfaa6bd7635b	Socio310@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	180728313859367191098426618355412297254	Vicente	Abrego Reyes	310	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825544
350	Socio 325	d8d8736160a642f98991d21013a355fa70274a561532a0b4584594f5dbe3433d54383ed12f8df535569a6c640b6433cbe1ba8c80ea21ba1f8803d3d29e194d14	Socio325@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	192794595070578240000436032195550006362	Felipe De Jesus	Garcia	325	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	2825380
351	Socio 326	24f4b803273eb92dc77fb94e841594decad18489a26d4830c938220288831735d4a4f569978beb58492f44c479ffda1167b2713808ffae10fca3598d469161b8	Socio326@mail.net	Ingresado de bd de sistema heredado -- [santafe] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:46	127.0.0.1	323501753901842291465418643857166050698	Nuðez Jose Ernesto	Nuðez	326	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:46	<cuentas><anda>0000</anda></cuentas>	1	20	\N	135060
415	Socio 389	26694ef2e847f1fc564ae0d874a3281d1f093ec6f8c256c1e8b5b4578a1583a046d2d4087610f1e3b586b1759a47720c23a484202098084a5d8d2677fa78379b	Socio389@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	288889025868998558735259826697079875977	Rosa Melia	Gonzalez	389	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053815
416	Socio 390	7f998d9ff3598d084db95e41ae4500eeaef146b6ba8722e346c9f2f4c455fea426dab95e4b5f0210d1714ec2a60a1f6f37073570beb252b496962b597b10ba15	Socio390@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	92192122213047625858776736772507116360	Heriberto	Lopez Mercado	390	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	22202
417	Socio 391	828d6fc3b2ddd1be02efe174b1e9601a0a7695cfc76b2a68c6ef1ae7adf8d0a971e4ef97811a3f0ffb1563d758e54d4e6e51ab3900558469f73e728f595c4df1	Socio391@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	156380550025596586106133488760431451651	Fredis	Ceron	391	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053884
418	Socio 392	0d1a920d3fada3b64ea8342d86edc05b648bf9b64126ebb71abb2fec323232bb872c5983ab7d326b8ae7e11da1f4a47135c9ae61e75cee838d296a867add65d1	Socio392@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	317645724918606372815887942751064308926	Maria Felicita	Alvarado	392	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	053874
419	Socio 393	7a3b8cfe89232650460987779e2bf84297499a6913e82e53feb28ecb29aff1aa79afe3f42d66a597374b9f7b57664eda80e01625ed24b51351a9283e1e30983a	Socio393@mail.net	Ingresado de bd de sistema heredado -- [sanpabloelcereto] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	200608272412191480120724384975248413544	Jesus Del Carmen	Salinas Albares	393	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	23	\N	16351
433	Socio 407	071a36adc23badd6019b1aacd1448c9521b72224434127f9217642001d0231ca3166aeaec40897665e8f0179449d0ee45e4f934afa6a35e2f27856ce4144b0cb	Socio407@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	231540506758666644040221772924362623085	Maria Rosa	Lopez	407	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824443
434	Socio 408	986426c55ce7a8c6201e50b45c5bd28036a5b7244d077620815a80b49689c225b749df144485c1db28a53965f4312fdfdf7095d005d493f3509ca160fce846d4	Socio408@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	271214690894735230581155596499339109277	Dinora	Garcia	408	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826622
435	Socio 409	b151f99e54733a523dc7b53136d49c42985356b93f226bcd58bab84a9af64e2b6fba1f30a7d49a51ad00144068d0fd935062fb5f3d342a46cc43111affeaed82	Socio409@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	152269483750136592015490529484166999835	El Sitio	Casa Comunal Adesco.	409	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824870
438	Socio 412	63eb7464d88ac192f6a199383a9d50a37926e4c79cc323e23c922069e51951b959ff67fb4b04f6662da55e53b6d2fecbf7c0a86a0e0182fe54c0f9031acb235f	Socio412@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	166129729214511972575416813995194810025	Ana Isable	Monterrosa	412	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826341
439	Socio 413	a3ff3c6eb10d67ad4fb665d4554b096bda594829c51b4257d61f8d3fcdcbd839ddf5010bebc8fcb0b9ff7d16412ebfc2fa3f8c6c2fc634972d3f5fc852323899	Socio413@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	263110557134567749042128689532978783349	Victor Manuel	Guevara Ochoa	413	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	12075978
440	Socio 414	3bc7c6bd998803c336d30dfc0b887d07c292ff94974f23cc6f0d16d09a4a0db6256eeb8ea4e5bd3e35c78a7a64795e18824ff1eea90eaafabdf6c33ae8e247c0	Socio414@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	180263945270682686762450832092367617839	Eduardo Ismael	Ascencio Hernandez	414	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	16373
447	Socio 421	0f67663cd9b7e3e56252df5d0e896705a4cd36f550e709112cc2a8b4f68b3615a9fec5ec1dbce36e7eb66527c4ed03b5c2961d88da0f83130744e33bb2ce2bd2	Socio421@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:48	127.0.0.1	14339953330471257473163999600079773917	Leticia	Escobar Rivera	421	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:48	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824019
448	Socio 422	51e56fc96e53079de7153038aec49c324aaefbc42620ddea77533e12f386ccd0e7b4dc95e588629d47c975ea2782f6e89562814f171578426506fe75ea7100ee	Socio422@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	172423771173982067027478498600092080815	Santos Fidel	Barrera	422	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825475
451	Socio 425	486cf80dfeee26f746938a078f25dbfee4ffc4d4cca78c7133938940690d1b498f95229e58e415261fca834133e7236ca31beebe2bbe67a2307c172c4d12faff	Socio425@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	207195985402950760316208922261342541114	Pedro Antonio	Galdamez Alas	425	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	135062
452	Socio 426	6c34b8ece8c134afd7b7d62d7f1fa362a3e560f9773bd5e925bfdee9bdd9240abc1efd9b74858b3a1d528f341f64ff61d98c529de5ae77dbd22b4df769ef601f	Socio426@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	123029119619207609182363564009905573106	Carlos Del Carmen	Gonzalez	426	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2827044
463	Socio 437	a08b2161bed0119d026f5ecf498627c4aefa9b7177ae626bb20a42239f6b1226178dcf13b2e59e9960ee7131ba08b8c3e51dee6d97e1b688ec9c0d3bb53b0490	Socio437@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	225914955750786325411460316268731482609	Carmen	Alas	437	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	159330
466	Socio 440	42d0dfc7503f3c3a631332ecd6f4c92cc0d919a55fa337d021fe6134f699687b0c1313d00f75912e0dc950a4b3a35d0f2fbcbb0065155149c7a2fde300121ba2	Socio440@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	248299406471936021044027485490071032498	Concepcion	Vasquez	440	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	144878
468	Socio 442	e6b883f9120d23e810e1883301c744bbb1e3394f4b515ae1022a86ff70a9ac7024d1faa6322f875baef4894480d9270ae7611206bb5a61d739d1adc21869b535	Socio442@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	134191482869352819291339658704240443585	Maria Esperanza	Gonzalez	442	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	144911
469	Socio 443	37822d059d7a6455268f59ca8fe7ba621dbb9e84028ccb3eccd990d4654444d15464017abacfa0d0cb0a6b52bb649b49bab84a450e885dc86b2cc29c4dd265c0	Socio443@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	165941133546426832257482484361184910080	Santos	Ayala Aleman	443	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	136018
479	Socio 453	912ebd92dbce060e043f38f7a56e05e8904d0dea5ad50c414adc62d31110fe7381a44a57452dbaa475b637ae68a4b5e6e980c9173fe4f259a5a62db034e0af95	Socio453@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	107039950973894861501617042907125879028	Hector Antonio	Ramirez	453	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824592
480	Socio 454	690a4a1002951731b561509526d643bb15e05a34ebdc7c1a11cd5ba38e1a6512cdaa1967971981345331eb2aeeef228ea29944fed2848b8d4421d96d0380c740	Socio454@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	157191352065355341443184302092453797736	Agustin	Galdamez Alas	454	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824379
481	Socio 455	30c1834b535724805709d4e254631474447b379c9ff65d0d413dd72a5fba7cf36f1777d6e0099c7f7b30ffd6065981fe31d3112c2825583839fa334696ef6409	Socio455@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	176212715865940599684828439149584611934	Juan Antonio	Rivas Somosa	455	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	16371
482	Socio 456	c656f50f50551396a1e5fbffd2b9955901a042f1496511cfebcf55e12991384f43cd2bbf7199f0c38005651a8998c59e04a933757a0b7dc0dff83277479207ea	Socio456@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	46089459785580591609027848571978571574	Habraam	Galdamez	456	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824858
484	Socio 458	669465205c3b6dbdf5cdadc17024e0c02936d440ec8b81e94f873d5e4e53691fc97cf47914e0990aaa531cdc507aa5537728486926b22b913da308832b326c65	Socio458@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	98101125641427227066526512100958565715	Maria Otilia	Gonzalez	458	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824824
485	Socio 459	a3e1a1a54c8306c19660e5dc936634d046ecae558cdd17d92ec8659ee377961186d936928dada76f604131cba280fa31d80833ddb08e782d62ff02bebcb16faa	Socio459@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	108413000745440237014306144569022604535	Jorge Alberto	Sanchez	459	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824381
498	Socio 469	90321b5c6d17a8b9683e4fd8fe8b668d023b492d46af406d4ed94506b68009e02184adf3f7d425df6705f5773816f5bfe3dbcec3df8b8906dd25f3abcdde72dd	Socio469@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	214537656944568516605991685599436220453	El Sitio	Concha Acustica Adesco	469	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825980
499	Socio 470	70f57bf2b21d71f407c02889818ad36a0f8b439eb6ee06801db4e279b804da37976f3a3d0382c61030a11eb2947235e218dadede69875c19f5cec64eaeacb0a0	Socio470@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	190033379056752019836525511022602872285	Candelaria	Gonzalez De Herrera	470	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2823870
501	Socio 472	81fb23ac13ce590a158336fbb8c6219069da2b7c30c09bdda82fc7c4c0d66622fb9ea8998bba785970eb69a2479a60cae256654bf3fc6a721cb9a587bdb975ed	Socio472@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	153409190241228238885355064978092236496	Ricardo Antonio	Rivera Monge	472	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	16379
502	Socio 473	5e424eb83053928e50a88489e8297b15d8179efbe82747b8e98ebcb8c072595dd7e3e85c6958563721fa87c6f5f11b7e8a1c5e16997a324b2c66ff5a6f35efcb	Socio473@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	196376995601117837188285849388115847592	Mario Antonio	Mejia	473	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2827057
503	Socio 474	c70e63ff34551d42687415f70b2c71dbb6cfd93fb6b6218bc3c27134727bbe0ba6dfd18eb8a76de03906872ac873bad050fad38d6a2bbb3da299bd13e921d6c6	Socio474@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	268156390922546393682940692667413546535	Mario	Hernandez Rivera	474	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825068
514	Socio 485	56a32cea03709d308da9dcda5932263da721f5c8f8093488df02da27ccf0200560b9b6f22f338bdc752aef5042e6ab74b008a5436ca01201989cd773368b70fe	Socio485@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	206081527030385521692791301404219894933	Salvador Alfredo	Ramirez	485	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826161
515	Socio 486	f0491e4ca20844ee52c28200ed4f21e5da849c78e5dd20d4e12a3bedd4dfc64fcb994a69e6f5df72caa17c1b8ea86d0900af4bb2250e5a6c1d6f444bd22e224e	Socio486@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	40977367873881792794156471686484122466	Juan Antonio	Barrera	486	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826068
516	Socio 487	40752dee95d77899900b32ec1dc3aa9e6206331aa25b78760cb27085829881db7ec42bbc07ee4fba8e3d74f7cb2f74f013abb6192b55feafc6df34b991adbbdb	Socio487@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:49	127.0.0.1	3212928608907175245104773520561276069	Rosa Adelia	Murilo Olivar	487	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:49	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2826047
530	Socio 501	8ceefe5a97f943c1d70f4f94f6997eb39a068c5190b545e8e3732a151860ed098f840d7010423d011ecee502b1339b93d90f7a75151301326e03b3048cf2ebf9	Socio501@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	291762511468575761721848403712824018224	El Sitio Zapotal	Oficina De Turismo Adesco	501	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824110
531	Socio 502	4334bd9b5d4c06d442da29c06e7521e3b7e7f3154daf4b38c49c8b2221ab49b14b440ac9d6eb7b05fcb6b57b567949bc37a9c25be51744b34fe7779ff61e7ec6	Socio502@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	148081167295580161043497016211490056089	Jose Domitilio	Lara Alas	502	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824921
532	Socio 503	821b11eebf1047cda16b9e69e4d3d1097ea2066559a7547032df9da3ffbff27970f7c41bd45fb38085b64c534158546c644fd3e720e9613054fdfa36f2f630af	Socio503@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	226263128562776525792352903999840133746	Concepcion	Mejia Lopez	503	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2824141
533	Socio 504	c2972b6f93065d9ebcc42ba50754283e5f70abad86270184739df085a6f3a1249eca5a7b6c6e794a22e7819ea61493a1c3755a83da92dfdc6838db0cbd31ecbe	Socio504@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	125743604334906187572554372471210509195	Maximiliano	Mendoza	504	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	14	\N	2825534
551	Socio 521	8a51851740df341c580dd3b5b13ef9707d3fccfc3ec5ce93d4204c551c5fd74508867e0705ae3bc7a524e9c8c74ecc8f5b24a47d490a093bce9d7777b58efd9e	Socio521@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	201977019511413567544958292504534720971	Ilaria	Lopez	521	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	16364
552	Socio 522	964d2518051c0c8376225abc30d18670aa2116bc947acf315f3fb4e4be307c514c93b2d0fc990fbcf43378f86c399be84bb558ced0019a1fd20b5c5770b27425	Socio522@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	58222000898533317568971300029002099693	Alfredo Antonio	Franco Casco	522	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	136013
553	Socio 523	78ac9fe5abf7c0454fed7070c306faeab94d45f9638ddb2790ee35f5e3df95cf116e0ee0e0b2d610d6e0435bb6cf7454f611b30af9e8ed7ea13c6c321b860655	Socio523@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	2507189027207111469547542651943955216	Centro Escolas	Valle Verde	523	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	196030
554	Socio 524	ef87f85359e02a51870e94f2937dea0327657a7e3496f8d52f5168ae06f1dcd90568ed00dc2d53414757206858992382260cae64712f7c5b79b5b9c5389fe080	Socio524@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	222748999549908981752159758152097392742	Jose Elmer	Montoya	524	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824145
557	Socio 527	fc434f71ed8a300100fcede93c1d7fdfbeefb3e68ff8066b20c8618014e7a0db79e3b571967360340cf39299ff0450ab92a1ec7dba8d447953560dd10af17357	Socio527@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	32665714168727631785374192883818742563	Rutilio	Jiron Melgar	527	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144880
558	Socio 528	844881948c84fd5ebce885290b492a3eae63e12f6299dc3688ce8ef45e2559f27d047b1f14bfa689cedd045ae0c637dbed2f20749c45a40a8cb47cfe45acc043	Socio528@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	294112516304145843676872757699344043029	Oscar	Casco	528	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144880
560	Socio 530	f66eb728137331a7c1720aa3b4de5946783b3f6a0690108c592164c2156968d8b4076ca8f96569114487c615b4bdfc4a880f097863c40a4f12223ad54c272a34	Socio530@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	171783320767758475462631639851110702891	Concepocion Jakeline	Huezo Acosta	530	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	135098
562	Socio 532	39cdfe5fc3094b46fd4144f4dd9e77c73270ebaa6f6916b557928451b318fe5a27e01273279c3c47a40d8570f53ced337699220257e75e67ade5e92ddead8682	Socio532@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	98966088489486652335954046751828369277	Agustin	Galdamez Alas	532	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2826111
563	Socio 533	e0c1539cd9f8a36d47ade4f3be02952e0f47cb4a271eed824eaef2f0453c2ff845ddf3bd1dc323edb08ffd9605ee8e30bd83fb59bdff7a443b5f8df5b12cb481	Socio533@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	237846466175537225299147864081734972036	Cesar Omar	Mojica Ortiz	533	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	136016
565	Socio 535	95589545276cd1e393b29756a9c6781abf984bf0060733d1266ec9a7286a18b03ac66ff2e6179ba849f09375128578f17e5f6908a0c97b1bb0fe029fbfc77bf8	Socio535@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	324040790403481631784936187512644893453	Teodoro	Orellana Orellana	535	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823364
579	Socio 549	e836024a9d506369648cdb6ec0e7ab5659d4b4f30788d88a0153e25ad79e9fde8f8c3b97bd621c1ee1ce06125b95fe44496f852eafc2d701f6abb2209d52e63e	Socio549@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	187472438697955853507419247593880331405	Rolando De Jesus	Franco	549	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	284183
580	Socio 550	55cdbcdf67120988ae14895f880f40946e91c6e1b08b48e6a0707ae5debb113d12f0374e36e5213aee603d7e2a939a6ab6ef0f26e50853604f5343189f49cbc5	Socio550@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	282640975416304379667782373527024157069	Roberto Samuel	Extrada Molina	550	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2825352
581	Socio 551	5f16b5ec4090589b2d193a8fb847e3e476ab5854bcc454108c8a505921cbbf3be0a5a72580638962d2a6d208954c5c96013dccb99f91a3ea6c02770d90268b3d	Socio551@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	307181998315292886557656681040748734052	Leonel	Figueroa Ramon	551	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823754
583	Socio 553	b9ab50c30e18dba11a8ba2aa18d53069e569721ead109d856f6db760e437b7047a93e5d8d853409c395341491b35acec21a02b5114046681301ca795f0b1aee8	Socio553@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	145433661282947241563196662539745280423	Jose Tito	Olmedo	553	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823935
587	Socio 557	7d463a7fefcb01062694e4f8c3e6de5b3a04254764de5dfb4040950bf771f56605f671a1a93c1d1b67bdc5a07ec54cdfb46c93581aa48351d4cd73ef0fa6dde7	Socio557@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	140159592732307287458207024061208451909	Avelina Reina	Diaz	557	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2826248
588	Socio 558	dfef3fdc0d480c18283aa9f6d7e06512a2102933b0d2da50380486b01feb37b51cad049b0c987c8f8ed5ddc4f9810eea47f2d718e987f920e73d697d44ec4a0d	Socio558@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:50	127.0.0.1	97943821441523309240429876423898175027	Carlos Fernando	Franco	558	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:50	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823573
595	Socio 565	ce5d41082ee985cf80325b3c5becc0045765b0df6d25228eb23222a18c021bf35b9b9f9e2d3d02d1538fc92eebe3d4ffe35b094b26843472a35d78f4a6c9abb5	Socio565@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	185699964336982040026102153896787547216	Juan Jose	Batres	565	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824280
611	Socio 581	96a43b902e1da503d17c67543627df8a4c906a1e55df7b68504874864109a4c4b54d8a195d6d20c7ff3467f81399c2f11c4aa2c4c8c75387dc3b59dbdaa43c98	Socio581@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	334325990332165720427545639229850912617	Marcos Antonio	Gonzalez Galan	581	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	144925
612	Socio 582	497fa5ce41a00ff743059977ff3cd459d4ff5b9ce8f7849765f25975a78ef9266e83d2dbe3f9f932ff1fbe92e53bbf8d03b10b6f0516c77a1eedde6ec8595889	Socio582@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	187673509274943883329566435916425516108	Tereso De Jesus	Galan	582	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823675
613	Socio 583	5e4ffd7ea049d69a1aed06fcf51ed3740958e5b32864604794a66a0491dfa4e9dfa0a8cde3ef1ecec7ab5415bcb69a736064445094e514e0a8e7f242c62011d3	Socio583@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	213634154516320783134766728533518948064	Luis Francisco	Ortiz Soriano	583	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823969
627	Socio 597	f0d213760bcd20eadee8b0150de4e6b4a91b1e9b94de01e07e6967a2040162481b1a700a4327135b649c3dc5eb4cd5b3351197cf49542663dd2f1d358b440456	Socio597@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	244031350145157180771605541910852861285	Maura Andrea	Zepeda	597	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824869
628	Socio 598	7f8693f8daf5a230aee947b27ac12af0bb3ce29362609b23e61aab2276f6d6caf55f7f0ef42e429d9d48e0a54973272e1aef3ab27072152999b7bcb160f2f1f8	Socio598@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	64232137668177417203638265234597313973	Alfonso	Rivas	598	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2825633
645	Socio 615	d649bf98e62f30b10b233542e9da3d3e708f41efeee991ee11754d8599c020fab9eafa5c8eb271c5f90cda4937a33117f554c913c51c8f0f92bab2f761a68098	Socio615@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	226194371956327474340123764137605513591	Teresa De Jesus	Franco	615	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824225
647	Socio 617	4c1dc98112b4e94d604f0c6126bb1fbebf5b2d4e228dbe4c7922ffebb631bb66e1d23287edd30bac7cffa245e30367bdc8377e06e19d2d9f543730773ba7978d	Socio617@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	193679689720316548879701504783509911614	Trancito	Casco Ardon	617	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	053878
648	Socio 618	0e0ebdec8c825dd759342d36ecc7b485d62618a40c7c082eef5ec422a31fe2f8942385092d9bb993f4fe7fd0f6cc78b2ba5e0dcc547520617fb06102eb218225	Socio618@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	223000095735082477363642982707966923407	Martin Antonio	Aleman Alvarenga	618	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823216
649	Socio 619	7ac6730fee3456f54562a90bc0764ff326c07e6400c1ad95f22e4c060520e2237c7e4e155b4cecb64168504b96a5b7faf101d85411608d62326ea96c0947a92b	Socio619@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	112828506867917014826274180475662721971	Claudia Yesenia	Erazo Valencia	619	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824136
650	Socio 620	a9c328e55ce5d5aab46e17293e7ca5664d78daff6d41c2abda229267bc13d4215c622ee64bc95fc568b19b94b89d888361bfaa76b25c2ed5f3b2bcce1718f254	Socio620@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	320618867192237128698002684403744377471	Pedro Antonio	Aleman	620	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2823406
653	Socio 623	5f38bb4ed36f7062978954eebcfc097d8567e9ea4da8fa21b676957aca337593a7e054e79edc054e2d16d27ffc85548091aad0d05b59d6a82aa646896dddf3b8	Socio623@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	20791200036163268928554662877401527802	Jaun De Dios	Flores Gomez	623	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	4	\N	2824177
659	Socio 629	2805301b11001ee99b3ca321f1d7a89a39c2c59d3b1aab4104d5f15ac384e804741938aabfe58fbd2b6f223e46fccfc9227ebb824b65f70f9dfbf074d630c538	Socio629@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:51	127.0.0.1	116634497380711531726995546887278718836	Paula De Jesus	Vasquez Rodriguez	629	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:51	<cuentas><anda>0000</anda></cuentas>	1	17	\N	136011
675	Socio 645	53bde55d1aee04f5e45b718db81986a3d9e32c3a4ee5aba909cfe1bdfd104e05f961a375e7adda0e057daef86fe1e291eb09c1061e9e785c6c7dad2043ddc6a1	Socio645@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	23836880733119457276192362652633924774	Marvin Antonio	Escobar Figueroa	645	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075982
676	Socio 646	7c48662715965494fe25f6e97af98108e1e2349cc67980daa8a00bd24cb604055eda5908361e2399a31fb0db2b310f42f91cb21845e412d527ba30552e9dc430	Socio646@mail.net	Ingresado de bd de sistema heredado -- [com_valleverde] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	329158307813448378673628742531144255572	Juan Pablo	Hernandez Cabrera	646	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	4	\N	12075988
691	Socio 661	c70fc5c779afc199bbe0656fb643b09c58e6db4b99e395b454d36024a828aa051f4d80c0835c7fa99eaca3537aad6c5ea1308fc7fd932059dde51c19f69971ec	Socio661@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	202156336122175711264339427169872205240	Maria Esperansa	Rivas De Lopez	661	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	13999
707	Socio 677	4d79d349159a29155e9b624373cd538eae41dcc3f9be97c4c3d6b6b3389316eef5e862e874841554cfd00088ce0b55df5218598c37c252d86b778c3cf9a60484	Socio677@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	232390452651452563569568172559833064890	Arely Del Carmen	Salas Torres	677	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	20	\N	21938
708	Socio 678	d23fde1459dc141e510bba12d4fbfd25000501f6b501951e32df70f16478f2944d8b3f474ff967d8bfd2e87b7c32b69a7bd5e973e68c6f172f6d4ebe21119482	Socio678@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	150117211680654396347244817674674126161	Jose Eliseo	Zamora Menjivar	678	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	17	\N	052829
709	Socio 679	6ab2a0ba0f3dc3671e64cc51b20ab2d7874550d26201dc4398495997a135417e4b625f3d996135e44d150b830bd00a3a60cac810277fe3246613b352c11e5d8e	Socio679@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	26127853418233958283004987082840290567	Miriam De Los Angeles	Pineda	679	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	17	\N	052835
710	Socio 680	e301048eab5a4f98cb190656450a9ed04f4d0f524d75a1ce47fe58d4741de580952562154a8a0550876ee035b3e31cab09a31225e2e9c197628aa0411f1b3a66	Socio680@mail.net	Ingresado de bd de sistema heredado -- [com_lamora] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	193693964006547142390346308759528493203	William Antonio	Hernandez	680	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	17	\N	052850
711	Socio 681	4181c9be16e20ce81a750d131884c7d80d80a58071598b4c8a74994e975431e95795163e926e300cdafe2d5015a39091174c46eb201c465c8e699e3bdc603db3	Socio681@mail.net	Ingresado de bd de sistema heredado -- [sitio] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:52	127.0.0.1	204538281893953499589821162662034584718	Delmi Estela	Salazar	681	2015-01-10	13.9500309999999992	-89.0686070000000001	\N	3	2015-02-15 06:47:52	<cuentas><anda>0000</anda></cuentas>	1	14	\N	052832
197	Socio 172	8447e890eda45ec6e01219c5f030acc71261bbf08e78b160bc0d6d153279d55f83284afb5adb652b9cbd6ad7450cf6af225fa23e34084346a5d0a08cc503476a	Socio172@mail.net	Ingresado de bd de sistema heredado -- [sanantoniodelmionte] -- 2015-01-10 22:30:42.64937-06	2015-02-15 06:47:43	127.0.0.1	175668049437002454428766823632847260448	Omar 	 Rodriguez Abrego 	172	2015-01-10	13.9500309999999992	-89.0686070000000001		3	2015-02-15 06:47:43	<cuentas><anda>0000</anda></cuentas>	1	20	\N	22193
\.


--
-- TOC entry 2584 (class 0 OID 17663)
-- Dependencies: 243 2590
-- Data for Name: scr_usuario_rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scr_usuario_rol (usuario_id, rol_id) FROM stdin;
4	5
5	3
6	2
7	4
31	1
34	1
35	1
36	1
37	1
42	1
66	1
69	1
81	1
83	1
84	1
89	1
90	1
109	1
113	1
126	1
127	1
129	1
133	1
134	1
135	1
136	1
140	1
141	1
149	1
150	1
152	1
157	1
158	1
163	1
164	1
166	1
167	1
168	1
212	1
213	1
222	1
225	1
235	1
241	1
251	1
254	1
270	1
277	1
285	1
294	1
296	1
297	1
298	1
299	1
300	1
301	1
302	1
303	1
304	1
305	1
306	1
307	1
308	1
316	1
319	1
338	1
339	1
352	1
359	1
421	1
422	1
423	1
425	1
429	1
431	1
432	1
436	1
437	1
443	1
446	1
449	1
450	1
455	1
462	1
464	1
465	1
467	1
470	1
483	1
489	1
490	1
491	1
494	1
496	1
500	1
505	1
510	1
511	1
512	1
525	1
526	1
529	1
536	1
540	1
542	1
543	1
547	1
548	1
549	1
550	1
555	1
556	1
559	1
561	1
564	1
573	1
582	1
584	1
585	1
586	1
589	1
590	1
600	1
620	1
622	1
623	1
636	1
642	1
643	1
644	1
646	1
651	1
652	1
654	1
672	1
685	1
687	1
699	1
28	1
29	1
25	1
26	1
27	1
30	1
712	1
713	1
714	1
32	1
33	1
38	1
39	1
40	1
41	1
43	1
44	1
45	1
46	1
47	1
48	1
49	1
50	1
51	1
52	1
53	1
54	1
55	1
56	1
57	1
58	1
59	1
60	1
61	1
62	1
63	1
64	1
65	1
67	1
68	1
70	1
71	1
72	1
73	1
74	1
75	1
76	1
77	1
78	1
79	1
80	1
82	1
85	1
86	1
87	1
88	1
91	1
92	1
93	1
94	1
95	1
96	1
97	1
98	1
99	1
100	1
101	1
102	1
103	1
104	1
105	1
106	1
107	1
108	1
110	1
111	1
112	1
114	1
115	1
116	1
117	1
118	1
119	1
120	1
121	1
122	1
123	1
124	1
125	1
128	1
130	1
131	1
132	1
137	1
138	1
139	1
142	1
143	1
144	1
145	1
146	1
147	1
148	1
151	1
153	1
154	1
155	1
156	1
159	1
160	1
161	1
162	1
165	1
169	1
170	1
171	1
172	1
173	1
174	1
175	1
176	1
177	1
178	1
179	1
180	1
181	1
182	1
183	1
184	1
185	1
186	1
187	1
188	1
189	1
190	1
191	1
192	1
193	1
194	1
195	1
196	1
197	1
198	1
199	1
200	1
201	1
202	1
203	1
204	1
205	1
206	1
207	1
208	1
209	1
210	1
211	1
214	1
215	1
216	1
217	1
218	1
219	1
220	1
221	1
223	1
224	1
226	1
227	1
228	1
229	1
230	1
231	1
232	1
233	1
234	1
236	1
237	1
238	1
239	1
240	1
242	1
243	1
244	1
245	1
246	1
247	1
248	1
249	1
250	1
252	1
253	1
255	1
256	1
257	1
258	1
259	1
260	1
261	1
262	1
263	1
264	1
265	1
266	1
267	1
268	1
269	1
271	1
272	1
273	1
274	1
275	1
276	1
278	1
279	1
280	1
281	1
282	1
283	1
284	1
286	1
287	1
288	1
289	1
290	1
291	1
292	1
293	1
295	1
309	1
310	1
311	1
312	1
313	1
314	1
315	1
317	1
318	1
320	1
321	1
322	1
323	1
324	1
325	1
326	1
327	1
328	1
329	1
330	1
331	1
332	1
333	1
334	1
335	1
336	1
337	1
340	1
341	1
342	1
343	1
344	1
345	1
346	1
347	1
348	1
349	1
350	1
351	1
353	1
354	1
355	1
356	1
357	1
358	1
360	1
361	1
362	1
363	1
364	1
365	1
366	1
367	1
368	1
369	1
370	1
371	1
372	1
373	1
374	1
375	1
377	1
378	1
379	1
380	1
381	1
382	1
383	1
384	1
385	1
386	1
387	1
388	1
389	1
390	1
391	1
392	1
393	1
394	1
395	1
396	1
397	1
398	1
399	1
400	1
401	1
402	1
403	1
404	1
405	1
406	1
407	1
408	1
409	1
410	1
411	1
412	1
413	1
414	1
415	1
416	1
417	1
418	1
419	1
420	1
424	1
426	1
427	1
428	1
430	1
433	1
434	1
435	1
438	1
439	1
440	1
441	1
442	1
444	1
445	1
447	1
448	1
451	1
452	1
453	1
454	1
456	1
457	1
458	1
459	1
460	1
461	1
463	1
466	1
468	1
469	1
471	1
472	1
473	1
474	1
475	1
476	1
477	1
478	1
479	1
480	1
481	1
482	1
484	1
485	1
486	1
487	1
493	1
495	1
498	1
499	1
501	1
502	1
503	1
504	1
506	1
507	1
508	1
509	1
513	1
514	1
515	1
516	1
517	1
518	1
519	1
520	1
521	1
522	1
523	1
524	1
527	1
528	1
530	1
531	1
532	1
533	1
534	1
537	1
538	1
539	1
541	1
544	1
545	1
546	1
551	1
552	1
553	1
554	1
557	1
558	1
560	1
562	1
563	1
565	1
566	1
567	1
568	1
569	1
570	1
571	1
572	1
574	1
575	1
576	1
577	1
578	1
579	1
580	1
581	1
583	1
587	1
588	1
591	1
592	1
593	1
594	1
595	1
596	1
597	1
598	1
599	1
601	1
602	1
603	1
604	1
605	1
606	1
607	1
608	1
609	1
610	1
611	1
612	1
613	1
614	1
615	1
616	1
617	1
618	1
619	1
621	1
624	1
625	1
626	1
627	1
628	1
629	1
630	1
631	1
632	1
633	1
634	1
635	1
637	1
638	1
639	1
640	1
641	1
645	1
647	1
648	1
649	1
650	1
653	1
655	1
656	1
657	1
658	1
659	1
660	1
661	1
662	1
663	1
664	1
665	1
666	1
667	1
668	1
669	1
670	1
671	1
673	1
674	1
675	1
676	1
677	1
678	1
679	1
680	1
681	1
682	1
683	1
684	1
686	1
688	1
689	1
690	1
691	1
692	1
693	1
694	1
695	1
696	1
697	1
698	1
700	1
701	1
702	1
703	1
704	1
705	1
706	1
707	1
708	1
709	1
710	1
711	1
\.


--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 244
-- Name: src_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('src_log_id_seq', 1, false);


--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 245
-- Name: src_rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('src_rol_id_seq', 1, false);


--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 246
-- Name: src_tip_rep_legal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('src_tip_rep_legal_id_seq', 3, true);


--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 247
-- Name: src_tipo_org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('src_tipo_org_id_seq', 1, false);


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 248
-- Name: src_usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('src_usuario_id_seq', 673, true);


--
-- TOC entry 2190 (class 2606 OID 17723)
-- Dependencies: 168 168 2591
-- Name: PK_bombeo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_bombeo
    ADD CONSTRAINT "PK_bombeo" PRIMARY KEY (id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2226 (class 2606 OID 17726)
-- Dependencies: 184 184 2591
-- Name: PK_cloracion; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cloracion
    ADD CONSTRAINT "PK_cloracion" PRIMARY KEY (id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2240 (class 2606 OID 17729)
-- Dependencies: 192 192 2591
-- Name: PK_cuenta; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cuenta
    ADD CONSTRAINT "PK_cuenta" PRIMARY KEY (id);


--
-- TOC entry 2267 (class 2606 OID 17731)
-- Dependencies: 202 202 2591
-- Name: PK_estado; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_estado
    ADD CONSTRAINT "PK_estado" PRIMARY KEY (id);


--
-- TOC entry 2279 (class 2606 OID 17733)
-- Dependencies: 210 210 210 2591
-- Name: PK_linea_proyecto; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_linea_proyecto
    ADD CONSTRAINT "PK_linea_proyecto" PRIMARY KEY (linea_estrategica_id, proyecto_id);


--
-- TOC entry 2303 (class 2606 OID 17735)
-- Dependencies: 222 222 222 2591
-- Name: PK_producto_area; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_producto_area
    ADD CONSTRAINT "PK_producto_area" PRIMARY KEY (producto_id, "areaTrabajo_id");


--
-- TOC entry 2324 (class 2606 OID 17737)
-- Dependencies: 238 238 2591
-- Name: PK_transaccion; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_transaccion
    ADD CONSTRAINT "PK_transaccion" PRIMARY KEY (id);


--
-- TOC entry 2192 (class 2606 OID 17739)
-- Dependencies: 170 170 2591
-- Name: UN_cargo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cargo
    ADD CONSTRAINT "UN_cargo" UNIQUE ("cargoNombre");


--
-- TOC entry 2196 (class 2606 OID 17741)
-- Dependencies: 172 172 2591
-- Name: UN_cat_actividad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_actividad
    ADD CONSTRAINT "UN_cat_actividad" UNIQUE ("cActividadNombre");


--
-- TOC entry 2200 (class 2606 OID 17743)
-- Dependencies: 174 174 2591
-- Name: UN_cat_cobro; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_cobro
    ADD CONSTRAINT "UN_cat_cobro" UNIQUE ("cCobroNombre");


--
-- TOC entry 2242 (class 2606 OID 17745)
-- Dependencies: 192 192 2591
-- Name: UN_cuenta_codigo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cuenta
    ADD CONSTRAINT "UN_cuenta_codigo" UNIQUE ("cuentaCodigo");


--
-- TOC entry 2244 (class 2606 OID 17747)
-- Dependencies: 192 192 192 2591
-- Name: UN_cuenta_nombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cuenta
    ADD CONSTRAINT "UN_cuenta_nombre" UNIQUE ("cuentaNombre", cat_cuenta_id);


--
-- TOC entry 2255 (class 2606 OID 17749)
-- Dependencies: 199 199 2591
-- Name: UN_empleado_email; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT "UN_empleado_email" UNIQUE ("empleadoEmail");


--
-- TOC entry 2257 (class 2606 OID 17751)
-- Dependencies: 199 199 2591
-- Name: UN_empleado_nit; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT "UN_empleado_nit" UNIQUE ("empleadoNit");


--
-- TOC entry 2269 (class 2606 OID 17753)
-- Dependencies: 202 202 2591
-- Name: UN_estado; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_estado
    ADD CONSTRAINT "UN_estado" UNIQUE ("nombreEstado");


--
-- TOC entry 2275 (class 2606 OID 17755)
-- Dependencies: 208 208 2591
-- Name: UN_lEstrategica_nombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_linea_estrategica
    ADD CONSTRAINT "UN_lEstrategica_nombre" UNIQUE ("lEstrategicaNombre");


--
-- TOC entry 2287 (class 2606 OID 17757)
-- Dependencies: 214 214 2591
-- Name: UN_marcaNombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_marca_produc
    ADD CONSTRAINT "UN_marcaNombre" UNIQUE ("marcaProducNombre");


--
-- TOC entry 2291 (class 2606 OID 17759)
-- Dependencies: 216 216 2591
-- Name: UN_org_nombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_organizacion
    ADD CONSTRAINT "UN_org_nombre" UNIQUE ("organizacionNombre");


--
-- TOC entry 2297 (class 2606 OID 17761)
-- Dependencies: 219 219 2591
-- Name: UN_presenNombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_presen_produc
    ADD CONSTRAINT "UN_presenNombre" UNIQUE ("presenProducNombre");


--
-- TOC entry 2305 (class 2606 OID 17763)
-- Dependencies: 224 224 2591
-- Name: UN_proveedorNombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_proveedor
    ADD CONSTRAINT "UN_proveedorNombre" UNIQUE ("proveedorNombre");


--
-- TOC entry 2313 (class 2606 OID 17765)
-- Dependencies: 230 230 2591
-- Name: UN_rep_leg_email; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_representante_legal
    ADD CONSTRAINT "UN_rep_leg_email" UNIQUE ("rLegalemail");


--
-- TOC entry 2207 (class 2606 OID 17767)
-- Dependencies: 176 176 2591
-- Name: UN_tip_depresiacion; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_depreciacion
    ADD CONSTRAINT "UN_tip_depresiacion" UNIQUE ("depreciacionNombre");


--
-- TOC entry 2211 (class 2606 OID 17769)
-- Dependencies: 177 177 2591
-- Name: UN_tip_org; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_organizacion
    ADD CONSTRAINT "UN_tip_org" UNIQUE ("cOrgNombre");


--
-- TOC entry 2218 (class 2606 OID 17771)
-- Dependencies: 179 179 2591
-- Name: UN_tip_rep_legal; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_rep_legal
    ADD CONSTRAINT "UN_tip_rep_legal" UNIQUE ("catRLegalNombre");


--
-- TOC entry 2326 (class 2606 OID 17773)
-- Dependencies: 240 240 2591
-- Name: UN_uMedidaNombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_u_medida_produc
    ADD CONSTRAINT "UN_uMedidaNombre" UNIQUE ("uMedidaProducNombre");


--
-- TOC entry 2180 (class 2606 OID 17775)
-- Dependencies: 162 162 2591
-- Name: pk_actividad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_actividad
    ADD CONSTRAINT pk_actividad PRIMARY KEY (id);


--
-- TOC entry 2184 (class 2606 OID 17777)
-- Dependencies: 164 164 2591
-- Name: pk_area_de_trabajo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_area_trabajo
    ADD CONSTRAINT pk_area_de_trabajo PRIMARY KEY (id);


--
-- TOC entry 2188 (class 2606 OID 17779)
-- Dependencies: 166 166 2591
-- Name: pk_banco; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_banco
    ADD CONSTRAINT pk_banco PRIMARY KEY (id);


--
-- TOC entry 2194 (class 2606 OID 17781)
-- Dependencies: 170 170 2591
-- Name: pk_cargo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cargo
    ADD CONSTRAINT pk_cargo PRIMARY KEY (id);


--
-- TOC entry 2204 (class 2606 OID 17783)
-- Dependencies: 175 175 2591
-- Name: pk_cat_cooperante; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_cooperante
    ADD CONSTRAINT pk_cat_cooperante PRIMARY KEY (id);


--
-- TOC entry 2215 (class 2606 OID 17785)
-- Dependencies: 178 178 2591
-- Name: pk_cat_product; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_produc
    ADD CONSTRAINT pk_cat_product PRIMARY KEY (id);


--
-- TOC entry 2222 (class 2606 OID 17787)
-- Dependencies: 180 180 2591
-- Name: pk_cheq_rr; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cheq_recurso
    ADD CONSTRAINT pk_cheq_rr PRIMARY KEY (id);


--
-- TOC entry 2224 (class 2606 OID 17789)
-- Dependencies: 182 182 2591
-- Name: pk_chequera; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_chequera
    ADD CONSTRAINT pk_chequera PRIMARY KEY (id);


--
-- TOC entry 2228 (class 2606 OID 17791)
-- Dependencies: 186 186 2591
-- Name: pk_cobro; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cobro
    ADD CONSTRAINT pk_cobro PRIMARY KEY (id);


--
-- TOC entry 2234 (class 2606 OID 17793)
-- Dependencies: 188 188 2591
-- Name: pk_consumo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_consumo
    ADD CONSTRAINT pk_consumo PRIMARY KEY (id);


--
-- TOC entry 2238 (class 2606 OID 17795)
-- Dependencies: 190 190 2591
-- Name: pk_cooperante; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cooperante
    ADD CONSTRAINT pk_cooperante PRIMARY KEY (id);


--
-- TOC entry 2249 (class 2606 OID 17797)
-- Dependencies: 196 196 2591
-- Name: pk_det_factura; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_det_factura
    ADD CONSTRAINT pk_det_factura PRIMARY KEY (id);


--
-- TOC entry 2247 (class 2606 OID 17799)
-- Dependencies: 194 194 2591
-- Name: pk_detalle_org; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_det_contable
    ADD CONSTRAINT pk_detalle_org PRIMARY KEY (id);


--
-- TOC entry 2259 (class 2606 OID 17801)
-- Dependencies: 199 199 2591
-- Name: pk_empleado; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT pk_empleado PRIMARY KEY (id);


--
-- TOC entry 2265 (class 2606 OID 17803)
-- Dependencies: 200 200 200 2591
-- Name: pk_empleado_actividad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_empleado_actividad
    ADD CONSTRAINT pk_empleado_actividad PRIMARY KEY (empleado_id, actividad_id);


--
-- TOC entry 2271 (class 2606 OID 17805)
-- Dependencies: 204 204 2591
-- Name: pk_his_rep_leg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_his_rep_legal
    ADD CONSTRAINT pk_his_rep_leg PRIMARY KEY (id);


--
-- TOC entry 2273 (class 2606 OID 17807)
-- Dependencies: 206 206 2591
-- Name: pk_lectura; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_lectura
    ADD CONSTRAINT pk_lectura PRIMARY KEY (id);


--
-- TOC entry 2277 (class 2606 OID 17809)
-- Dependencies: 208 208 2591
-- Name: pk_linea_estrateg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_linea_estrategica
    ADD CONSTRAINT pk_linea_estrateg PRIMARY KEY (id);


--
-- TOC entry 2281 (class 2606 OID 17811)
-- Dependencies: 211 211 2591
-- Name: pk_localidad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_localidad
    ADD CONSTRAINT pk_localidad PRIMARY KEY (id);


--
-- TOC entry 2285 (class 2606 OID 17813)
-- Dependencies: 213 213 2591
-- Name: pk_log; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_log
    ADD CONSTRAINT pk_log PRIMARY KEY (id);


--
-- TOC entry 2289 (class 2606 OID 17815)
-- Dependencies: 214 214 2591
-- Name: pk_marca_produc; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_marca_produc
    ADD CONSTRAINT pk_marca_produc PRIMARY KEY (id);


--
-- TOC entry 2293 (class 2606 OID 17817)
-- Dependencies: 216 216 2591
-- Name: pk_organizacion; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_organizacion
    ADD CONSTRAINT pk_organizacion PRIMARY KEY (id);


--
-- TOC entry 2295 (class 2606 OID 17819)
-- Dependencies: 218 218 218 2591
-- Name: pk_organizacion_representante_legal; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_periodo_representante
    ADD CONSTRAINT pk_organizacion_representante_legal PRIMARY KEY (organizacion_id, representante_legal_id);


--
-- TOC entry 2299 (class 2606 OID 17821)
-- Dependencies: 219 219 2591
-- Name: pk_presen_produc; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_presen_produc
    ADD CONSTRAINT pk_presen_produc PRIMARY KEY (id);


--
-- TOC entry 2301 (class 2606 OID 17823)
-- Dependencies: 221 221 2591
-- Name: pk_producto; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_producto
    ADD CONSTRAINT pk_producto PRIMARY KEY (id);


--
-- TOC entry 2307 (class 2606 OID 17825)
-- Dependencies: 224 224 2591
-- Name: pk_proveedor; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_proveedor
    ADD CONSTRAINT pk_proveedor PRIMARY KEY (id);


--
-- TOC entry 2309 (class 2606 OID 17827)
-- Dependencies: 226 226 2591
-- Name: pk_proyecto; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_proyecto
    ADD CONSTRAINT pk_proyecto PRIMARY KEY (id);


--
-- TOC entry 2311 (class 2606 OID 17829)
-- Dependencies: 228 228 2591
-- Name: pk_recibo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_recibo
    ADD CONSTRAINT pk_recibo PRIMARY KEY (id);


--
-- TOC entry 2315 (class 2606 OID 17831)
-- Dependencies: 230 230 2591
-- Name: pk_representante_legal; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_representante_legal
    ADD CONSTRAINT pk_representante_legal PRIMARY KEY (id);


--
-- TOC entry 2321 (class 2606 OID 17833)
-- Dependencies: 233 233 2591
-- Name: pk_rr_ejecucion; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_rr_ejecucion
    ADD CONSTRAINT pk_rr_ejecucion PRIMARY KEY (id);


--
-- TOC entry 2317 (class 2606 OID 17835)
-- Dependencies: 232 232 2591
-- Name: pk_saf_rol; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_rol
    ADD CONSTRAINT pk_saf_rol PRIMARY KEY (id);


--
-- TOC entry 2209 (class 2606 OID 17837)
-- Dependencies: 176 176 2591
-- Name: pk_tip_depresiacion; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_depreciacion
    ADD CONSTRAINT pk_tip_depresiacion PRIMARY KEY (id);


--
-- TOC entry 2220 (class 2606 OID 17839)
-- Dependencies: 179 179 2591
-- Name: pk_tip_rep_leg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_rep_legal
    ADD CONSTRAINT pk_tip_rep_leg PRIMARY KEY (id);


--
-- TOC entry 2198 (class 2606 OID 17841)
-- Dependencies: 172 172 2591
-- Name: pk_tipo_actividad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_actividad
    ADD CONSTRAINT pk_tipo_actividad PRIMARY KEY (id);


--
-- TOC entry 2202 (class 2606 OID 17843)
-- Dependencies: 174 174 2591
-- Name: pk_tipo_cobro; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_cobro
    ADD CONSTRAINT pk_tipo_cobro PRIMARY KEY (id);


--
-- TOC entry 2213 (class 2606 OID 17845)
-- Dependencies: 177 177 2591
-- Name: pk_tipo_org; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cat_organizacion
    ADD CONSTRAINT pk_tipo_org PRIMARY KEY (id);


--
-- TOC entry 2328 (class 2606 OID 17847)
-- Dependencies: 240 240 2591
-- Name: pk_u_medida_produc; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_u_medida_produc
    ADD CONSTRAINT pk_u_medida_produc PRIMARY KEY (id);


--
-- TOC entry 2332 (class 2606 OID 17849)
-- Dependencies: 242 242 2591
-- Name: pk_usuario; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_usuario
    ADD CONSTRAINT pk_usuario PRIMARY KEY (id);


--
-- TOC entry 2338 (class 2606 OID 17851)
-- Dependencies: 243 243 243 2591
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_usuario_rol
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (usuario_id, rol_id);


--
-- TOC entry 2319 (class 2606 OID 17853)
-- Dependencies: 232 232 2591
-- Name: scd_rol_nombrerol_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_rol
    ADD CONSTRAINT scd_rol_nombrerol_key UNIQUE (nombrerol);


--
-- TOC entry 2236 (class 2606 OID 17855)
-- Dependencies: 188 188 188 2591
-- Name: unique_cobro_xfactura; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_consumo
    ADD CONSTRAINT unique_cobro_xfactura UNIQUE (cobro_id, factura_id);


--
-- TOC entry 2251 (class 2606 OID 17857)
-- Dependencies: 196 196 2591
-- Name: unique_comprobante; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_det_factura
    ADD CONSTRAINT unique_comprobante UNIQUE (det_factur_numero) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2334 (class 2606 OID 17860)
-- Dependencies: 242 242 2591
-- Name: unique_correo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_usuario
    ADD CONSTRAINT unique_correo UNIQUE (correousuario);


--
-- TOC entry 2261 (class 2606 OID 17862)
-- Dependencies: 199 199 2591
-- Name: unique_dui_empleado; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT unique_dui_empleado UNIQUE ("empleadoDui");


--
-- TOC entry 2253 (class 2606 OID 17864)
-- Dependencies: 196 196 196 2591
-- Name: unique_factura_mes; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_det_factura
    ADD CONSTRAINT unique_factura_mes UNIQUE (socio_id, limite_pago);


--
-- TOC entry 2263 (class 2606 OID 17866)
-- Dependencies: 199 199 2591
-- Name: unique_isss_empleado; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT unique_isss_empleado UNIQUE ("empleadoIsss");


--
-- TOC entry 2336 (class 2606 OID 17868)
-- Dependencies: 242 242 2591
-- Name: unique_login; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_usuario
    ADD CONSTRAINT unique_login UNIQUE (username);


--
-- TOC entry 2182 (class 2606 OID 17870)
-- Dependencies: 162 162 2591
-- Name: unique_nombre_actividad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_actividad
    ADD CONSTRAINT unique_nombre_actividad UNIQUE ("actividadNombre");


--
-- TOC entry 2186 (class 2606 OID 17872)
-- Dependencies: 164 164 2591
-- Name: unique_nombre_area_de_trabajo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_area_trabajo
    ADD CONSTRAINT unique_nombre_area_de_trabajo UNIQUE ("aTrabajoNombre");


--
-- TOC entry 2230 (class 2606 OID 17874)
-- Dependencies: 186 186 2591
-- Name: unique_nombre_cobrocodigo; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cobro
    ADD CONSTRAINT unique_nombre_cobrocodigo UNIQUE ("cobroCodigo");


--
-- TOC entry 2232 (class 2606 OID 17876)
-- Dependencies: 186 186 2591
-- Name: unique_nombre_cobronombre; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_cobro
    ADD CONSTRAINT unique_nombre_cobronombre UNIQUE ("cobroNombre");


--
-- TOC entry 2283 (class 2606 OID 17878)
-- Dependencies: 211 211 2591
-- Name: unique_nombre_localidad; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_localidad
    ADD CONSTRAINT unique_nombre_localidad UNIQUE (localidad_nombre);


--
-- TOC entry 2340 (class 2606 OID 17880)
-- Dependencies: 243 243 243 2591
-- Name: unique_permiso; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scr_usuario_rol
    ADD CONSTRAINT unique_permiso UNIQUE (rol_id, usuario_id);


--
-- TOC entry 2322 (class 1259 OID 17881)
-- Dependencies: 238 2591
-- Name: FKI_det_contable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "FKI_det_contable" ON scr_transaccion USING btree (pcontable_id);


--
-- TOC entry 2245 (class 1259 OID 17882)
-- Dependencies: 194 2591
-- Name: FKI_organizacion; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "FKI_organizacion" ON scr_det_contable USING btree (organizacion_id);


--
-- TOC entry 2205 (class 1259 OID 17883)
-- Dependencies: 176 2591
-- Name: IDX_tip_depreciacion; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "IDX_tip_depreciacion" ON scr_cat_depreciacion USING btree ("depreciacionNombre");


--
-- TOC entry 2216 (class 1259 OID 17884)
-- Dependencies: 179 2591
-- Name: IDX_tip_rep_legal; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "IDX_tip_rep_legal" ON scr_cat_rep_legal USING btree ("catRLegalNombre");


--
-- TOC entry 2329 (class 1259 OID 17885)
-- Dependencies: 242 2591
-- Name: fki_PK_estado; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "fki_PK_estado" ON scr_usuario USING btree (estado_id);


--
-- TOC entry 2330 (class 1259 OID 17886)
-- Dependencies: 242 2591
-- Name: fki_localidad; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fki_localidad ON scr_usuario USING btree (localidad_id);


--
-- TOC entry 2178 (class 1259 OID 17887)
-- Dependencies: 161 2591
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- TOC entry 2393 (class 2620 OID 17888)
-- Dependencies: 284 192 2591
-- Name: actualiza_a_activo; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER actualiza_a_activo BEFORE INSERT OR UPDATE ON scr_cuenta FOR EACH ROW EXECUTE PROCEDURE tgr_verifica_activo();


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 2393
-- Name: TRIGGER actualiza_a_activo ON scr_cuenta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER actualiza_a_activo ON scr_cuenta IS 'Actualiza el estado de la cuenta si no es pasivo o capital';


--
-- TOC entry 2397 (class 2620 OID 17889)
-- Dependencies: 278 238 2591
-- Name: actualiza_cuenta; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER actualiza_cuenta BEFORE INSERT ON scr_transaccion FOR EACH ROW EXECUTE PROCEDURE tgr_actualiza_cuenta();

ALTER TABLE scr_transaccion DISABLE TRIGGER actualiza_cuenta;


--
-- TOC entry 2394 (class 2620 OID 17890)
-- Dependencies: 279 192 2591
-- Name: actualiza_rubros; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER actualiza_rubros AFTER INSERT OR UPDATE ON scr_cuenta FOR EACH ROW EXECUTE PROCEDURE tgr_actualiza_rubro();

ALTER TABLE scr_cuenta DISABLE TRIGGER actualiza_rubros;


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 2394
-- Name: TRIGGER actualiza_rubros ON scr_cuenta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER actualiza_rubros ON scr_cuenta IS 'Actualiza el el rubro';


--
-- TOC entry 2392 (class 2620 OID 17891)
-- Dependencies: 188 280 2591
-- Name: agrega_costo; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER agrega_costo BEFORE INSERT OR UPDATE ON scr_consumo FOR EACH ROW EXECUTE PROCEDURE tgr_agrega_costo();


--
-- TOC entry 2399 (class 2620 OID 17892)
-- Dependencies: 242 281 2591
-- Name: asigna_contador; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER asigna_contador BEFORE INSERT ON scr_usuario FOR EACH ROW EXECUTE PROCEDURE tgr_asigna_contador();

ALTER TABLE scr_usuario DISABLE TRIGGER asigna_contador;


--
-- TOC entry 2395 (class 2620 OID 17893)
-- Dependencies: 285 192 2591
-- Name: genera_cod_cuenta; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER genera_cod_cuenta BEFORE INSERT ON scr_cuenta FOR EACH ROW EXECUTE PROCEDURE tgr_verifica_cod_cuenta();


--
-- TOC entry 2400 (class 2620 OID 17894)
-- Dependencies: 277 242 2591
-- Name: gestiona_contador; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gestiona_contador BEFORE DELETE OR UPDATE ON scr_usuario FOR EACH ROW EXECUTE PROCEDURE tgr_actualiza_contador();

ALTER TABLE scr_usuario DISABLE TRIGGER gestiona_contador;


--
-- TOC entry 2398 (class 2620 OID 17895)
-- Dependencies: 282 238 2591
-- Name: maneja_transacx; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER maneja_transacx BEFORE DELETE OR UPDATE ON scr_transaccion FOR EACH ROW EXECUTE PROCEDURE tgr_gestion_transacx();


--
-- TOC entry 2396 (class 2620 OID 17896)
-- Dependencies: 194 286 2591
-- Name: verifica_fecha; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER verifica_fecha BEFORE INSERT OR UPDATE ON scr_det_contable FOR EACH ROW EXECUTE PROCEDURE tgr_verifica_tcontable();


--
-- TOC entry 2391 (class 2620 OID 17897)
-- Dependencies: 162 287 2591
-- Name: verificartiempoact; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER verificartiempoact BEFORE INSERT ON scr_actividad FOR EACH ROW EXECUTE PROCEDURE tgr_verificar_tiempo_act();


--
-- TOC entry 2344 (class 2606 OID 17898)
-- Dependencies: 170 2193 164 2591
-- Name: FK_cargo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_area_trabajo
    ADD CONSTRAINT "FK_cargo" FOREIGN KEY (cargo_id) REFERENCES scr_cargo(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2353 (class 2606 OID 17903)
-- Dependencies: 2201 174 186 2591
-- Name: FK_catCobro; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cobro
    ADD CONSTRAINT "FK_catCobro" FOREIGN KEY (cat_cobro_id) REFERENCES scr_cat_cobro(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2384 (class 2606 OID 17908)
-- Dependencies: 238 2239 192 2591
-- Name: FK_cuenta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_transaccion
    ADD CONSTRAINT "FK_cuenta" FOREIGN KEY (cuenta_id) REFERENCES scr_cuenta(id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2357 (class 2606 OID 17913)
-- Dependencies: 2239 192 192 2591
-- Name: FK_cuenta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cuenta
    ADD CONSTRAINT "FK_cuenta" FOREIGN KEY (cat_cuenta_id) REFERENCES scr_cuenta(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED NOT VALID;


--
-- TOC entry 2385 (class 2606 OID 17918)
-- Dependencies: 238 2246 194 2591
-- Name: FK_det_contable; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_transaccion
    ADD CONSTRAINT "FK_det_contable" FOREIGN KEY (pcontable_id) REFERENCES scr_det_contable(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2358 (class 2606 OID 17923)
-- Dependencies: 2258 199 194 2591
-- Name: FK_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_det_contable
    ADD CONSTRAINT "FK_empleado" FOREIGN KEY (empleado_id) REFERENCES scr_empleado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2386 (class 2606 OID 17928)
-- Dependencies: 2258 199 238 2591
-- Name: FK_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_transaccion
    ADD CONSTRAINT "FK_empleado" FOREIGN KEY (empleado_id) REFERENCES scr_empleado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2351 (class 2606 OID 17933)
-- Dependencies: 184 199 2258 2591
-- Name: FK_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cloracion
    ADD CONSTRAINT "FK_empleado" FOREIGN KEY (empleado_id) REFERENCES scr_empleado(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2347 (class 2606 OID 17938)
-- Dependencies: 168 2258 199 2591
-- Name: FK_empleado_bombeo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_bombeo
    ADD CONSTRAINT "FK_empleado_bombeo" FOREIGN KEY (empleado_id) REFERENCES scr_empleado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2370 (class 2606 OID 17943)
-- Dependencies: 2276 208 210 2591
-- Name: FK_linea_estrategica; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_linea_proyecto
    ADD CONSTRAINT "FK_linea_estrategica" FOREIGN KEY (linea_estrategica_id) REFERENCES scr_linea_estrategica(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2361 (class 2606 OID 17948)
-- Dependencies: 199 2280 211 2591
-- Name: FK_localidad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT "FK_localidad" FOREIGN KEY (localidad_id) REFERENCES scr_localidad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2352 (class 2606 OID 17953)
-- Dependencies: 184 2280 211 2591
-- Name: FK_localidad_cloracion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cloracion
    ADD CONSTRAINT "FK_localidad_cloracion" FOREIGN KEY (localidad_id) REFERENCES scr_localidad(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2359 (class 2606 OID 17958)
-- Dependencies: 194 2292 216 2591
-- Name: FK_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_det_contable
    ADD CONSTRAINT "FK_organizacion" FOREIGN KEY (organizacion_id) REFERENCES scr_organizacion(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2371 (class 2606 OID 17963)
-- Dependencies: 210 2308 226 2591
-- Name: FK_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_linea_proyecto
    ADD CONSTRAINT "FK_proyecto" FOREIGN KEY (proyecto_id) REFERENCES scr_proyecto(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2341 (class 2606 OID 17968)
-- Dependencies: 2308 226 162 2591
-- Name: FK_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_actividad
    ADD CONSTRAINT "FK_proyecto" FOREIGN KEY (proyecto_id) REFERENCES scr_proyecto(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2387 (class 2606 OID 17973)
-- Dependencies: 242 2266 202 2591
-- Name: PK_estado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_usuario
    ADD CONSTRAINT "PK_estado" FOREIGN KEY (estado_id) REFERENCES scr_estado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2364 (class 2606 OID 17978)
-- Dependencies: 162 2179 200 2591
-- Name: fk_actividad_emp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_empleado_actividad
    ADD CONSTRAINT fk_actividad_emp FOREIGN KEY (actividad_id) REFERENCES scr_actividad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2345 (class 2606 OID 17983)
-- Dependencies: 164 2183 164 2591
-- Name: fk_area_de_trabajo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_area_trabajo
    ADD CONSTRAINT fk_area_de_trabajo FOREIGN KEY (area_trabajo_id) REFERENCES scr_area_trabajo(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2350 (class 2606 OID 17988)
-- Dependencies: 166 182 2187 2591
-- Name: fk_banco_chequera; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_chequera
    ADD CONSTRAINT fk_banco_chequera FOREIGN KEY (banco_id) REFERENCES scr_banco(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2362 (class 2606 OID 17993)
-- Dependencies: 199 170 2193 2591
-- Name: fk_cargo_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT fk_cargo_empleado FOREIGN KEY (cargo_id) REFERENCES scr_cargo(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2348 (class 2606 OID 17998)
-- Dependencies: 170 170 2193 2591
-- Name: fk_cargo_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cargo
    ADD CONSTRAINT fk_cargo_parent FOREIGN KEY (cargo_id) REFERENCES scr_cargo(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2356 (class 2606 OID 18003)
-- Dependencies: 2203 190 175 2591
-- Name: fk_cat_cooperante; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cooperante
    ADD CONSTRAINT fk_cat_cooperante FOREIGN KEY ("catCooperante_id") REFERENCES scr_cat_cooperante(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2376 (class 2606 OID 18008)
-- Dependencies: 2208 176 221 2591
-- Name: fk_cat_depresiacion_producto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_producto
    ADD CONSTRAINT fk_cat_depresiacion_producto FOREIGN KEY ("catDepresiacion_id") REFERENCES scr_cat_depreciacion(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2377 (class 2606 OID 18013)
-- Dependencies: 221 2214 178 2591
-- Name: fk_cat_produc_produc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_producto
    ADD CONSTRAINT fk_cat_produc_produc FOREIGN KEY ("catProduc_id") REFERENCES scr_cat_produc(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2349 (class 2606 OID 18018)
-- Dependencies: 180 2223 182 2591
-- Name: fk_chequera; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_cheq_recurso
    ADD CONSTRAINT fk_chequera FOREIGN KEY (chequera_id) REFERENCES scr_chequera(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2354 (class 2606 OID 18023)
-- Dependencies: 188 2227 186 2591
-- Name: fk_consumo_cobro; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_consumo
    ADD CONSTRAINT fk_consumo_cobro FOREIGN KEY (cobro_id) REFERENCES scr_cobro(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2355 (class 2606 OID 18028)
-- Dependencies: 196 2248 188 2591
-- Name: fk_consumo_factura; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_consumo
    ADD CONSTRAINT fk_consumo_factura FOREIGN KEY (factura_id) REFERENCES scr_det_factura(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2365 (class 2606 OID 18033)
-- Dependencies: 200 199 2258 2591
-- Name: fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_empleado_actividad
    ADD CONSTRAINT fk_empleado FOREIGN KEY (empleado_id) REFERENCES scr_empleado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2367 (class 2606 OID 18038)
-- Dependencies: 199 2258 206 2591
-- Name: fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_lectura
    ADD CONSTRAINT fk_empleado FOREIGN KEY (tecnico_id) REFERENCES scr_empleado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2372 (class 2606 OID 18043)
-- Dependencies: 211 211 2280 2591
-- Name: fk_localidad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_localidad
    ADD CONSTRAINT fk_localidad FOREIGN KEY (localidad_id) REFERENCES scr_localidad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2388 (class 2606 OID 18048)
-- Dependencies: 2280 211 242 2591
-- Name: fk_localidad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_usuario
    ADD CONSTRAINT fk_localidad FOREIGN KEY (localidad_id) REFERENCES scr_localidad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2373 (class 2606 OID 18053)
-- Dependencies: 2280 211 216 2591
-- Name: fk_localidad_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_organizacion
    ADD CONSTRAINT fk_localidad_organizacion FOREIGN KEY (localidad_id) REFERENCES scr_localidad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2378 (class 2606 OID 18058)
-- Dependencies: 2288 214 221 2591
-- Name: fk_marca_producto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_producto
    ADD CONSTRAINT fk_marca_producto FOREIGN KEY (marca_id) REFERENCES scr_marca_produc(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2374 (class 2606 OID 18063)
-- Dependencies: 2292 216 218 2591
-- Name: fk_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_periodo_representante
    ADD CONSTRAINT fk_organizacion FOREIGN KEY (organizacion_id) REFERENCES scr_organizacion(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2369 (class 2606 OID 18068)
-- Dependencies: 2292 216 208 2591
-- Name: fk_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_linea_estrategica
    ADD CONSTRAINT fk_organizacion FOREIGN KEY (organizacion_id) REFERENCES scr_organizacion(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2346 (class 2606 OID 18073)
-- Dependencies: 164 216 2292 2591
-- Name: fk_organizacion_area_de_trabajo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_area_trabajo
    ADD CONSTRAINT fk_organizacion_area_de_trabajo FOREIGN KEY (organizacion_id) REFERENCES scr_organizacion(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2342 (class 2606 OID 18078)
-- Dependencies: 162 162 2179 2591
-- Name: fk_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_actividad
    ADD CONSTRAINT fk_parent FOREIGN KEY (actividad_id) REFERENCES scr_actividad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2379 (class 2606 OID 18083)
-- Dependencies: 221 219 2298 2591
-- Name: fk_presen_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_producto
    ADD CONSTRAINT fk_presen_product FOREIGN KEY (presentacion_id) REFERENCES scr_presen_produc(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2366 (class 2606 OID 18088)
-- Dependencies: 2314 230 204 2591
-- Name: fk_rep_leg_his_rep_legal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_his_rep_legal
    ADD CONSTRAINT fk_rep_leg_his_rep_legal FOREIGN KEY (representante_legal_id) REFERENCES scr_representante_legal(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2375 (class 2606 OID 18093)
-- Dependencies: 230 218 2314 2591
-- Name: fk_representate_legal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_periodo_representante
    ADD CONSTRAINT fk_representate_legal FOREIGN KEY (representante_legal_id) REFERENCES scr_representante_legal(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2389 (class 2606 OID 18098)
-- Dependencies: 232 243 2316 2591
-- Name: fk_rol; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_usuario_rol
    ADD CONSTRAINT fk_rol FOREIGN KEY (rol_id) REFERENCES scr_rol(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2368 (class 2606 OID 18103)
-- Dependencies: 206 242 2331 2591
-- Name: fk_socio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_lectura
    ADD CONSTRAINT fk_socio FOREIGN KEY (socio_id) REFERENCES scr_usuario(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2360 (class 2606 OID 18108)
-- Dependencies: 196 242 2331 2591
-- Name: fk_socio_factura; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_det_factura
    ADD CONSTRAINT fk_socio_factura FOREIGN KEY (socio_id) REFERENCES scr_usuario(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2383 (class 2606 OID 18113)
-- Dependencies: 233 199 2258 2591
-- Name: fk_solicitado_por; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_rr_ejecucion
    ADD CONSTRAINT fk_solicitado_por FOREIGN KEY (empleado_id) REFERENCES scr_empleado(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2382 (class 2606 OID 18118)
-- Dependencies: 230 2219 179 2591
-- Name: fk_tip_rep_leg_rep_leg; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_representante_legal
    ADD CONSTRAINT fk_tip_rep_leg_rep_leg FOREIGN KEY (cat_rep_legal_id) REFERENCES scr_cat_rep_legal(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2343 (class 2606 OID 18123)
-- Dependencies: 172 162 2197 2591
-- Name: fk_tipo_act_actividad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_actividad
    ADD CONSTRAINT fk_tipo_act_actividad FOREIGN KEY (cat_actividad_id) REFERENCES scr_cat_actividad(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2380 (class 2606 OID 18128)
-- Dependencies: 221 240 2327 2591
-- Name: fk_u_medida_produc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_producto
    ADD CONSTRAINT fk_u_medida_produc FOREIGN KEY (u_medida_id) REFERENCES scr_u_medida_produc(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2381 (class 2606 OID 18133)
-- Dependencies: 228 242 2331 2591
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_recibo
    ADD CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES scr_usuario(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2390 (class 2606 OID 18138)
-- Dependencies: 243 2331 242 2591
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_usuario_rol
    ADD CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES scr_usuario(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2363 (class 2606 OID 18143)
-- Dependencies: 242 2331 199 2591
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scr_empleado
    ADD CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES scr_usuario(id) MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2015-03-03 15:02:30 CST

--
-- PostgreSQL database dump complete
--

