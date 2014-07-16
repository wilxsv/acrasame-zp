# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "scr_actividad", force: true do |t|
    t.string  "actividadNombre",      limit: 150,                                       null: false
    t.text    "actividadDescripcion"
    t.date    "actividadInicio",                                                        null: false
    t.date    "actividadFin",                                                           null: false
    t.float   "actividadPresupuesto",                                     default: 0.0, null: false
    t.integer "actividad_id",         limit: 8
    t.integer "cat_actividad_id",     limit: 8,                                         null: false
    t.decimal "actividadEjecutado",               precision: 3, scale: 2, default: 0.0, null: false
    t.integer "proyecto_id",          limit: 8,                                         null: false
  end

  add_index "scr_actividad", ["actividadNombre"], name: "unique_nombre_actividad", unique: true, using: :btree

  create_table "scr_area_trabajo", force: true do |t|
    t.string  "aTrabajoNombre",      limit: 150, null: false
    t.text    "aTrabajoDescripcion"
    t.integer "area_trabajo_id",     limit: 8
    t.integer "organizacion_id",     limit: 8,   null: false
    t.integer "cargo_id",            limit: 8,   null: false
  end

  add_index "scr_area_trabajo", ["aTrabajoNombre"], name: "unique_nombre_area_de_trabajo", unique: true, using: :btree

  create_table "scr_banco", force: true do |t|
    t.string "banco_nombre", limit: 100, null: false
  end

  create_table "scr_cargo", force: true do |t|
    t.string  "cargoNombre",      limit: 150,               null: false
    t.text    "cargoDescripcion"
    t.float   "cargoSalario",                 default: 1.0, null: false
    t.integer "cargo_id",         limit: 8
  end

  add_index "scr_cargo", ["cargoNombre"], name: "UN_cargo", unique: true, using: :btree

  create_table "scr_cat_actividad", force: true do |t|
    t.string "cActividadNombre",        limit: 150, null: false
    t.text   "catActividadDescripcion"
  end

  add_index "scr_cat_actividad", ["cActividadNombre"], name: "UN_cat_actividad", unique: true, using: :btree

  create_table "scr_cat_cooperante", force: true do |t|
    t.string "catCoopNombre",  limit: 100, null: false
    t.text   "catCoopDescrip"
  end

  create_table "scr_cat_depreciacion", force: true do |t|
    t.string "depreciacionNombre",      limit: 100, null: false
    t.text   "depreciacionDescripcion"
  end

  add_index "scr_cat_depreciacion", ["depreciacionNombre"], name: "IDX_tip_depreciacion", using: :btree
  add_index "scr_cat_depreciacion", ["depreciacionNombre"], name: "UN_tip_depresiacion", unique: true, using: :btree

  create_table "scr_cat_organizacion", force: true do |t|
    t.string "cOrgNombre",      limit: 150, null: false
    t.text   "cOrgDescripcion"
  end

  add_index "scr_cat_organizacion", ["cOrgNombre"], name: "UN_tip_org", unique: true, using: :btree

  create_table "scr_cat_produc", force: true do |t|
    t.string "catProducNombre",  limit: 100, null: false
    t.text   "catProducDescrip"
  end

  create_table "scr_cat_rep_legal", force: true do |t|
    t.string   "catRLegalNombre",      limit: 150,                   null: false
    t.text     "catRLegalDescripcion"
    t.datetime "catRLegalRegistro",                default: "now()", null: false
    t.boolean  "catRLegalFirma",                   default: false,   null: false
  end

  add_index "scr_cat_rep_legal", ["catRLegalNombre"], name: "IDX_tip_rep_legal", unique: true, using: :btree
  add_index "scr_cat_rep_legal", ["catRLegalNombre"], name: "UN_tip_rep_legal", unique: true, using: :btree

  create_table "scr_cheq_recurso", force: true do |t|
    t.integer  "cheq_rr_codigo",        limit: 8,   null: false
    t.string   "cheq_rr_quien_recibe",  limit: 100, null: false
    t.datetime "cheq_rr_fecha_emision",             null: false
    t.datetime "cheq_rr_fecha_vence",               null: false
    t.integer  "chequera_id",           limit: 8,   null: false
  end

  create_table "scr_chequera", force: true do |t|
    t.integer "chequera_correlativo", limit: 8, null: false
    t.integer "banco_id",             limit: 8
  end

  create_table "scr_cooperante", force: true do |t|
    t.string  "cooperanteNombre",      limit: 100, null: false
    t.text    "cooperanteDescripcion"
    t.integer "catCooperante_id",      limit: 8,   null: false
  end

  create_table "scr_cuenta", force: true do |t|
    t.string   "cuentaNombre",      limit: 150,                                                           null: false
    t.datetime "cuentaRegistro",                default: "('now'::text)::timestamp(0) without time zone", null: false
    t.float    "cuentaDebe",                    default: 0.0,                                             null: false
    t.float    "cuentaHaber",                   default: 0.0,                                             null: false
    t.integer  "cat_cuenta_id"
    t.boolean  "cuentaActivo",                  default: false,                                           null: false
    t.integer  "cuentaCodigo",      limit: 8,   default: 0,                                               null: false
    t.text     "cuentaDescripcion"
    t.boolean  "cuentaNegativa",                default: false,                                           null: false
  end

  add_index "scr_cuenta", ["cuentaCodigo"], name: "UN_cuenta_codigo", unique: true, using: :btree
  add_index "scr_cuenta", ["cuentaNombre", "cat_cuenta_id"], name: "UN_cuenta_nombre", unique: true, using: :btree

  create_table "scr_det_contable", force: true do |t|
    t.date    "dConIniPeriodo",                              null: false
    t.date    "dConFinPeriodo",                              null: false
    t.boolean "dConActivo",                  default: false, null: false
    t.string  "dConSimboloMoneda", limit: 3, default: "$",   null: false
    t.integer "dConPagoXMes",      limit: 2, default: 1,     null: false
    t.integer "organizacion_id",   limit: 8,                 null: false
    t.integer "empleado_id",       limit: 8,                 null: false
  end

  add_index "scr_det_contable", ["organizacion_id"], name: "FKI_organizacion", using: :btree

  create_table "scr_det_factura", force: true do |t|
    t.integer  "det_factur_numero",  limit: 8, null: false
    t.text     "det_factur_cliente",           null: false
    t.datetime "det_factur_fecha",             null: false
  end

