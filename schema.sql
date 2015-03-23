--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.15
-- Dumped by pg_dump version 9.1.15
-- Started on 2015-03-20 14:07:44 CST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2507 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 249 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2508 (class 0 OID 0)
-- Dependencies: 249
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


SET search_path = "public", pg_catalog;

--
-- TOC entry 597 (class 1247 OID 19113)
-- Dependencies: 598 5
-- Name: dominio_email; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN "dominio_email" AS character varying(150)
	CONSTRAINT "dominio_email_check" CHECK (((VALUE)::"text" ~ '^[A-Za-z0-9](([_.-]?[a-zA-Z0-9]+)*)@([A-Za-z0-9]+)(([.-]?[a-zA-Z0-9]+)*).([A-Za-z]{2,})$'::"text"));


--
-- TOC entry 599 (class 1247 OID 19115)
-- Dependencies: 600 5
-- Name: dominio_ip; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN "dominio_ip" AS character varying(15)
	CONSTRAINT "dominio_ip_check" CHECK ((("family"((VALUE)::"inet") = 4) OR ("family"((VALUE)::"inet") = 6)));


--
-- TOC entry 601 (class 1247 OID 19117)
-- Dependencies: 602 5
-- Name: dominio_xml; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN "dominio_xml" AS "text"
	CONSTRAINT "dominio_xml_check" CHECK ((VALUE)::"xml" IS DOCUMENT);


--
-- TOC entry 261 (class 1255 OID 19119)
-- Dependencies: 5 816
-- Name: fcn_actualiza_cuenta(boolean, bigint, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_actualiza_cuenta"(boolean, bigint, double precision) RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 262 (class 1255 OID 19120)
-- Dependencies: 5 816
-- Name: fcn_actualiza_rubro(bigint, bigint, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_actualiza_rubro"(bigint, bigint, double precision) RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 263 (class 1255 OID 19121)
-- Dependencies: 816 5
-- Name: fcn_actualiza_rubro(boolean, bigint, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_actualiza_rubro"(boolean, bigint, double precision) RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 287 (class 1255 OID 19122)
-- Dependencies: 816 5
-- Name: fcn_agrega_transacx(double precision, "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_agrega_transacx"(double precision, "text") RETURNS integer
    LANGUAGE "plpgsql"
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
-- TOC entry 285 (class 1255 OID 19123)
-- Dependencies: 5 816
-- Name: fcn_agrega_transacx_pago(double precision, "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_agrega_transacx_pago"(double precision, "text") RETURNS integer
    LANGUAGE "plpgsql"
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
-- TOC entry 286 (class 1255 OID 19124)
-- Dependencies: 816 5
-- Name: fcn_det_factura(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_det_factura"() RETURNS bigint
    LANGUAGE "plpgsql"
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
  FOR p IN SELECT * FROM scr_usuario AS u, scr_usuario_rol AS ro WHERE u.id = ro.usuario_id AND ro.rol_id=1 AND u.estado_id = 1 ORDER BY u.localidad_id
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
-- TOC entry 264 (class 1255 OID 19125)
-- Dependencies: 816 5
-- Name: fcn_det_factura(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_det_factura"(bigint) RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 265 (class 1255 OID 19126)
-- Dependencies: 816 5
-- Name: fcn_es_subcuenta(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_es_subcuenta"(bigint) RETURNS boolean
    LANGUAGE "plpgsql"
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
-- TOC entry 266 (class 1255 OID 19127)
-- Dependencies: 816 5
-- Name: fcn_find_nodoXML("text", "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_find_nodoXML"("text", "text") RETURNS "text"
    LANGUAGE "plpgsql"
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
-- TOC entry 268 (class 1255 OID 19128)
-- Dependencies: 5 816
-- Name: fcn_genera_transaccion("text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_genera_transaccion"("text") RETURNS boolean
    LANGUAGE "plpgsql"
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
-- TOC entry 269 (class 1255 OID 19129)
-- Dependencies: 816 5
-- Name: fcn_get_nodoXML("text", "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_get_nodoXML"("text", "text") RETURNS "text"
    LANGUAGE "plpgsql"
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
-- TOC entry 270 (class 1255 OID 19130)
-- Dependencies: 816 5
-- Name: fcn_pago_factura(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_pago_factura"(bigint) RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 271 (class 1255 OID 19131)
-- Dependencies: 5 816
-- Name: fcn_periodo("date"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_periodo"("date") RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 272 (class 1255 OID 19132)
-- Dependencies: 5 816
-- Name: fcn_sec_transacx("date"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_sec_transacx"("date") RETURNS bigint
    LANGUAGE "plpgsql"
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
-- TOC entry 273 (class 1255 OID 19133)
-- Dependencies: 5 816
-- Name: fcn_xml2data("text", "text"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "fcn_xml2data"("text", "text") RETURNS "text"
    LANGUAGE "plpgsql"
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
-- TOC entry 284 (class 1255 OID 20034)
-- Dependencies: 5 816
-- Name: getallfoo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "getallfoo"() RETURNS integer
    LANGUAGE "plpgsql"
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
-- TOC entry 283 (class 1255 OID 19134)
-- Dependencies: 816 5
-- Name: tgr_actualiza_contador(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_actualiza_contador"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 267 (class 1255 OID 19135)
-- Dependencies: 5 816
-- Name: tgr_actualiza_cuenta(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_actualiza_cuenta"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 274 (class 1255 OID 19136)
-- Dependencies: 816 5
-- Name: tgr_actualiza_rubro(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_actualiza_rubro"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 275 (class 1255 OID 19137)
-- Dependencies: 5 816
-- Name: tgr_agrega_costo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_agrega_costo"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 281 (class 1255 OID 20011)
-- Dependencies: 816 5
-- Name: tgr_asigna_contador(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_asigna_contador"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 276 (class 1255 OID 19138)
-- Dependencies: 816 5
-- Name: tgr_gestion_transacx(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_gestion_transacx"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 277 (class 1255 OID 19139)
-- Dependencies: 816 5
-- Name: tgr_inhabilita_mod_transax(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_inhabilita_mod_transax"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 278 (class 1255 OID 19140)
-- Dependencies: 5 816
-- Name: tgr_verifica_activo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_verifica_activo"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 279 (class 1255 OID 19141)
-- Dependencies: 5 816
-- Name: tgr_verifica_cod_cuenta(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_verifica_cod_cuenta"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 280 (class 1255 OID 19142)
-- Dependencies: 5 816
-- Name: tgr_verifica_tcontable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_verifica_tcontable"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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
-- TOC entry 282 (class 1255 OID 19143)
-- Dependencies: 5 816
-- Name: tgr_verificar_tiempo_act(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION "tgr_verificar_tiempo_act"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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


SET default_with_oids = false;

--
-- TOC entry 161 (class 1259 OID 19144)
-- Dependencies: 5
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "schema_migrations" (
    "version" character varying(255) NOT NULL
);


--
-- TOC entry 162 (class 1259 OID 19147)
-- Dependencies: 2079 2080 2082 2083 5
-- Name: scr_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_actividad" (
    "id" bigint NOT NULL,
    "actividadNombre" character varying(150) NOT NULL,
    "actividadDescripcion" "text",
    "actividadInicio" "date" NOT NULL,
    "actividadFin" "date" NOT NULL,
    "actividadPresupuesto" double precision DEFAULT 0 NOT NULL,
    "actividad_id" bigint,
    "cat_actividad_id" bigint NOT NULL,
    "actividadEjecutado" numeric(3,2) DEFAULT 0 NOT NULL,
    "proyecto_id" bigint NOT NULL,
    CONSTRAINT "CK_actividad_ejecutado" CHECK ((("actividadEjecutado" >= (0)::numeric) AND ("actividadEjecutado" <= (100)::numeric))),
    CONSTRAINT "CK_valor_actividad" CHECK (("actividadPresupuesto" > (0)::double precision))
);


--
-- TOC entry 2509 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "scr_actividad"."actividadPresupuesto"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "scr_actividad"."actividadPresupuesto" IS 'presupuesto';


--
-- TOC entry 163 (class 1259 OID 19157)
-- Dependencies: 162 5
-- Name: scr_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_actividad_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2510 (class 0 OID 0)
-- Dependencies: 163
-- Name: scr_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_actividad_id_seq" OWNED BY "scr_actividad"."id";


--
-- TOC entry 164 (class 1259 OID 19159)
-- Dependencies: 5
-- Name: scr_area_trabajo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_area_trabajo" (
    "id" bigint NOT NULL,
    "aTrabajoNombre" character varying(150) NOT NULL,
    "aTrabajoDescripcion" "text",
    "area_trabajo_id" bigint,
    "organizacion_id" bigint NOT NULL,
    "cargo_id" bigint NOT NULL
);


--
-- TOC entry 165 (class 1259 OID 19165)
-- Dependencies: 164 5
-- Name: scr_area_de_trabajo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_area_de_trabajo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2511 (class 0 OID 0)
-- Dependencies: 165
-- Name: scr_area_de_trabajo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_area_de_trabajo_id_seq" OWNED BY "scr_area_trabajo"."id";


--
-- TOC entry 166 (class 1259 OID 19167)
-- Dependencies: 5
-- Name: scr_banco; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_banco" (
    "id" bigint NOT NULL,
    "banco_nombre" character varying(100) NOT NULL
);


--
-- TOC entry 167 (class 1259 OID 19170)
-- Dependencies: 166 5
-- Name: scr_banco_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_banco_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2512 (class 0 OID 0)
-- Dependencies: 167
-- Name: scr_banco_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_banco_id_seq" OWNED BY "scr_banco"."id";


--
-- TOC entry 168 (class 1259 OID 19172)
-- Dependencies: 2086 2087 2088 2089 2090 2091 5
-- Name: scr_bombeo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_bombeo" (
    "id" bigint NOT NULL,
    "fecha" "date" DEFAULT ('now'::"text")::"date" NOT NULL,
    "bombeo_inicio" time without time zone NOT NULL,
    "bombeo_fin" time without time zone NOT NULL,
    "voltaje" double precision DEFAULT 0 NOT NULL,
    "amperaje" double precision DEFAULT 0 NOT NULL,
    "presion" double precision DEFAULT 0 NOT NULL,
    "lectura" double precision DEFAULT 0 NOT NULL,
    "produccion" double precision DEFAULT 0 NOT NULL,
    "empleado_id" bigint NOT NULL
)
WITH (autovacuum_enabled=true);


--
-- TOC entry 169 (class 1259 OID 19181)
-- Dependencies: 5 168
-- Name: scr_bombeo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_bombeo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2513 (class 0 OID 0)
-- Dependencies: 169
-- Name: scr_bombeo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_bombeo_id_seq" OWNED BY "scr_bombeo"."id";


--
-- TOC entry 170 (class 1259 OID 19183)
-- Dependencies: 2093 2095 5
-- Name: scr_cargo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cargo" (
    "id" bigint NOT NULL,
    "cargoNombre" character varying(150) NOT NULL,
    "cargoDescripcion" "text",
    "cargoSalario" double precision DEFAULT 1 NOT NULL,
    "cargo_id" bigint,
    CONSTRAINT "CK_cargoSalario" CHECK (("cargoSalario" > (1)::double precision))
);


--
-- TOC entry 171 (class 1259 OID 19191)
-- Dependencies: 5 170
-- Name: scr_cargo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_cargo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 171
-- Name: scr_cargo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_cargo_id_seq" OWNED BY "scr_cargo"."id";


--
-- TOC entry 172 (class 1259 OID 19193)
-- Dependencies: 5
-- Name: scr_cat_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_actividad" (
    "id" bigint NOT NULL,
    "cActividadNombre" character varying(150) NOT NULL,
    "catActividadDescripcion" "text"
);


--
-- TOC entry 173 (class 1259 OID 19199)
-- Dependencies: 172 5
-- Name: scr_tipo_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_tipo_actividad_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 173
-- Name: scr_tipo_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_tipo_actividad_id_seq" OWNED BY "scr_cat_actividad"."id";


--
-- TOC entry 174 (class 1259 OID 19201)
-- Dependencies: 2097 5
-- Name: scr_cat_cobro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_cobro" (
    "id" bigint DEFAULT "nextval"('"scr_tipo_actividad_id_seq"'::"regclass") NOT NULL,
    "cCobroNombre" character varying(150) NOT NULL,
    "cCobroDescripcion" "text"
);


--
-- TOC entry 175 (class 1259 OID 19208)
-- Dependencies: 5
-- Name: scr_cat_cooperante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_cooperante" (
    "id" bigint NOT NULL,
    "catCoopNombre" character varying(100) NOT NULL,
    "catCoopDescrip" "text"
);


--
-- TOC entry 176 (class 1259 OID 19214)
-- Dependencies: 5
-- Name: scr_cat_depreciacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_depreciacion" (
    "id" bigint NOT NULL,
    "depreciacionNombre" character varying(100) NOT NULL,
    "depreciacionDescripcion" "text"
);


--
-- TOC entry 177 (class 1259 OID 19220)
-- Dependencies: 5
-- Name: scr_cat_organizacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_organizacion" (
    "id" bigint NOT NULL,
    "cOrgNombre" character varying(150) NOT NULL,
    "cOrgDescripcion" "text"
);


--
-- TOC entry 178 (class 1259 OID 19226)
-- Dependencies: 5
-- Name: scr_cat_produc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_produc" (
    "id" bigint NOT NULL,
    "catProducNombre" character varying(100) NOT NULL,
    "catProducDescrip" "text"
);


--
-- TOC entry 179 (class 1259 OID 19232)
-- Dependencies: 2102 2103 5
-- Name: scr_cat_rep_legal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cat_rep_legal" (
    "id" bigint NOT NULL,
    "catRLegalNombre" character varying(150) NOT NULL,
    "catRLegalDescripcion" "text",
    "catRLegalRegistro" timestamp without time zone DEFAULT "now"() NOT NULL,
    "catRLegalFirma" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 2516 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "scr_cat_rep_legal"."catRLegalFirma"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "scr_cat_rep_legal"."catRLegalFirma" IS 'Usuario habilitado para firmar estados financieros';


--
-- TOC entry 180 (class 1259 OID 19240)
-- Dependencies: 5
-- Name: scr_cheq_recurso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cheq_recurso" (
    "id" bigint NOT NULL,
    "cheq_rr_codigo" bigint NOT NULL,
    "cheq_rr_quien_recibe" character varying(100) NOT NULL,
    "cheq_rr_fecha_emision" timestamp without time zone NOT NULL,
    "cheq_rr_fecha_vence" timestamp without time zone NOT NULL,
    "chequera_id" bigint NOT NULL
);


--
-- TOC entry 181 (class 1259 OID 19243)
-- Dependencies: 180 5
-- Name: scr_cheq_recurso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_cheq_recurso_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2517 (class 0 OID 0)
-- Dependencies: 181
-- Name: scr_cheq_recurso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_cheq_recurso_id_seq" OWNED BY "scr_cheq_recurso"."id";


--
-- TOC entry 182 (class 1259 OID 19245)
-- Dependencies: 5
-- Name: scr_chequera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_chequera" (
    "id" bigint NOT NULL,
    "chequera_correlativo" bigint NOT NULL,
    "banco_id" bigint
);


--
-- TOC entry 183 (class 1259 OID 19248)
-- Dependencies: 182 5
-- Name: scr_chequera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_chequera_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2518 (class 0 OID 0)
-- Dependencies: 183
-- Name: scr_chequera_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_chequera_id_seq" OWNED BY "scr_chequera"."id";


--
-- TOC entry 184 (class 1259 OID 19250)
-- Dependencies: 2107 2109 5
-- Name: scr_cloracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cloracion" (
    "id" bigint NOT NULL,
    "fecha" "date" NOT NULL,
    "hora" time without time zone NOT NULL,
    "gramos" double precision NOT NULL,
    "localidad_id" bigint NOT NULL,
    "empleado_id" bigint NOT NULL,
    "observacion" "text" DEFAULT 'ninguna'::"text" NOT NULL,
    CONSTRAINT "CK_gramos_positivos" CHECK (("gramos" >= (0)::double precision))
)
WITH (autovacuum_enabled=true);


--
-- TOC entry 185 (class 1259 OID 19258)
-- Dependencies: 5 184
-- Name: scr_cloracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_cloracion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2519 (class 0 OID 0)
-- Dependencies: 185
-- Name: scr_cloracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_cloracion_id_seq" OWNED BY "scr_cloracion"."id";


--
-- TOC entry 186 (class 1259 OID 19260)
-- Dependencies: 2110 2111 5
-- Name: scr_cobro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cobro" (
    "id" bigint NOT NULL,
    "cobroNombre" character varying(150) NOT NULL,
    "cobroCodigo" character varying(10) NOT NULL,
    "cobroDescripcion" "text",
    "cobroInicio" double precision NOT NULL,
    "cobroFin" double precision NOT NULL,
    "cobroValor" double precision DEFAULT 0 NOT NULL,
    "cobroPermanente" boolean DEFAULT false NOT NULL,
    "cat_cobro_id" bigint NOT NULL
);


--
-- TOC entry 187 (class 1259 OID 19268)
-- Dependencies: 186 5
-- Name: scr_cobro_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_cobro_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 187
-- Name: scr_cobro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_cobro_id_seq" OWNED BY "scr_cobro"."id";


--
-- TOC entry 188 (class 1259 OID 19270)
-- Dependencies: 2113 2114 5
-- Name: scr_consumo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_consumo" (
    "id" bigint NOT NULL,
    "registro" timestamp without time zone DEFAULT "now"() NOT NULL,
    "cantidad" double precision DEFAULT 0 NOT NULL,
    "cobro_id" bigint NOT NULL,
    "factura_id" bigint NOT NULL
);


--
-- TOC entry 189 (class 1259 OID 19275)
-- Dependencies: 188 5
-- Name: scr_consumo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_consumo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2521 (class 0 OID 0)
-- Dependencies: 189
-- Name: scr_consumo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_consumo_id_seq" OWNED BY "scr_consumo"."id";


--
-- TOC entry 190 (class 1259 OID 19277)
-- Dependencies: 5
-- Name: scr_cooperante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cooperante" (
    "id" bigint NOT NULL,
    "cooperanteNombre" character varying(100) NOT NULL,
    "cooperanteDescripcion" "text",
    "catCooperante_id" bigint NOT NULL
);


--
-- TOC entry 191 (class 1259 OID 19283)
-- Dependencies: 5 190
-- Name: scr_cooperante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_cooperante_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2522 (class 0 OID 0)
-- Dependencies: 191
-- Name: scr_cooperante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_cooperante_id_seq" OWNED BY "scr_cooperante"."id";


--
-- TOC entry 192 (class 1259 OID 19285)
-- Dependencies: 2117 2118 2119 2120 2121 2122 2124 5
-- Name: scr_cuenta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_cuenta" (
    "id" bigint NOT NULL,
    "cuentaNombre" character varying(150) NOT NULL,
    "cuentaRegistro" timestamp without time zone DEFAULT ('now'::"text")::timestamp(0) without time zone NOT NULL,
    "cuentaDebe" double precision DEFAULT 0 NOT NULL,
    "cuentaHaber" double precision DEFAULT 0 NOT NULL,
    "cat_cuenta_id" integer,
    "cuentaActivo" boolean DEFAULT false NOT NULL,
    "cuentaCodigo" bigint DEFAULT 0 NOT NULL,
    "cuentaDescripcion" "text",
    "cuentaNegativa" boolean DEFAULT false NOT NULL,
    CONSTRAINT "CK_valores_positivos" CHECK (((("cuentaDebe" >= (0)::double precision) AND ("cuentaHaber" >= (0)::double precision)) AND ("cuentaCodigo" > (0)::bigint)))
);


--
-- TOC entry 193 (class 1259 OID 19298)
-- Dependencies: 5 192
-- Name: scr_cuenta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_cuenta_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2523 (class 0 OID 0)
-- Dependencies: 193
-- Name: scr_cuenta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_cuenta_id_seq" OWNED BY "scr_cuenta"."id";


--
-- TOC entry 194 (class 1259 OID 19300)
-- Dependencies: 2125 2126 2127 2129 2130 5
-- Name: scr_det_contable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_det_contable" (
    "id" bigint NOT NULL,
    "dConIniPeriodo" "date" NOT NULL,
    "dConFinPeriodo" "date" NOT NULL,
    "dConActivo" boolean DEFAULT false NOT NULL,
    "dConSimboloMoneda" character varying(3) DEFAULT '$'::character varying NOT NULL,
    "dConPagoXMes" smallint DEFAULT 1 NOT NULL,
    "organizacion_id" bigint NOT NULL,
    "empleado_id" bigint NOT NULL,
    CONSTRAINT "CK_fechasValidas" CHECK (("dConIniPeriodo" < "dConFinPeriodo")),
    CONSTRAINT "CK_pagos_x_mes" CHECK (("dConPagoXMes" > 0))
);


--
-- TOC entry 2524 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "scr_det_contable"."dConIniPeriodo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "scr_det_contable"."dConIniPeriodo" IS 'Inicio de periodo contable';


--
-- TOC entry 2525 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "scr_det_contable"."dConFinPeriodo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "scr_det_contable"."dConFinPeriodo" IS 'Fin de periodo contable';


--
-- TOC entry 2526 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "scr_det_contable"."dConActivo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "scr_det_contable"."dConActivo" IS 'activo mientras no se cierra el periodo contable';


--
-- TOC entry 2527 (class 0 OID 0)
-- Dependencies: 194
-- Name: CONSTRAINT "CK_fechasValidas" ON "scr_det_contable"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT "CK_fechasValidas" ON "scr_det_contable" IS 'Verifica que el fin no sea menor a inicio y que el inicio no sea menor a un fin ya registrado.';


--
-- TOC entry 195 (class 1259 OID 19308)
-- Dependencies: 5
-- Name: scr_factura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_factura_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


--
-- TOC entry 196 (class 1259 OID 19310)
-- Dependencies: 2131 2132 2133 2134 5
-- Name: scr_det_factura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_det_factura" (
    "id" bigint NOT NULL,
    "det_factur_numero" bigint DEFAULT "nextval"('"scr_factura_id_seq"'::"regclass") NOT NULL,
    "det_factur_fecha" timestamp without time zone DEFAULT "now"() NOT NULL,
    "socio_id" bigint NOT NULL,
    "cancelada" boolean DEFAULT false NOT NULL,
    "fecha_cancelada" timestamp without time zone,
    "total" double precision DEFAULT 0 NOT NULL,
    "limite_pago" "date" NOT NULL
)
WITH (autovacuum_enabled=true);


--
-- TOC entry 197 (class 1259 OID 19317)
-- Dependencies: 196 5
-- Name: scr_det_factura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_det_factura_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2528 (class 0 OID 0)
-- Dependencies: 197
-- Name: scr_det_factura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_det_factura_id_seq" OWNED BY "scr_det_factura"."id";


--
-- TOC entry 198 (class 1259 OID 19319)
-- Dependencies: 194 5
-- Name: scr_detalle_org_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_detalle_org_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2529 (class 0 OID 0)
-- Dependencies: 198
-- Name: scr_detalle_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_detalle_org_id_seq" OWNED BY "scr_det_contable"."id";


--
-- TOC entry 199 (class 1259 OID 19321)
-- Dependencies: 2136 2137 5 597
-- Name: scr_empleado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_empleado" (
    "id" bigint NOT NULL,
    "empleadoNombre" character varying(150) NOT NULL,
    "empleadoApellido" character varying(150) NOT NULL,
    "empleadoTelefono" bigint NOT NULL,
    "empleadoCelular" bigint,
    "empleadoDireccion" "text" NOT NULL,
    "empleadoDui" bigint NOT NULL,
    "empleadoIsss" bigint NOT NULL,
    "empleadoRegistro" timestamp without time zone DEFAULT "now"() NOT NULL,
    "empleadoFechaIngreso" "date" NOT NULL,
    "cargo_id" bigint NOT NULL,
    "empleadoEmail" "dominio_email" NOT NULL,
    "empleadoNit" bigint NOT NULL,
    "localidad_id" bigint NOT NULL,
    "usuario_id" bigint DEFAULT 1 NOT NULL
);


--
-- TOC entry 2530 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "scr_empleado"."empleadoRegistro"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "scr_empleado"."empleadoRegistro" IS 'fecha de registro en el sistema';


--
-- TOC entry 200 (class 1259 OID 19329)
-- Dependencies: 5
-- Name: scr_empleado_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_empleado_actividad" (
    "empleado_id" bigint NOT NULL,
    "actividad_id" bigint NOT NULL
);


--
-- TOC entry 201 (class 1259 OID 19332)
-- Dependencies: 5 199
-- Name: scr_empleado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_empleado_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2531 (class 0 OID 0)
-- Dependencies: 201
-- Name: scr_empleado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_empleado_id_seq" OWNED BY "scr_empleado"."id";


--
-- TOC entry 202 (class 1259 OID 19334)
-- Dependencies: 5
-- Name: scr_estado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_estado" (
    "id" bigint NOT NULL,
    "nombreEstado" character varying(150) NOT NULL
);