# Could not dump table "scr_empleado" because of following StandardError
#   Unknown type 'dominio_email' for column 'empleadoEmail'

  create_table "scr_empleado_actividad", id: false, force: true do |t|
    t.integer "empleado_id",  limit: 8, null: false
    t.integer "actividad_id", limit: 8, null: false
  end

  create_table "scr_estado", force: true do |t|
    t.string "nombreEstado", limit: 150, null: false
  end

  add_index "scr_estado", ["nombreEstado"], name: "UN_estado", unique: true, using: :btree

  create_table "scr_his_rep_legal", force: true do |t|
    t.string   "his_rep_leg_nombre",         limit: 150, null: false
    t.string   "his_rep_leg_apellido",       limit: 150, null: false
    t.integer  "his_rep_leg_telefono",       limit: 8,   null: false
    t.integer  "his_rep_leg_celular",        limit: 8
    t.string   "his_rep_leg_email",          limit: 100
    t.string   "his_rep_leg_direccion",      limit: 200, null: false
    t.datetime "his_rep_leg_fecha_registro",             null: false
    t.integer  "representante_legal_id",     limit: 8,   null: false
  end

  create_table "scr_linea_estrategica", force: true do |t|
    t.integer "organizacion_id",         limit: 8,                     null: false
    t.string  "lEstrategicaNombre",      limit: 150,                   null: false
    t.text    "lEstrategicaDescripcion"
    t.date    "lEstrategicaInicio",                  default: "now()", null: false
    t.date    "lEstrategicaFin",                                       null: false
    t.integer "linea_estrategica_id",    limit: 8
  end

  add_index "scr_linea_estrategica", ["lEstrategicaNombre"], name: "UN_lEstrategica_nombre", unique: true, using: :btree

  create_table "scr_linea_proyecto", id: false, force: true do |t|
    t.integer "linea_estrategica_id", limit: 8, null: false
    t.integer "proyecto_id",          limit: 8, null: false
  end

  create_table "scr_localidad", force: true do |t|
    t.string  "localidad_nombre",      limit: 150, null: false
    t.text    "localidad_descripcion"
    t.integer "localidad_id",          limit: 8
    t.float   "localidad_lat",                     null: false
    t.float   "localidad_lon",                     null: false
  end

  add_index "scr_localidad", ["localidad_nombre"], name: "unique_nombre_localidad", unique: true, using: :btree

  create_table "scr_log", force: true do |t|
    t.datetime "src_fecha",                 null: false
    t.text     "src_descripcion",           null: false
    t.integer  "usuario_id",      limit: 8, null: false
  end

  create_table "scr_marca_produc", force: true do |t|
    t.string "marcaProducNombre",  limit: 100, null: false
    t.text   "marcaProducDescrip"
  end

  add_index "scr_marca_produc", ["marcaProducNombre"], name: "UN_marcaNombre", unique: true, using: :btree

  create_table "scr_organizacion", force: true do |t|
    t.string  "organizacionNombre",      limit: 150, null: false
    t.text    "organizacionDescripcion"
    t.integer "localidad_id",            limit: 8,   null: false
  end

  add_index "scr_organizacion", ["organizacionNombre"], name: "UN_org_nombre", unique: true, using: :btree

  create_table "scr_periodo_representante", id: false, force: true do |t|
    t.integer "organizacion_id",        limit: 8,                   null: false
    t.integer "representante_legal_id", limit: 8,                   null: false
    t.date    "periodoInicio",                    default: "now()", null: false
    t.date    "periodoFin",                                         null: false
  end

  create_table "scr_presen_produc", force: true do |t|
    t.string "presenProducNombre",  limit: 100, null: false
    t.text   "presenProducDescrip"
  end

  add_index "scr_presen_produc", ["presenProducNombre"], name: "UN_presenNombre", unique: true, using: :btree

  create_table "scr_producto", force: true do |t|
    t.string  "productoNombre",      limit: 100, null: false
    t.text    "productoDescripcion"
    t.integer "marca_id",            limit: 8,   null: false
    t.integer "catProduc_id",        limit: 8,   null: false
    t.integer "u_medida_id",         limit: 8,   null: false
    t.integer "presentacion_id",     limit: 8,   null: false
    t.integer "catDepresiacion_id",  limit: 8,   null: false
    t.string  "productoComprobante", limit: 100, null: false
    t.integer "proveedor_id",        limit: 8,   null: false
    t.text    "productoCodigo",                  null: false
  end

  create_table "scr_producto_area", id: false, force: true do |t|
    t.integer "producto_id",    limit: 8, null: false
    t.integer "areaTrabajo_id", limit: 8, null: false
  end

  create_table "scr_proveedor", force: true do |t|
    t.string "proveedorNombre",      limit: 100, null: false
    t.text   "proveedorDescripcion"
  end

  add_index "scr_proveedor", ["proveedorNombre"], name: "UN_proveedorNombre", unique: true, using: :btree

  create_table "scr_proyecto", force: true do |t|
    t.string  "proyectoNombre",  limit: 100, null: false
    t.text    "proyectoDescrip"
    t.integer "cooperante_id",   limit: 8,   null: false
  end