--
-- TOC entry 203 (class 1259 OID 19337)
-- Dependencies: 5 202
-- Name: scr_estado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_estado_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2532 (class 0 OID 0)
-- Dependencies: 203
-- Name: scr_estado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_estado_id_seq" OWNED BY "scr_estado"."id";


--
-- TOC entry 204 (class 1259 OID 19339)
-- Dependencies: 5
-- Name: scr_his_rep_legal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_his_rep_legal" (
    "id" bigint NOT NULL,
    "his_rep_leg_nombre" character varying(150) NOT NULL,
    "his_rep_leg_apellido" character varying(150) NOT NULL,
    "his_rep_leg_telefono" bigint NOT NULL,
    "his_rep_leg_celular" bigint,
    "his_rep_leg_email" character varying(100),
    "his_rep_leg_direccion" character varying(200) NOT NULL,
    "his_rep_leg_fecha_registro" timestamp without time zone NOT NULL,
    "representante_legal_id" bigint NOT NULL
);


--
-- TOC entry 205 (class 1259 OID 19345)
-- Dependencies: 204 5
-- Name: scr_historial_representante_legal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_historial_representante_legal_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2533 (class 0 OID 0)
-- Dependencies: 205
-- Name: scr_historial_representante_legal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_historial_representante_legal_id_seq" OWNED BY "scr_his_rep_legal"."id";


--
-- TOC entry 206 (class 1259 OID 19347)
-- Dependencies: 2141 5
-- Name: scr_lectura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_lectura" (
    "id" bigint NOT NULL,
    "valorLectura" character varying(150) NOT NULL,
    "fechaLectura" "date" NOT NULL,
    "registroLectura" timestamp without time zone DEFAULT ('now'::"text")::"date" NOT NULL,
    "socio_id" bigint NOT NULL,
    "tecnico_id" bigint NOT NULL
);


--
-- TOC entry 207 (class 1259 OID 19351)
-- Dependencies: 206 5
-- Name: scr_lectura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_lectura_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2534 (class 0 OID 0)
-- Dependencies: 207
-- Name: scr_lectura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_lectura_id_seq" OWNED BY "scr_lectura"."id";


--
-- TOC entry 208 (class 1259 OID 19353)
-- Dependencies: 2143 2145 5
-- Name: scr_linea_estrategica; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_linea_estrategica" (
    "id" bigint NOT NULL,
    "organizacion_id" bigint NOT NULL,
    "lEstrategicaNombre" character varying(150) NOT NULL,
    "lEstrategicaDescripcion" "text",
    "lEstrategicaInicio" "date" DEFAULT "now"() NOT NULL,
    "lEstrategicaFin" "date" NOT NULL,
    "linea_estrategica_id" bigint,
    CONSTRAINT "CK_periodo_lEstrategica" CHECK (("lEstrategicaFin" > "lEstrategicaInicio"))
);


--
-- TOC entry 209 (class 1259 OID 19361)
-- Dependencies: 5 208
-- Name: scr_lin_estrateg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_lin_estrateg_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2535 (class 0 OID 0)
-- Dependencies: 209
-- Name: scr_lin_estrateg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_lin_estrateg_id_seq" OWNED BY "scr_linea_estrategica"."id";


--
-- TOC entry 210 (class 1259 OID 19363)
-- Dependencies: 5
-- Name: scr_linea_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_linea_proyecto" (
    "linea_estrategica_id" bigint NOT NULL,
    "proyecto_id" bigint NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 19366)
-- Dependencies: 5
-- Name: scr_localidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_localidad" (
    "id" bigint NOT NULL,
    "localidad_nombre" character varying(150) NOT NULL,
    "localidad_descripcion" "text",
    "localidad_id" bigint,
    "localidad_lat" double precision NOT NULL,
    "localidad_lon" double precision NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 19372)
-- Dependencies: 5 211
-- Name: scr_localidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_localidad_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2536 (class 0 OID 0)
-- Dependencies: 212
-- Name: scr_localidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_localidad_id_seq" OWNED BY "scr_localidad"."id";


--
-- TOC entry 213 (class 1259 OID 19374)
-- Dependencies: 5
-- Name: scr_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_log" (
    "id" bigint NOT NULL,
    "src_fecha" timestamp without time zone NOT NULL,
    "src_descripcion" "text" NOT NULL,
    "usuario_id" bigint NOT NULL
);


--
-- TOC entry 214 (class 1259 OID 19380)
-- Dependencies: 5
-- Name: scr_marca_produc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_marca_produc" (
    "id" bigint NOT NULL,
    "marcaProducNombre" character varying(100) NOT NULL,
    "marcaProducDescrip" "text"
);


--
-- TOC entry 215 (class 1259 OID 19386)
-- Dependencies: 214 5
-- Name: scr_marca_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_marca_produc_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2537 (class 0 OID 0)
-- Dependencies: 215
-- Name: scr_marca_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_marca_produc_id_seq" OWNED BY "scr_marca_produc"."id";


--
-- TOC entry 216 (class 1259 OID 19388)
-- Dependencies: 5
-- Name: scr_organizacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_organizacion" (
    "id" bigint NOT NULL,
    "organizacionNombre" character varying(150) NOT NULL,
    "organizacionDescripcion" "text",
    "localidad_id" bigint NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 19394)
-- Dependencies: 216 5
-- Name: scr_organizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_organizacion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2538 (class 0 OID 0)
-- Dependencies: 217
-- Name: scr_organizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_organizacion_id_seq" OWNED BY "scr_organizacion"."id";


--
-- TOC entry 218 (class 1259 OID 19396)
-- Dependencies: 2150 2151 2152 5
-- Name: scr_periodo_representante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_periodo_representante" (
    "organizacion_id" bigint NOT NULL,
    "representante_legal_id" bigint NOT NULL,
    "periodoInicio" "date" DEFAULT "now"() NOT NULL,
    "periodoFin" "date" NOT NULL,
    CONSTRAINT "CK_periodo_dentro" CHECK ((("date_part"('month'::"text", "age"(("periodoFin")::timestamp without time zone, ("periodoInicio")::timestamp without time zone)) > (1)::double precision) AND ("date_part"('month'::"text", "age"(("periodoFin")::timestamp without time zone, ("periodoInicio")::timestamp without time zone)) < (12)::double precision))),
    CONSTRAINT "CK_periodo_valido" CHECK (("periodoInicio" < "periodoFin"))
);


--
-- TOC entry 219 (class 1259 OID 19402)
-- Dependencies: 5
-- Name: scr_presen_produc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_presen_produc" (
    "id" bigint NOT NULL,
    "presenProducNombre" character varying(100) NOT NULL,
    "presenProducDescrip" "text"
);


--
-- TOC entry 220 (class 1259 OID 19408)
-- Dependencies: 5 219
-- Name: scr_presen_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_presen_produc_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2539 (class 0 OID 0)
-- Dependencies: 220
-- Name: scr_presen_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_presen_produc_id_seq" OWNED BY "scr_presen_produc"."id";


--
-- TOC entry 221 (class 1259 OID 19410)
-- Dependencies: 5
-- Name: scr_producto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_producto" (
    "id" bigint NOT NULL,
    "productoNombre" character varying(100) NOT NULL,
    "productoDescripcion" "text",
    "marca_id" bigint NOT NULL,
    "catProduc_id" bigint NOT NULL,
    "u_medida_id" bigint NOT NULL,
    "presentacion_id" bigint NOT NULL,
    "catDepresiacion_id" bigint NOT NULL,
    "productoComprobante" character varying(100) NOT NULL,
    "proveedor_id" bigint NOT NULL,
    "productoCodigo" "text" NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 19416)
-- Dependencies: 5
-- Name: scr_producto_area; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_producto_area" (
    "producto_id" bigint NOT NULL,
    "areaTrabajo_id" bigint NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 19419)
-- Dependencies: 221 5
-- Name: scr_producto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_producto_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2540 (class 0 OID 0)
-- Dependencies: 223
-- Name: scr_producto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_producto_id_seq" OWNED BY "scr_producto"."id";


--
-- TOC entry 224 (class 1259 OID 19421)
-- Dependencies: 5
-- Name: scr_proveedor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_proveedor" (
    "id" bigint NOT NULL,
    "proveedorNombre" character varying(100) NOT NULL,
    "proveedorDescripcion" "text"
);


--
-- TOC entry 225 (class 1259 OID 19427)
-- Dependencies: 224 5
-- Name: scr_proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_proveedor_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2541 (class 0 OID 0)
-- Dependencies: 225
-- Name: scr_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_proveedor_id_seq" OWNED BY "scr_proveedor"."id";


--
-- TOC entry 226 (class 1259 OID 19429)
-- Dependencies: 5
-- Name: scr_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_proyecto" (
    "id" bigint NOT NULL,
    "proyectoNombre" character varying(100) NOT NULL,
    "proyectoDescrip" "text",
    "cooperante_id" bigint NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 19435)
-- Dependencies: 226 5
-- Name: scr_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_proyecto_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2542 (class 0 OID 0)
-- Dependencies: 227
-- Name: scr_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_proyecto_id_seq" OWNED BY "scr_proyecto"."id";


--
-- TOC entry 228 (class 1259 OID 19437)
-- Dependencies: 5
-- Name: scr_recibo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_recibo" (
    "id" bigint NOT NULL,
    "recibonumero" bigint NOT NULL,
    "recibocuenta" bigint NOT NULL,
    "recibosocio" "text" NOT NULL,
    "recibolecturax" "text" NOT NULL,
    "recibolecturay" "text" NOT NULL,
    "recibofecha" timestamp without time zone NOT NULL,
    "usuario_id" bigint NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 19443)
-- Dependencies: 5 228
-- Name: scr_recibo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_recibo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2543 (class 0 OID 0)
-- Dependencies: 229
-- Name: scr_recibo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_recibo_id_seq" OWNED BY "scr_recibo"."id";


--
-- TOC entry 230 (class 1259 OID 19445)
-- Dependencies: 2158 5 597
-- Name: scr_representante_legal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_representante_legal" (
    "id" bigint NOT NULL,
    "rLegalNombre" character varying(150) NOT NULL,
    "rLegalApellido" character varying(150) NOT NULL,
    "rLegalTelefono" bigint NOT NULL,
    "rLegalCelular" bigint,
    "rLegalDireccion" "text" NOT NULL,
    "rLegalRegistro" timestamp without time zone DEFAULT "now"() NOT NULL,
    "cat_rep_legal_id" bigint NOT NULL,
    "rLegalemail" "dominio_email" NOT NULL
);


--
-- TOC entry 231 (class 1259 OID 19452)
-- Dependencies: 5 230
-- Name: scr_representate_legal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_representate_legal_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2544 (class 0 OID 0)
-- Dependencies: 231
-- Name: scr_representate_legal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_representate_legal_id_seq" OWNED BY "scr_representante_legal"."id";


--
-- TOC entry 232 (class 1259 OID 19454)
-- Dependencies: 5
-- Name: scr_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_rol" (
    "id" integer NOT NULL,
    "nombrerol" character varying(75) NOT NULL,
    "detallerol" "text"
);


--
-- TOC entry 233 (class 1259 OID 19460)
-- Dependencies: 5
-- Name: scr_rr_ejecucion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_rr_ejecucion" (
    "id" bigint NOT NULL,
    "solic_rr_id" bigint NOT NULL,
    "empleado_id" bigint NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 19463)
-- Dependencies: 233 5
-- Name: scr_rr_ejecucion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_rr_ejecucion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2545 (class 0 OID 0)
-- Dependencies: 234
-- Name: scr_rr_ejecucion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_rr_ejecucion_id_seq" OWNED BY "scr_rr_ejecucion"."id";


--
-- TOC entry 235 (class 1259 OID 19465)
-- Dependencies: 176 5
-- Name: scr_tip_depresiacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_tip_depresiacion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2546 (class 0 OID 0)
-- Dependencies: 235
-- Name: scr_tip_depresiacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_tip_depresiacion_id_seq" OWNED BY "scr_cat_depreciacion"."id";


--
-- TOC entry 236 (class 1259 OID 19467)
-- Dependencies: 5 175
-- Name: scr_tipo_cooperante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_tipo_cooperante_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2547 (class 0 OID 0)
-- Dependencies: 236
-- Name: scr_tipo_cooperante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_tipo_cooperante_id_seq" OWNED BY "scr_cat_cooperante"."id";


--
-- TOC entry 237 (class 1259 OID 19469)
-- Dependencies: 5 178
-- Name: scr_tipo_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_tipo_produc_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2548 (class 0 OID 0)
-- Dependencies: 237
-- Name: scr_tipo_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_tipo_produc_id_seq" OWNED BY "scr_cat_produc"."id";


--
-- TOC entry 238 (class 1259 OID 19471)
-- Dependencies: 2162 2163 2164 2165 2166 2168 2169 5
-- Name: scr_transaccion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_transaccion" (
    "id" bigint NOT NULL,
    "transaxSecuencia" bigint NOT NULL,
    "cuenta_id" bigint NOT NULL,
    "transaxMonto" double precision DEFAULT 0 NOT NULL,
    "transaxDebeHaber" boolean DEFAULT true NOT NULL,
    "empleado_id" bigint NOT NULL,
    "transaxRegistro" timestamp without time zone DEFAULT ('now'::"text")::timestamp(0) without time zone NOT NULL,
    "transaxFecha" "date" NOT NULL,
    "pcontable_id" bigint NOT NULL,
    "activa" boolean DEFAULT true NOT NULL,
    "comentario" "text" DEFAULT 'Sin detalle'::"text",
    "transaxImg" "text",
    CONSTRAINT "CK_monto_positivo" CHECK (("transaxMonto" > (0)::double precision)),
    CONSTRAINT "CK_secuencia_positiva" CHECK (("transaxSecuencia" > 0))
);


--
-- TOC entry 239 (class 1259 OID 19484)
-- Dependencies: 5 238
-- Name: scr_transaccion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_transaccion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2549 (class 0 OID 0)
-- Dependencies: 239
-- Name: scr_transaccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_transaccion_id_seq" OWNED BY "scr_transaccion"."id";


--
-- TOC entry 240 (class 1259 OID 19486)
-- Dependencies: 5
-- Name: scr_u_medida_produc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_u_medida_produc" (
    "id" bigint NOT NULL,
    "uMedidaProducNombre" character varying(100) NOT NULL,
    "uMedidaProducDescrip" "text"
);


--
-- TOC entry 241 (class 1259 OID 19492)
-- Dependencies: 240 5
-- Name: scr_u_medida_produc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "scr_u_medida_produc_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2550 (class 0 OID 0)
-- Dependencies: 241
-- Name: scr_u_medida_produc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "scr_u_medida_produc_id_seq" OWNED BY "scr_u_medida_produc"."id";


--
-- TOC entry 242 (class 1259 OID 19494)
-- Dependencies: 2171 2172 2173 2174 2176 2177 597 5 599 601
-- Name: scr_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_usuario" (
    "id" bigint NOT NULL,
    "username" character varying(50) NOT NULL,
    "password" "text" NOT NULL,
    "correousuario" "dominio_email" NOT NULL,
    "detalleuuario" "text",
    "ultimavisitausuario" timestamp without time zone DEFAULT ('now'::"text")::timestamp(0) without time zone NOT NULL,
    "ipusuario" "dominio_ip" DEFAULT '127.0.0.1'::character varying NOT NULL,
    "salt" "text" NOT NULL,
    "nombreusuario" character varying(150) NOT NULL,
    "apellidousuario" character varying(150) NOT NULL,
    "telefonousuario" bigint NOT NULL,
    "nacimientousuario" "date",
    "latusuario" double precision NOT NULL,
    "lonusuario" double precision NOT NULL,
    "direccionusuario" "text",
    "sexousuario" numeric(1,0) DEFAULT 0 NOT NULL,
    "registrousuario" timestamp without time zone DEFAULT ('now'::"text")::timestamp(0) without time zone NOT NULL,
    "cuentausuario" "dominio_xml" DEFAULT '<cuentas><anda>0000</anda></cuentas>'::"text" NOT NULL,
    "estado_id" bigint NOT NULL,
    "localidad_id" bigint NOT NULL,
    "imagenusuario" "text",
    "contador" "text" DEFAULT 'x'::"text" NOT NULL
);


--
-- TOC entry 243 (class 1259 OID 19504)
-- Dependencies: 5
-- Name: scr_usuario_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "scr_usuario_rol" (
    "usuario_id" bigint NOT NULL,
    "rol_id" bigint NOT NULL
);


--
-- TOC entry 244 (class 1259 OID 19507)
-- Dependencies: 213 5
-- Name: src_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "src_log_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2551 (class 0 OID 0)
-- Dependencies: 244
-- Name: src_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "src_log_id_seq" OWNED BY "scr_log"."id";


--
-- TOC entry 245 (class 1259 OID 19509)
-- Dependencies: 5 232
-- Name: src_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "src_rol_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2552 (class 0 OID 0)
-- Dependencies: 245
-- Name: src_rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "src_rol_id_seq" OWNED BY "scr_rol"."id";


--
-- TOC entry 246 (class 1259 OID 19511)
-- Dependencies: 179 5
-- Name: src_tip_rep_legal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "src_tip_rep_legal_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2553 (class 0 OID 0)
-- Dependencies: 246
-- Name: src_tip_rep_legal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "src_tip_rep_legal_id_seq" OWNED BY "scr_cat_rep_legal"."id";


--
-- TOC entry 247 (class 1259 OID 19513)
-- Dependencies: 5 177
-- Name: src_tipo_org_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "src_tipo_org_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2554 (class 0 OID 0)
-- Dependencies: 247
-- Name: src_tipo_org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "src_tipo_org_id_seq" OWNED BY "scr_cat_organizacion"."id";


--
-- TOC entry 248 (class 1259 OID 19515)
-- Dependencies: 242 5
-- Name: src_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "src_usuario_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2555 (class 0 OID 0)
-- Dependencies: 248
-- Name: src_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "src_usuario_id_seq" OWNED BY "scr_usuario"."id";


--
-- TOC entry 2081 (class 2604 OID 19517)
-- Dependencies: 163 162
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_actividad" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_actividad_id_seq"'::"regclass");


--
-- TOC entry 2084 (class 2604 OID 19518)
-- Dependencies: 165 164
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_area_trabajo" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_area_de_trabajo_id_seq"'::"regclass");


--
-- TOC entry 2085 (class 2604 OID 19519)
-- Dependencies: 167 166
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_banco" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_banco_id_seq"'::"regclass");


--
-- TOC entry 2092 (class 2604 OID 19520)
-- Dependencies: 169 168
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_bombeo" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_bombeo_id_seq"'::"regclass");


--
-- TOC entry 2094 (class 2604 OID 19521)
-- Dependencies: 171 170
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cargo" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_cargo_id_seq"'::"regclass");