# Could not dump table "scr_representante_legal" because of following StandardError
#   Unknown type 'dominio_email' for column 'rLegalemail'

  create_table "scr_rol", force: true do |t|
    t.string "nombrerol",  limit: 75, null: false
    t.text   "detallerol"
  end

  add_index "scr_rol", ["nombrerol"], name: "scd_rol_nombrerol_key", unique: true, using: :btree

  create_table "scr_rr_ejecucion", force: true do |t|
    t.integer "solic_rr_id", limit: 8, null: false
    t.integer "empleado_id", limit: 8, null: false
  end

  create_table "scr_transaccion", force: true do |t|
    t.integer  "transaxSecuencia", limit: 8,                                                           null: false
    t.integer  "cuenta_id",        limit: 8,                                                           null: false
    t.float    "transaxMonto",               default: 0.0,                                             null: false
    t.boolean  "transaxDebeHaber",           default: true,                                            null: false
    t.integer  "empleado_id",      limit: 8,                                                           null: false
    t.datetime "transaxRegistro",            default: "('now'::text)::timestamp(0) without time zone", null: false
    t.date     "transaxFecha",                                                                         null: false
    t.integer  "pcontable_id",     limit: 8,                                                           null: false
  end

  add_index "scr_transaccion", ["pcontable_id"], name: "FKI_det_contable", using: :btree

  create_table "scr_u_medida_produc", force: true do |t|
    t.string "uMedidaProducNombre",  limit: 100, null: false
    t.text   "uMedidaProducDescrip"
  end

  add_index "scr_u_medida_produc", ["uMedidaProducNombre"], name: "UN_uMedidaNombre", unique: true, using: :btree

# Could not dump table "scr_usuario" because of following StandardError
#   Unknown type 'dominio_email' for column 'correousuario'

  create_table "scr_usuario_rol", id: false, force: true do |t|
    t.integer "usuario_id", limit: 8, null: false
    t.integer "rol_id",     limit: 8, null: false
  end

end