--
-- TOC entry 2096 (class 2604 OID 19522)
-- Dependencies: 173 172
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_actividad" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_tipo_actividad_id_seq"'::"regclass");


--
-- TOC entry 2098 (class 2604 OID 19523)
-- Dependencies: 236 175
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_cooperante" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_tipo_cooperante_id_seq"'::"regclass");


--
-- TOC entry 2099 (class 2604 OID 19524)
-- Dependencies: 235 176
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_depreciacion" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_tip_depresiacion_id_seq"'::"regclass");


--
-- TOC entry 2100 (class 2604 OID 19525)
-- Dependencies: 247 177
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_organizacion" ALTER COLUMN "id" SET DEFAULT "nextval"('"src_tipo_org_id_seq"'::"regclass");


--
-- TOC entry 2101 (class 2604 OID 19526)
-- Dependencies: 237 178
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_produc" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_tipo_produc_id_seq"'::"regclass");


--
-- TOC entry 2104 (class 2604 OID 19527)
-- Dependencies: 246 179
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_rep_legal" ALTER COLUMN "id" SET DEFAULT "nextval"('"src_tip_rep_legal_id_seq"'::"regclass");


--
-- TOC entry 2105 (class 2604 OID 19528)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cheq_recurso" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_cheq_recurso_id_seq"'::"regclass");


--
-- TOC entry 2106 (class 2604 OID 19529)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_chequera" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_chequera_id_seq"'::"regclass");


--
-- TOC entry 2108 (class 2604 OID 19530)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cloracion" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_cloracion_id_seq"'::"regclass");


--
-- TOC entry 2112 (class 2604 OID 19531)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cobro" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_cobro_id_seq"'::"regclass");


--
-- TOC entry 2115 (class 2604 OID 19532)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_consumo" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_consumo_id_seq"'::"regclass");


--
-- TOC entry 2116 (class 2604 OID 19533)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cooperante" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_cooperante_id_seq"'::"regclass");


--
-- TOC entry 2123 (class 2604 OID 19534)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cuenta" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_cuenta_id_seq"'::"regclass");


--
-- TOC entry 2128 (class 2604 OID 19535)
-- Dependencies: 198 194
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_contable" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_detalle_org_id_seq"'::"regclass");


--
-- TOC entry 2135 (class 2604 OID 19536)
-- Dependencies: 197 196
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_factura" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_det_factura_id_seq"'::"regclass");


--
-- TOC entry 2138 (class 2604 OID 19537)
-- Dependencies: 201 199
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_empleado_id_seq"'::"regclass");


--
-- TOC entry 2139 (class 2604 OID 19538)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_estado" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_estado_id_seq"'::"regclass");


--
-- TOC entry 2140 (class 2604 OID 19539)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_his_rep_legal" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_historial_representante_legal_id_seq"'::"regclass");


--
-- TOC entry 2142 (class 2604 OID 19540)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_lectura" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_lectura_id_seq"'::"regclass");


--
-- TOC entry 2144 (class 2604 OID 19541)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_estrategica" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_lin_estrateg_id_seq"'::"regclass");


--
-- TOC entry 2146 (class 2604 OID 19542)
-- Dependencies: 212 211
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_localidad" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_localidad_id_seq"'::"regclass");


--
-- TOC entry 2147 (class 2604 OID 19543)
-- Dependencies: 244 213
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_log" ALTER COLUMN "id" SET DEFAULT "nextval"('"src_log_id_seq"'::"regclass");


--
-- TOC entry 2148 (class 2604 OID 19544)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_marca_produc" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_marca_produc_id_seq"'::"regclass");


--
-- TOC entry 2149 (class 2604 OID 19545)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_organizacion" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_organizacion_id_seq"'::"regclass");


--
-- TOC entry 2153 (class 2604 OID 19546)
-- Dependencies: 220 219
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_presen_produc" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_presen_produc_id_seq"'::"regclass");


--
-- TOC entry 2154 (class 2604 OID 19547)
-- Dependencies: 223 221
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_producto_id_seq"'::"regclass");


--
-- TOC entry 2155 (class 2604 OID 19548)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_proveedor" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_proveedor_id_seq"'::"regclass");


--
-- TOC entry 2156 (class 2604 OID 19549)
-- Dependencies: 227 226
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_proyecto" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_proyecto_id_seq"'::"regclass");


--
-- TOC entry 2157 (class 2604 OID 19550)
-- Dependencies: 229 228
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_recibo" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_recibo_id_seq"'::"regclass");


--
-- TOC entry 2159 (class 2604 OID 19551)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_representante_legal" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_representate_legal_id_seq"'::"regclass");


--
-- TOC entry 2160 (class 2604 OID 19552)
-- Dependencies: 245 232
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_rol" ALTER COLUMN "id" SET DEFAULT "nextval"('"src_rol_id_seq"'::"regclass");


--
-- TOC entry 2161 (class 2604 OID 19553)
-- Dependencies: 234 233
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_rr_ejecucion" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_rr_ejecucion_id_seq"'::"regclass");


--
-- TOC entry 2167 (class 2604 OID 19554)
-- Dependencies: 239 238
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_transaccion" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_transaccion_id_seq"'::"regclass");


--
-- TOC entry 2170 (class 2604 OID 19555)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_u_medida_produc" ALTER COLUMN "id" SET DEFAULT "nextval"('"scr_u_medida_produc_id_seq"'::"regclass");


--
-- TOC entry 2175 (class 2604 OID 19556)
-- Dependencies: 248 242
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario" ALTER COLUMN "id" SET DEFAULT "nextval"('"src_usuario_id_seq"'::"regclass");


--
-- TOC entry 2190 (class 2606 OID 19558)
-- Dependencies: 168 168 2503
-- Name: PK_bombeo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_bombeo"
    ADD CONSTRAINT "PK_bombeo" PRIMARY KEY ("id") DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2226 (class 2606 OID 19561)
-- Dependencies: 184 184 2503
-- Name: PK_cloracion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cloracion"
    ADD CONSTRAINT "PK_cloracion" PRIMARY KEY ("id") DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2240 (class 2606 OID 19564)
-- Dependencies: 192 192 2503
-- Name: PK_cuenta; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cuenta"
    ADD CONSTRAINT "PK_cuenta" PRIMARY KEY ("id");


--
-- TOC entry 2267 (class 2606 OID 19566)
-- Dependencies: 202 202 2503
-- Name: PK_estado; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_estado"
    ADD CONSTRAINT "PK_estado" PRIMARY KEY ("id");


--
-- TOC entry 2279 (class 2606 OID 19568)
-- Dependencies: 210 210 210 2503
-- Name: PK_linea_proyecto; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_proyecto"
    ADD CONSTRAINT "PK_linea_proyecto" PRIMARY KEY ("linea_estrategica_id", "proyecto_id");


--
-- TOC entry 2303 (class 2606 OID 19570)
-- Dependencies: 222 222 222 2503
-- Name: PK_producto_area; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto_area"
    ADD CONSTRAINT "PK_producto_area" PRIMARY KEY ("producto_id", "areaTrabajo_id");


--
-- TOC entry 2324 (class 2606 OID 19572)
-- Dependencies: 238 238 2503
-- Name: PK_transaccion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_transaccion"
    ADD CONSTRAINT "PK_transaccion" PRIMARY KEY ("id");


--
-- TOC entry 2192 (class 2606 OID 19574)
-- Dependencies: 170 170 2503
-- Name: UN_cargo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cargo"
    ADD CONSTRAINT "UN_cargo" UNIQUE ("cargoNombre");


--
-- TOC entry 2196 (class 2606 OID 19576)
-- Dependencies: 172 172 2503
-- Name: UN_cat_actividad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_actividad"
    ADD CONSTRAINT "UN_cat_actividad" UNIQUE ("cActividadNombre");


--
-- TOC entry 2200 (class 2606 OID 19578)
-- Dependencies: 174 174 2503
-- Name: UN_cat_cobro; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_cobro"
    ADD CONSTRAINT "UN_cat_cobro" UNIQUE ("cCobroNombre");


--
-- TOC entry 2242 (class 2606 OID 19580)
-- Dependencies: 192 192 2503
-- Name: UN_cuenta_codigo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cuenta"
    ADD CONSTRAINT "UN_cuenta_codigo" UNIQUE ("cuentaCodigo");


--
-- TOC entry 2244 (class 2606 OID 19582)
-- Dependencies: 192 192 192 2503
-- Name: UN_cuenta_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cuenta"
    ADD CONSTRAINT "UN_cuenta_nombre" UNIQUE ("cuentaNombre", "cat_cuenta_id");


--
-- TOC entry 2255 (class 2606 OID 19584)
-- Dependencies: 199 199 2503
-- Name: UN_empleado_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "UN_empleado_email" UNIQUE ("empleadoEmail");


--
-- TOC entry 2257 (class 2606 OID 19586)
-- Dependencies: 199 199 2503
-- Name: UN_empleado_nit; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "UN_empleado_nit" UNIQUE ("empleadoNit");


--
-- TOC entry 2269 (class 2606 OID 19588)
-- Dependencies: 202 202 2503
-- Name: UN_estado; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_estado"
    ADD CONSTRAINT "UN_estado" UNIQUE ("nombreEstado");


--
-- TOC entry 2275 (class 2606 OID 19590)
-- Dependencies: 208 208 2503
-- Name: UN_lEstrategica_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_estrategica"
    ADD CONSTRAINT "UN_lEstrategica_nombre" UNIQUE ("lEstrategicaNombre");


--
-- TOC entry 2287 (class 2606 OID 19592)
-- Dependencies: 214 214 2503
-- Name: UN_marcaNombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_marca_produc"
    ADD CONSTRAINT "UN_marcaNombre" UNIQUE ("marcaProducNombre");


--
-- TOC entry 2291 (class 2606 OID 19594)
-- Dependencies: 216 216 2503
-- Name: UN_org_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_organizacion"
    ADD CONSTRAINT "UN_org_nombre" UNIQUE ("organizacionNombre");


--
-- TOC entry 2297 (class 2606 OID 19596)
-- Dependencies: 219 219 2503
-- Name: UN_presenNombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_presen_produc"
    ADD CONSTRAINT "UN_presenNombre" UNIQUE ("presenProducNombre");


--
-- TOC entry 2305 (class 2606 OID 19598)
-- Dependencies: 224 224 2503
-- Name: UN_proveedorNombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_proveedor"
    ADD CONSTRAINT "UN_proveedorNombre" UNIQUE ("proveedorNombre");


--
-- TOC entry 2313 (class 2606 OID 19600)
-- Dependencies: 230 230 2503
-- Name: UN_rep_leg_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_representante_legal"
    ADD CONSTRAINT "UN_rep_leg_email" UNIQUE ("rLegalemail");


--
-- TOC entry 2207 (class 2606 OID 19602)
-- Dependencies: 176 176 2503
-- Name: UN_tip_depresiacion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_depreciacion"
    ADD CONSTRAINT "UN_tip_depresiacion" UNIQUE ("depreciacionNombre");


--
-- TOC entry 2211 (class 2606 OID 19604)
-- Dependencies: 177 177 2503
-- Name: UN_tip_org; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_organizacion"
    ADD CONSTRAINT "UN_tip_org" UNIQUE ("cOrgNombre");


--
-- TOC entry 2218 (class 2606 OID 19606)
-- Dependencies: 179 179 2503
-- Name: UN_tip_rep_legal; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_rep_legal"
    ADD CONSTRAINT "UN_tip_rep_legal" UNIQUE ("catRLegalNombre");


--
-- TOC entry 2326 (class 2606 OID 19608)
-- Dependencies: 240 240 2503
-- Name: UN_uMedidaNombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_u_medida_produc"
    ADD CONSTRAINT "UN_uMedidaNombre" UNIQUE ("uMedidaProducNombre");


--
-- TOC entry 2180 (class 2606 OID 19610)
-- Dependencies: 162 162 2503
-- Name: pk_actividad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_actividad"
    ADD CONSTRAINT "pk_actividad" PRIMARY KEY ("id");


--
-- TOC entry 2184 (class 2606 OID 19612)
-- Dependencies: 164 164 2503
-- Name: pk_area_de_trabajo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_area_trabajo"
    ADD CONSTRAINT "pk_area_de_trabajo" PRIMARY KEY ("id");


--
-- TOC entry 2188 (class 2606 OID 19614)
-- Dependencies: 166 166 2503
-- Name: pk_banco; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_banco"
    ADD CONSTRAINT "pk_banco" PRIMARY KEY ("id");


--
-- TOC entry 2194 (class 2606 OID 19616)
-- Dependencies: 170 170 2503
-- Name: pk_cargo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cargo"
    ADD CONSTRAINT "pk_cargo" PRIMARY KEY ("id");


--
-- TOC entry 2204 (class 2606 OID 19618)
-- Dependencies: 175 175 2503
-- Name: pk_cat_cooperante; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_cooperante"
    ADD CONSTRAINT "pk_cat_cooperante" PRIMARY KEY ("id");


--
-- TOC entry 2215 (class 2606 OID 19620)
-- Dependencies: 178 178 2503
-- Name: pk_cat_product; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_produc"
    ADD CONSTRAINT "pk_cat_product" PRIMARY KEY ("id");


--
-- TOC entry 2222 (class 2606 OID 19622)
-- Dependencies: 180 180 2503
-- Name: pk_cheq_rr; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cheq_recurso"
    ADD CONSTRAINT "pk_cheq_rr" PRIMARY KEY ("id");


--
-- TOC entry 2224 (class 2606 OID 19624)
-- Dependencies: 182 182 2503
-- Name: pk_chequera; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_chequera"
    ADD CONSTRAINT "pk_chequera" PRIMARY KEY ("id");


--
-- TOC entry 2228 (class 2606 OID 19626)
-- Dependencies: 186 186 2503
-- Name: pk_cobro; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cobro"
    ADD CONSTRAINT "pk_cobro" PRIMARY KEY ("id");


--
-- TOC entry 2234 (class 2606 OID 19628)
-- Dependencies: 188 188 2503
-- Name: pk_consumo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_consumo"
    ADD CONSTRAINT "pk_consumo" PRIMARY KEY ("id");


--
-- TOC entry 2238 (class 2606 OID 19630)
-- Dependencies: 190 190 2503
-- Name: pk_cooperante; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cooperante"
    ADD CONSTRAINT "pk_cooperante" PRIMARY KEY ("id");


--
-- TOC entry 2249 (class 2606 OID 19632)
-- Dependencies: 196 196 2503
-- Name: pk_det_factura; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_factura"
    ADD CONSTRAINT "pk_det_factura" PRIMARY KEY ("id");


--
-- TOC entry 2247 (class 2606 OID 19634)
-- Dependencies: 194 194 2503
-- Name: pk_detalle_org; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_contable"
    ADD CONSTRAINT "pk_detalle_org" PRIMARY KEY ("id");


--
-- TOC entry 2259 (class 2606 OID 19636)
-- Dependencies: 199 199 2503
-- Name: pk_empleado; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "pk_empleado" PRIMARY KEY ("id");


--
-- TOC entry 2265 (class 2606 OID 19638)
-- Dependencies: 200 200 200 2503
-- Name: pk_empleado_actividad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado_actividad"
    ADD CONSTRAINT "pk_empleado_actividad" PRIMARY KEY ("empleado_id", "actividad_id");


--
-- TOC entry 2271 (class 2606 OID 19640)
-- Dependencies: 204 204 2503
-- Name: pk_his_rep_leg; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_his_rep_legal"
    ADD CONSTRAINT "pk_his_rep_leg" PRIMARY KEY ("id");


--
-- TOC entry 2273 (class 2606 OID 19642)
-- Dependencies: 206 206 2503
-- Name: pk_lectura; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_lectura"
    ADD CONSTRAINT "pk_lectura" PRIMARY KEY ("id");


--
-- TOC entry 2277 (class 2606 OID 19644)
-- Dependencies: 208 208 2503
-- Name: pk_linea_estrateg; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_estrategica"
    ADD CONSTRAINT "pk_linea_estrateg" PRIMARY KEY ("id");


--
-- TOC entry 2281 (class 2606 OID 19646)
-- Dependencies: 211 211 2503
-- Name: pk_localidad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_localidad"
    ADD CONSTRAINT "pk_localidad" PRIMARY KEY ("id");


--
-- TOC entry 2285 (class 2606 OID 19648)
-- Dependencies: 213 213 2503
-- Name: pk_log; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_log"
    ADD CONSTRAINT "pk_log" PRIMARY KEY ("id");


--
-- TOC entry 2289 (class 2606 OID 19650)
-- Dependencies: 214 214 2503
-- Name: pk_marca_produc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_marca_produc"
    ADD CONSTRAINT "pk_marca_produc" PRIMARY KEY ("id");


--
-- TOC entry 2293 (class 2606 OID 19652)
-- Dependencies: 216 216 2503
-- Name: pk_organizacion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_organizacion"
    ADD CONSTRAINT "pk_organizacion" PRIMARY KEY ("id");


--
-- TOC entry 2295 (class 2606 OID 19654)
-- Dependencies: 218 218 218 2503
-- Name: pk_organizacion_representante_legal; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_periodo_representante"
    ADD CONSTRAINT "pk_organizacion_representante_legal" PRIMARY KEY ("organizacion_id", "representante_legal_id");


--
-- TOC entry 2299 (class 2606 OID 19656)
-- Dependencies: 219 219 2503
-- Name: pk_presen_produc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_presen_produc"
    ADD CONSTRAINT "pk_presen_produc" PRIMARY KEY ("id");


--
-- TOC entry 2301 (class 2606 OID 19658)
-- Dependencies: 221 221 2503
-- Name: pk_producto; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto"
    ADD CONSTRAINT "pk_producto" PRIMARY KEY ("id");


--
-- TOC entry 2307 (class 2606 OID 19660)
-- Dependencies: 224 224 2503
-- Name: pk_proveedor; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_proveedor"
    ADD CONSTRAINT "pk_proveedor" PRIMARY KEY ("id");


--
-- TOC entry 2309 (class 2606 OID 19662)
-- Dependencies: 226 226 2503
-- Name: pk_proyecto; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_proyecto"
    ADD CONSTRAINT "pk_proyecto" PRIMARY KEY ("id");


--
-- TOC entry 2311 (class 2606 OID 19664)
-- Dependencies: 228 228 2503
-- Name: pk_recibo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_recibo"
    ADD CONSTRAINT "pk_recibo" PRIMARY KEY ("id");


--
-- TOC entry 2315 (class 2606 OID 19666)
-- Dependencies: 230 230 2503
-- Name: pk_representante_legal; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_representante_legal"
    ADD CONSTRAINT "pk_representante_legal" PRIMARY KEY ("id");


--
-- TOC entry 2321 (class 2606 OID 19668)
-- Dependencies: 233 233 2503
-- Name: pk_rr_ejecucion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_rr_ejecucion"
    ADD CONSTRAINT "pk_rr_ejecucion" PRIMARY KEY ("id");


--
-- TOC entry 2317 (class 2606 OID 19670)
-- Dependencies: 232 232 2503
-- Name: pk_saf_rol; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_rol"
    ADD CONSTRAINT "pk_saf_rol" PRIMARY KEY ("id");


--
-- TOC entry 2209 (class 2606 OID 19672)
-- Dependencies: 176 176 2503
-- Name: pk_tip_depresiacion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_depreciacion"
    ADD CONSTRAINT "pk_tip_depresiacion" PRIMARY KEY ("id");


--
-- TOC entry 2220 (class 2606 OID 19674)
-- Dependencies: 179 179 2503
-- Name: pk_tip_rep_leg; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_rep_legal"
    ADD CONSTRAINT "pk_tip_rep_leg" PRIMARY KEY ("id");


--
-- TOC entry 2198 (class 2606 OID 19676)
-- Dependencies: 172 172 2503
-- Name: pk_tipo_actividad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_actividad"
    ADD CONSTRAINT "pk_tipo_actividad" PRIMARY KEY ("id");


--
-- TOC entry 2202 (class 2606 OID 19678)
-- Dependencies: 174 174 2503
-- Name: pk_tipo_cobro; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_cobro"
    ADD CONSTRAINT "pk_tipo_cobro" PRIMARY KEY ("id");


--
-- TOC entry 2213 (class 2606 OID 19680)
-- Dependencies: 177 177 2503
-- Name: pk_tipo_org; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cat_organizacion"
    ADD CONSTRAINT "pk_tipo_org" PRIMARY KEY ("id");


--
-- TOC entry 2328 (class 2606 OID 19682)
-- Dependencies: 240 240 2503
-- Name: pk_u_medida_produc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_u_medida_produc"
    ADD CONSTRAINT "pk_u_medida_produc" PRIMARY KEY ("id");


--
-- TOC entry 2332 (class 2606 OID 19684)
-- Dependencies: 242 242 2503
-- Name: pk_usuario; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario"
    ADD CONSTRAINT "pk_usuario" PRIMARY KEY ("id");


--
-- TOC entry 2338 (class 2606 OID 19686)
-- Dependencies: 243 243 243 2503
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario_rol"
    ADD CONSTRAINT "pk_usuario_rol" PRIMARY KEY ("usuario_id", "rol_id");


--
-- TOC entry 2319 (class 2606 OID 19688)
-- Dependencies: 232 232 2503
-- Name: scd_rol_nombrerol_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_rol"
    ADD CONSTRAINT "scd_rol_nombrerol_key" UNIQUE ("nombrerol");


--
-- TOC entry 2236 (class 2606 OID 19690)
-- Dependencies: 188 188 188 2503
-- Name: unique_cobro_xfactura; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_consumo"
    ADD CONSTRAINT "unique_cobro_xfactura" UNIQUE ("cobro_id", "factura_id");


--
-- TOC entry 2251 (class 2606 OID 19692)
-- Dependencies: 196 196 2503
-- Name: unique_comprobante; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_factura"
    ADD CONSTRAINT "unique_comprobante" UNIQUE ("det_factur_numero") DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2334 (class 2606 OID 19695)
-- Dependencies: 242 242 2503
-- Name: unique_correo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario"
    ADD CONSTRAINT "unique_correo" UNIQUE ("correousuario");


--
-- TOC entry 2261 (class 2606 OID 19697)
-- Dependencies: 199 199 2503
-- Name: unique_dui_empleado; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "unique_dui_empleado" UNIQUE ("empleadoDui");


--
-- TOC entry 2253 (class 2606 OID 19699)
-- Dependencies: 196 196 196 2503
-- Name: unique_factura_mes; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_factura"
    ADD CONSTRAINT "unique_factura_mes" UNIQUE ("socio_id", "limite_pago");


--
-- TOC entry 2263 (class 2606 OID 19701)
-- Dependencies: 199 199 2503
-- Name: unique_isss_empleado; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "unique_isss_empleado" UNIQUE ("empleadoIsss");


--
-- TOC entry 2336 (class 2606 OID 19703)
-- Dependencies: 242 242 2503
-- Name: unique_login; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario"
    ADD CONSTRAINT "unique_login" UNIQUE ("username");


--
-- TOC entry 2182 (class 2606 OID 19705)
-- Dependencies: 162 162 2503
-- Name: unique_nombre_actividad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_actividad"
    ADD CONSTRAINT "unique_nombre_actividad" UNIQUE ("actividadNombre");


--
-- TOC entry 2186 (class 2606 OID 19707)
-- Dependencies: 164 164 2503
-- Name: unique_nombre_area_de_trabajo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_area_trabajo"
    ADD CONSTRAINT "unique_nombre_area_de_trabajo" UNIQUE ("aTrabajoNombre");


--
-- TOC entry 2230 (class 2606 OID 19709)
-- Dependencies: 186 186 2503
-- Name: unique_nombre_cobrocodigo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cobro"
    ADD CONSTRAINT "unique_nombre_cobrocodigo" UNIQUE ("cobroCodigo");


--
-- TOC entry 2232 (class 2606 OID 19711)
-- Dependencies: 186 186 2503
-- Name: unique_nombre_cobronombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cobro"
    ADD CONSTRAINT "unique_nombre_cobronombre" UNIQUE ("cobroNombre");


--
-- TOC entry 2283 (class 2606 OID 19713)
-- Dependencies: 211 211 2503
-- Name: unique_nombre_localidad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_localidad"
    ADD CONSTRAINT "unique_nombre_localidad" UNIQUE ("localidad_nombre");


--
-- TOC entry 2340 (class 2606 OID 19715)
-- Dependencies: 243 243 243 2503
-- Name: unique_permiso; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario_rol"
    ADD CONSTRAINT "unique_permiso" UNIQUE ("rol_id", "usuario_id");


--
-- TOC entry 2322 (class 1259 OID 19716)
-- Dependencies: 238 2503
-- Name: FKI_det_contable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FKI_det_contable" ON "scr_transaccion" USING "btree" ("pcontable_id");


--
-- TOC entry 2245 (class 1259 OID 19717)
-- Dependencies: 194 2503
-- Name: FKI_organizacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FKI_organizacion" ON "scr_det_contable" USING "btree" ("organizacion_id");


--
-- TOC entry 2205 (class 1259 OID 19718)
-- Dependencies: 176 2503
-- Name: IDX_tip_depreciacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tip_depreciacion" ON "scr_cat_depreciacion" USING "btree" ("depreciacionNombre");


--
-- TOC entry 2216 (class 1259 OID 19719)
-- Dependencies: 179 2503
-- Name: IDX_tip_rep_legal; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tip_rep_legal" ON "scr_cat_rep_legal" USING "btree" ("catRLegalNombre");


--
-- TOC entry 2329 (class 1259 OID 19720)
-- Dependencies: 242 2503
-- Name: fki_PK_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_PK_estado" ON "scr_usuario" USING "btree" ("estado_id");


--
-- TOC entry 2330 (class 1259 OID 19721)
-- Dependencies: 242 2503
-- Name: fki_localidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_localidad" ON "scr_usuario" USING "btree" ("localidad_id");


--
-- TOC entry 2178 (class 1259 OID 19722)
-- Dependencies: 161 2503
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" USING "btree" ("version");


--
-- TOC entry 2393 (class 2620 OID 19723)
-- Dependencies: 278 192 2503
-- Name: actualiza_a_activo; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "actualiza_a_activo" BEFORE INSERT OR UPDATE ON "scr_cuenta" FOR EACH ROW EXECUTE PROCEDURE "tgr_verifica_activo"();


--
-- TOC entry 2556 (class 0 OID 0)
-- Dependencies: 2393
-- Name: TRIGGER "actualiza_a_activo" ON "scr_cuenta"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER "actualiza_a_activo" ON "scr_cuenta" IS 'Actualiza el estado de la cuenta si no es pasivo o capital';


--
-- TOC entry 2397 (class 2620 OID 19724)
-- Dependencies: 267 238 2503
-- Name: actualiza_cuenta; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "actualiza_cuenta" BEFORE INSERT ON "scr_transaccion" FOR EACH ROW EXECUTE PROCEDURE "tgr_actualiza_cuenta"();

ALTER TABLE "scr_transaccion" DISABLE TRIGGER "actualiza_cuenta";


--
-- TOC entry 2394 (class 2620 OID 19725)
-- Dependencies: 192 274 2503
-- Name: actualiza_rubros; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "actualiza_rubros" AFTER INSERT OR UPDATE ON "scr_cuenta" FOR EACH ROW EXECUTE PROCEDURE "tgr_actualiza_rubro"();

ALTER TABLE "scr_cuenta" DISABLE TRIGGER "actualiza_rubros";


--
-- TOC entry 2557 (class 0 OID 0)
-- Dependencies: 2394
-- Name: TRIGGER "actualiza_rubros" ON "scr_cuenta"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER "actualiza_rubros" ON "scr_cuenta" IS 'Actualiza el el rubro';


--
-- TOC entry 2392 (class 2620 OID 19726)
-- Dependencies: 188 275 2503
-- Name: agrega_costo; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "agrega_costo" BEFORE INSERT OR UPDATE ON "scr_consumo" FOR EACH ROW EXECUTE PROCEDURE "tgr_agrega_costo"();


--
-- TOC entry 2400 (class 2620 OID 20016)
-- Dependencies: 242 281 2503
-- Name: asigna_contador; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "asigna_contador" BEFORE INSERT ON "scr_usuario" FOR EACH ROW EXECUTE PROCEDURE "tgr_asigna_contador"();

ALTER TABLE "scr_usuario" DISABLE TRIGGER "asigna_contador";


--
-- TOC entry 2395 (class 2620 OID 19727)
-- Dependencies: 192 279 2503
-- Name: genera_cod_cuenta; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "genera_cod_cuenta" BEFORE INSERT ON "scr_cuenta" FOR EACH ROW EXECUTE PROCEDURE "tgr_verifica_cod_cuenta"();


--
-- TOC entry 2399 (class 2620 OID 19728)
-- Dependencies: 283 242 2503
-- Name: gestiona_contador; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "gestiona_contador" BEFORE DELETE OR UPDATE ON "scr_usuario" FOR EACH ROW EXECUTE PROCEDURE "tgr_actualiza_contador"();

ALTER TABLE "scr_usuario" DISABLE TRIGGER "gestiona_contador";


--
-- TOC entry 2398 (class 2620 OID 19729)
-- Dependencies: 276 238 2503
-- Name: maneja_transacx; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "maneja_transacx" BEFORE DELETE OR UPDATE ON "scr_transaccion" FOR EACH ROW EXECUTE PROCEDURE "tgr_gestion_transacx"();


--
-- TOC entry 2396 (class 2620 OID 19730)
-- Dependencies: 194 280 2503
-- Name: verifica_fecha; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "verifica_fecha" BEFORE INSERT OR UPDATE ON "scr_det_contable" FOR EACH ROW EXECUTE PROCEDURE "tgr_verifica_tcontable"();


--
-- TOC entry 2391 (class 2620 OID 19731)
-- Dependencies: 282 162 2503
-- Name: verificartiempoact; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "verificartiempoact" BEFORE INSERT ON "scr_actividad" FOR EACH ROW EXECUTE PROCEDURE "tgr_verificar_tiempo_act"();


--
-- TOC entry 2344 (class 2606 OID 19732)
-- Dependencies: 170 2193 164 2503
-- Name: FK_cargo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_area_trabajo"
    ADD CONSTRAINT "FK_cargo" FOREIGN KEY ("cargo_id") REFERENCES "scr_cargo"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2353 (class 2606 OID 19737)
-- Dependencies: 174 2201 186 2503
-- Name: FK_catCobro; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cobro"
    ADD CONSTRAINT "FK_catCobro" FOREIGN KEY ("cat_cobro_id") REFERENCES "scr_cat_cobro"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2384 (class 2606 OID 19742)
-- Dependencies: 192 238 2239 2503
-- Name: FK_cuenta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_transaccion"
    ADD CONSTRAINT "FK_cuenta" FOREIGN KEY ("cuenta_id") REFERENCES "scr_cuenta"("id") MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2357 (class 2606 OID 19747)
-- Dependencies: 192 2239 192 2503
-- Name: FK_cuenta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cuenta"
    ADD CONSTRAINT "FK_cuenta" FOREIGN KEY ("cat_cuenta_id") REFERENCES "scr_cuenta"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED NOT VALID;


--
-- TOC entry 2385 (class 2606 OID 19752)
-- Dependencies: 194 2246 238 2503
-- Name: FK_det_contable; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_transaccion"
    ADD CONSTRAINT "FK_det_contable" FOREIGN KEY ("pcontable_id") REFERENCES "scr_det_contable"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2358 (class 2606 OID 19757)
-- Dependencies: 2258 194 199 2503
-- Name: FK_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_contable"
    ADD CONSTRAINT "FK_empleado" FOREIGN KEY ("empleado_id") REFERENCES "scr_empleado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2386 (class 2606 OID 19762)
-- Dependencies: 2258 238 199 2503
-- Name: FK_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_transaccion"
    ADD CONSTRAINT "FK_empleado" FOREIGN KEY ("empleado_id") REFERENCES "scr_empleado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2351 (class 2606 OID 19767)
-- Dependencies: 2258 184 199 2503
-- Name: FK_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cloracion"
    ADD CONSTRAINT "FK_empleado" FOREIGN KEY ("empleado_id") REFERENCES "scr_empleado"("id") ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2347 (class 2606 OID 19772)
-- Dependencies: 168 199 2258 2503
-- Name: FK_empleado_bombeo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_bombeo"
    ADD CONSTRAINT "FK_empleado_bombeo" FOREIGN KEY ("empleado_id") REFERENCES "scr_empleado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2370 (class 2606 OID 19777)
-- Dependencies: 2276 210 208 2503
-- Name: FK_linea_estrategica; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_proyecto"
    ADD CONSTRAINT "FK_linea_estrategica" FOREIGN KEY ("linea_estrategica_id") REFERENCES "scr_linea_estrategica"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2361 (class 2606 OID 19782)
-- Dependencies: 199 211 2280 2503
-- Name: FK_localidad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "FK_localidad" FOREIGN KEY ("localidad_id") REFERENCES "scr_localidad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2352 (class 2606 OID 19787)
-- Dependencies: 184 211 2280 2503
-- Name: FK_localidad_cloracion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cloracion"
    ADD CONSTRAINT "FK_localidad_cloracion" FOREIGN KEY ("localidad_id") REFERENCES "scr_localidad"("id") ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2359 (class 2606 OID 19792)
-- Dependencies: 216 194 2292 2503
-- Name: FK_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_contable"
    ADD CONSTRAINT "FK_organizacion" FOREIGN KEY ("organizacion_id") REFERENCES "scr_organizacion"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2371 (class 2606 OID 19797)
-- Dependencies: 2308 226 210 2503
-- Name: FK_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_proyecto"
    ADD CONSTRAINT "FK_proyecto" FOREIGN KEY ("proyecto_id") REFERENCES "scr_proyecto"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2341 (class 2606 OID 19802)
-- Dependencies: 226 162 2308 2503
-- Name: FK_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_actividad"
    ADD CONSTRAINT "FK_proyecto" FOREIGN KEY ("proyecto_id") REFERENCES "scr_proyecto"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2387 (class 2606 OID 20020)
-- Dependencies: 242 2266 202 2503
-- Name: PK_estado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario"
    ADD CONSTRAINT "PK_estado" FOREIGN KEY ("estado_id") REFERENCES "scr_estado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2364 (class 2606 OID 19812)
-- Dependencies: 162 200 2179 2503
-- Name: fk_actividad_emp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado_actividad"
    ADD CONSTRAINT "fk_actividad_emp" FOREIGN KEY ("actividad_id") REFERENCES "scr_actividad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2345 (class 2606 OID 19817)
-- Dependencies: 164 164 2183 2503
-- Name: fk_area_de_trabajo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_area_trabajo"
    ADD CONSTRAINT "fk_area_de_trabajo" FOREIGN KEY ("area_trabajo_id") REFERENCES "scr_area_trabajo"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2350 (class 2606 OID 19822)
-- Dependencies: 166 2187 182 2503
-- Name: fk_banco_chequera; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_chequera"
    ADD CONSTRAINT "fk_banco_chequera" FOREIGN KEY ("banco_id") REFERENCES "scr_banco"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2362 (class 2606 OID 19827)
-- Dependencies: 170 199 2193 2503
-- Name: fk_cargo_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "fk_cargo_empleado" FOREIGN KEY ("cargo_id") REFERENCES "scr_cargo"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2348 (class 2606 OID 19832)
-- Dependencies: 170 2193 170 2503
-- Name: fk_cargo_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cargo"
    ADD CONSTRAINT "fk_cargo_parent" FOREIGN KEY ("cargo_id") REFERENCES "scr_cargo"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2356 (class 2606 OID 19837)
-- Dependencies: 175 190 2203 2503
-- Name: fk_cat_cooperante; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cooperante"
    ADD CONSTRAINT "fk_cat_cooperante" FOREIGN KEY ("catCooperante_id") REFERENCES "scr_cat_cooperante"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2376 (class 2606 OID 19842)
-- Dependencies: 176 2208 221 2503
-- Name: fk_cat_depresiacion_producto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto"
    ADD CONSTRAINT "fk_cat_depresiacion_producto" FOREIGN KEY ("catDepresiacion_id") REFERENCES "scr_cat_depreciacion"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2377 (class 2606 OID 19847)
-- Dependencies: 178 221 2214 2503
-- Name: fk_cat_produc_produc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto"
    ADD CONSTRAINT "fk_cat_produc_produc" FOREIGN KEY ("catProduc_id") REFERENCES "scr_cat_produc"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2349 (class 2606 OID 19852)
-- Dependencies: 2223 182 180 2503
-- Name: fk_chequera; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_cheq_recurso"
    ADD CONSTRAINT "fk_chequera" FOREIGN KEY ("chequera_id") REFERENCES "scr_chequera"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2354 (class 2606 OID 19857)
-- Dependencies: 186 2227 188 2503
-- Name: fk_consumo_cobro; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_consumo"
    ADD CONSTRAINT "fk_consumo_cobro" FOREIGN KEY ("cobro_id") REFERENCES "scr_cobro"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2355 (class 2606 OID 19862)
-- Dependencies: 196 188 2248 2503
-- Name: fk_consumo_factura; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_consumo"
    ADD CONSTRAINT "fk_consumo_factura" FOREIGN KEY ("factura_id") REFERENCES "scr_det_factura"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2365 (class 2606 OID 19867)
-- Dependencies: 200 2258 199 2503
-- Name: fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado_actividad"
    ADD CONSTRAINT "fk_empleado" FOREIGN KEY ("empleado_id") REFERENCES "scr_empleado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2367 (class 2606 OID 19872)
-- Dependencies: 199 2258 206 2503
-- Name: fk_empleado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_lectura"
    ADD CONSTRAINT "fk_empleado" FOREIGN KEY ("tecnico_id") REFERENCES "scr_empleado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2372 (class 2606 OID 19877)
-- Dependencies: 211 211 2280 2503
-- Name: fk_localidad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_localidad"
    ADD CONSTRAINT "fk_localidad" FOREIGN KEY ("localidad_id") REFERENCES "scr_localidad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2388 (class 2606 OID 20025)
-- Dependencies: 211 2280 242 2503
-- Name: fk_localidad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario"
    ADD CONSTRAINT "fk_localidad" FOREIGN KEY ("localidad_id") REFERENCES "scr_localidad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2373 (class 2606 OID 19887)
-- Dependencies: 211 2280 216 2503
-- Name: fk_localidad_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_organizacion"
    ADD CONSTRAINT "fk_localidad_organizacion" FOREIGN KEY ("localidad_id") REFERENCES "scr_localidad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2378 (class 2606 OID 19892)
-- Dependencies: 2288 221 214 2503
-- Name: fk_marca_producto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto"
    ADD CONSTRAINT "fk_marca_producto" FOREIGN KEY ("marca_id") REFERENCES "scr_marca_produc"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2374 (class 2606 OID 19897)
-- Dependencies: 218 2292 216 2503
-- Name: fk_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_periodo_representante"
    ADD CONSTRAINT "fk_organizacion" FOREIGN KEY ("organizacion_id") REFERENCES "scr_organizacion"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2369 (class 2606 OID 19902)
-- Dependencies: 208 216 2292 2503
-- Name: fk_organizacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_linea_estrategica"
    ADD CONSTRAINT "fk_organizacion" FOREIGN KEY ("organizacion_id") REFERENCES "scr_organizacion"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2346 (class 2606 OID 19907)
-- Dependencies: 164 2292 216 2503
-- Name: fk_organizacion_area_de_trabajo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_area_trabajo"
    ADD CONSTRAINT "fk_organizacion_area_de_trabajo" FOREIGN KEY ("organizacion_id") REFERENCES "scr_organizacion"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2342 (class 2606 OID 19912)
-- Dependencies: 162 2179 162 2503
-- Name: fk_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_actividad"
    ADD CONSTRAINT "fk_parent" FOREIGN KEY ("actividad_id") REFERENCES "scr_actividad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2379 (class 2606 OID 19917)
-- Dependencies: 2298 221 219 2503
-- Name: fk_presen_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto"
    ADD CONSTRAINT "fk_presen_product" FOREIGN KEY ("presentacion_id") REFERENCES "scr_presen_produc"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2366 (class 2606 OID 19922)
-- Dependencies: 204 230 2314 2503
-- Name: fk_rep_leg_his_rep_legal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_his_rep_legal"
    ADD CONSTRAINT "fk_rep_leg_his_rep_legal" FOREIGN KEY ("representante_legal_id") REFERENCES "scr_representante_legal"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2375 (class 2606 OID 19927)
-- Dependencies: 2314 230 218 2503
-- Name: fk_representate_legal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_periodo_representante"
    ADD CONSTRAINT "fk_representate_legal" FOREIGN KEY ("representante_legal_id") REFERENCES "scr_representante_legal"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2389 (class 2606 OID 19932)
-- Dependencies: 243 2316 232 2503
-- Name: fk_rol; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario_rol"
    ADD CONSTRAINT "fk_rol" FOREIGN KEY ("rol_id") REFERENCES "scr_rol"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2368 (class 2606 OID 19937)
-- Dependencies: 206 2331 242 2503
-- Name: fk_socio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_lectura"
    ADD CONSTRAINT "fk_socio" FOREIGN KEY ("socio_id") REFERENCES "scr_usuario"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2360 (class 2606 OID 19942)
-- Dependencies: 196 242 2331 2503
-- Name: fk_socio_factura; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_det_factura"
    ADD CONSTRAINT "fk_socio_factura" FOREIGN KEY ("socio_id") REFERENCES "scr_usuario"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2383 (class 2606 OID 19947)
-- Dependencies: 2258 233 199 2503
-- Name: fk_solicitado_por; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_rr_ejecucion"
    ADD CONSTRAINT "fk_solicitado_por" FOREIGN KEY ("empleado_id") REFERENCES "scr_empleado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2382 (class 2606 OID 19952)
-- Dependencies: 179 230 2219 2503
-- Name: fk_tip_rep_leg_rep_leg; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_representante_legal"
    ADD CONSTRAINT "fk_tip_rep_leg_rep_leg" FOREIGN KEY ("cat_rep_legal_id") REFERENCES "scr_cat_rep_legal"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2343 (class 2606 OID 19957)
-- Dependencies: 172 162 2197 2503
-- Name: fk_tipo_act_actividad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_actividad"
    ADD CONSTRAINT "fk_tipo_act_actividad" FOREIGN KEY ("cat_actividad_id") REFERENCES "scr_cat_actividad"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2380 (class 2606 OID 19962)
-- Dependencies: 240 221 2327 2503
-- Name: fk_u_medida_produc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_producto"
    ADD CONSTRAINT "fk_u_medida_produc" FOREIGN KEY ("u_medida_id") REFERENCES "scr_u_medida_produc"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2381 (class 2606 OID 19967)
-- Dependencies: 242 228 2331 2503
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_recibo"
    ADD CONSTRAINT "fk_usuario" FOREIGN KEY ("usuario_id") REFERENCES "scr_usuario"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2390 (class 2606 OID 19972)
-- Dependencies: 2331 243 242 2503
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_usuario_rol"
    ADD CONSTRAINT "fk_usuario" FOREIGN KEY ("usuario_id") REFERENCES "scr_usuario"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2363 (class 2606 OID 19977)
-- Dependencies: 242 2331 199 2503
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "scr_empleado"
    ADD CONSTRAINT "fk_usuario" FOREIGN KEY ("usuario_id") REFERENCES "scr_usuario"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


-- Completed on 2015-03-20 14:07:44 CST

--
-- PostgreSQL database dump complete
--

