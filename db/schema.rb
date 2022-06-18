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

ActiveRecord::Schema.define(version: 20170821042024) do

  create_table "actual_vessels", force: true do |t|
    t.integer  "shipment_tracking_id"
    t.integer  "vessel_id"
    t.date     "actual_etd_date"
    t.date     "actual_eta_date"
    t.integer  "status_etd",           default: 0
    t.integer  "status_eta",           default: 0
    t.text     "reason_etd"
    t.text     "reason_eta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "actual_vessels", ["shipment_tracking_id"], name: "index_actual_vessels_on_shipment_tracking_id", using: :btree
  add_index "actual_vessels", ["vessel_id"], name: "index_actual_vessels_on_vessel_id", using: :btree

  create_table "agents", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "reference"
    t.integer  "credit_term"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",  default: false
  end

  create_table "attachments", force: true do |t|
    t.string   "name"
    t.integer  "assetable_id"
    t.string   "assetable_type"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "banks", force: true do |t|
    t.string   "bank_name"
    t.text     "bank_address"
    t.string   "acc_name"
    t.string   "acc_no"
    t.string   "swift_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bill_of_lading_histories", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.integer  "shipping_instruction_id"
    t.integer  "shipper_id"
    t.integer  "consignee_id"
    t.text     "notify_party"
    t.string   "country_of_origin"
    t.text     "also_notify_party"
    t.string   "place_of_receipt"
    t.string   "port_of_loading"
    t.string   "port_of_discharge"
    t.string   "final_destination"
    t.string   "feeder_vessel"
    t.string   "connection_vessel"
    t.text     "marks_no"
    t.text     "description_packages"
    t.string   "gw"
    t.string   "measurement"
    t.text     "container_no"
    t.string   "freight"
    t.text     "freight_details"
    t.string   "no_of_obl"
    t.date     "date_of_issue"
    t.text     "shipped_on_board"
    t.integer  "create_by"
    t.integer  "update_by"
    t.string   "bl_number"
    t.string   "place_of_issue"
    t.text     "special_clause"
    t.string   "master_bl_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shipper_name",            default: "", null: false
    t.string   "consignee_name",          default: "", null: false
    t.integer  "agent_id"
    t.text     "agent_name"
  end

  add_index "bill_of_lading_histories", ["agent_id"], name: "index_bill_of_lading_histories_on_agent_id", using: :btree

  create_table "bill_of_lading_invoices", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.boolean  "is_tick_all",                                      default: false
    t.boolean  "is_ai",                                            default: false
    t.boolean  "is_gi",                                            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_instruction_id"
    t.decimal  "other",                   precision: 13, scale: 2
    t.decimal  "rate",                    precision: 13, scale: 2
    t.decimal  "vat_10",                  precision: 13, scale: 2
    t.decimal  "vat_1",                   precision: 13, scale: 2
    t.decimal  "pph_23",                  precision: 13, scale: 2
  end

  add_index "bill_of_lading_invoices", ["bill_of_lading_id"], name: "index_bill_of_lading_invoices_on_bill_of_lading_id", using: :btree
  add_index "bill_of_lading_invoices", ["shipping_instruction_id"], name: "index_bill_of_lading_invoices_on_shipping_instruction_id", using: :btree

  create_table "bill_of_lading_items", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.string   "description"
    t.decimal  "volume",                    precision: 13, scale: 5, default: 1.0
    t.decimal  "amount_usd",                precision: 13, scale: 2
    t.decimal  "amount_idr",                precision: 13, scale: 2
    t.boolean  "add_vat_10",                                         default: false
    t.boolean  "add_vat_1",                                          default: false
    t.boolean  "add_pph_23",                                         default: false
    t.boolean  "is_deleted",                                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bill_of_lading_invoice_id"
    t.integer  "item_type",                                          default: 1,     null: false
    t.integer  "item_order",                                         default: 0,     null: false
  end

  add_index "bill_of_lading_items", ["bill_of_lading_id"], name: "index_bill_of_lading_items_on_bill_of_lading_id", using: :btree
  add_index "bill_of_lading_items", ["bill_of_lading_invoice_id"], name: "index_bill_of_lading_items_on_bill_of_lading_invoice_id", using: :btree

  create_table "bill_of_ladings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.integer  "shipper_id"
    t.integer  "consignee_id"
    t.text     "notify_party"
    t.string   "country_of_origin"
    t.text     "also_notify_party"
    t.string   "place_of_receipt"
    t.string   "port_of_loading"
    t.string   "port_of_discharge"
    t.string   "final_destination"
    t.string   "feeder_vessel"
    t.string   "connection_vessel"
    t.text     "marks_no"
    t.text     "description_packages"
    t.string   "gw"
    t.string   "measurement"
    t.text     "container_no"
    t.string   "freight"
    t.text     "freight_details"
    t.string   "no_of_obl"
    t.date     "date_of_issue"
    t.text     "shipped_on_board"
    t.integer  "create_by"
    t.integer  "update_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bl_number"
    t.string   "place_of_issue"
    t.text     "special_clause"
    t.string   "master_bl_no",            default: "",    null: false
    t.integer  "status_tracking",         default: 0,     null: false
    t.integer  "is_cancel",               default: 0,     null: false
    t.string   "shipper_name",            default: "",    null: false
    t.string   "consignee_name",          default: "",    null: false
    t.integer  "agent_id"
    t.text     "agent_name"
    t.boolean  "is_shadow",               default: false
    t.string   "shipper_reference"
    t.boolean  "hide_agent",              default: false
    t.boolean  "delivery_doc",            default: false
  end

  add_index "bill_of_ladings", ["agent_id"], name: "index_bill_of_ladings_on_agent_id", using: :btree

  create_table "bl_monitorings", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.string   "hbl_no"
    t.string   "mbl_no"
    t.boolean  "invoiced",                default: false
    t.boolean  "closed",                  default: false
    t.boolean  "hidden",                  default: false
    t.datetime "shipment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "ibl_ref"
    t.date     "etd_date"
    t.integer  "shipping_instruction_id"
  end

  add_index "bl_monitorings", ["bill_of_lading_id"], name: "index_bl_monitorings_on_bill_of_lading_id", using: :btree
  add_index "bl_monitorings", ["shipping_instruction_id"], name: "index_bl_monitorings_on_shipping_instruction_id", using: :btree

  create_table "carrier_banks", force: true do |t|
    t.integer  "carrier_id"
    t.string   "bank_name"
    t.string   "bank_address"
    t.string   "acc_name"
    t.string   "acc_no"
    t.string   "swift_code"
    t.string   "currency"
    t.string   "branch"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",   default: false
  end

  create_table "carrier_items", force: true do |t|
    t.integer  "carrier_id"
    t.string   "description"
    t.decimal  "amount_usd",  precision: 13, scale: 2
    t.decimal  "amount_idr",  precision: 13, scale: 2
    t.boolean  "is_deleted",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carrier_items", ["carrier_id"], name: "index_carrier_items_on_carrier_id", using: :btree

  create_table "carriers", force: true do |t|
    t.string  "name"
    t.text    "notes"
    t.text    "address"
    t.string  "reference",   default: ""
    t.integer "credit_term", default: 0
    t.boolean "is_deleted",  default: false
  end

  create_table "close_payments", force: true do |t|
    t.integer  "invoice_id"
    t.string   "ibl_ref"
    t.string   "customer"
    t.string   "shipper"
    t.string   "invoice_no"
    t.decimal  "amount",       precision: 13, scale: 2
    t.decimal  "amount_paid",  precision: 13, scale: 2
    t.decimal  "rate",         precision: 13, scale: 2
    t.date     "payment_date"
    t.integer  "status",                                default: 0,     null: false
    t.string   "currency"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "close_ref"
    t.boolean  "is_shadow",                             default: false
  end

  add_index "close_payments", ["invoice_id"], name: "index_close_payments_on_invoice_id", using: :btree

  create_table "commision_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.integer  "cost_revenue_id"
    t.string   "hbl_no"
    t.string   "mbl_no"
    t.boolean  "exported",                default: false
    t.datetime "exported_at"
    t.boolean  "hidden",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commision_monitorings", ["cost_revenue_id"], name: "index_commision_monitorings_on_cost_revenue_id", using: :btree
  add_index "commision_monitorings", ["shipping_instruction_id"], name: "index_commision_monitorings_on_shipping_instruction_id", using: :btree

  create_table "consignees", force: true do |t|
    t.string  "company_name"
    t.text    "address"
    t.string  "city"
    t.string  "zipcode"
    t.string  "country_id"
    t.string  "contact_name"
    t.string  "phone"
    t.string  "cellphone"
    t.string  "email_address"
    t.text    "custom_field1"
    t.text    "custom_field2"
    t.text    "custom_field3"
    t.string  "reference",     default: ""
    t.integer "credit_term",   default: 0
    t.boolean "is_deleted",    default: false
  end

  create_table "containers", force: true do |t|
    t.string "container_type"
    t.string "length"
    t.string "width"
    t.string "height"
    t.string "capacity"
    t.string "load"
    t.string "container_weight"
    t.string "max_gross_weight"
  end

  create_table "cost_revenue_items", force: true do |t|
    t.integer  "cost_revenue_id"
    t.string   "description"
    t.decimal  "selling_usd",             precision: 13, scale: 2
    t.decimal  "selling_idr",             precision: 13, scale: 2
    t.decimal  "buying_usd",              precision: 13, scale: 2
    t.decimal  "buying_idr",              precision: 13, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "selling_amount",          precision: 13, scale: 2
    t.decimal  "buying_amount",           precision: 13, scale: 2
    t.integer  "item_type",                                        default: 1,   null: false
    t.integer  "item_order",                                       default: 0,   null: false
    t.decimal  "selling_total_after_tax", precision: 13, scale: 2
    t.decimal  "buying_total_after_tax",  precision: 13, scale: 2
    t.decimal  "selling_volume",          precision: 13, scale: 5, default: 1.0
    t.decimal  "buying_volume",           precision: 13, scale: 5, default: 1.0
  end

  add_index "cost_revenue_items", ["cost_revenue_id"], name: "index_cost_revenue_items_on_cost_revenue_id", using: :btree

  create_table "cost_revenues", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.text     "payment_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                                           default: 0, null: false
    t.text     "notes"
    t.string   "owner"
    t.string   "master_bl_no"
    t.string   "shipper_reference"
    t.string   "carrier"
    t.integer  "shipper_id"
    t.integer  "consignee_id"
    t.string   "trade"
    t.string   "vessel_name"
    t.date     "etd_date"
    t.string   "port_of_loading"
    t.string   "port_of_discharge"
    t.string   "final_destination"
    t.string   "volume"
    t.decimal  "selling_other",           precision: 13, scale: 2
    t.decimal  "selling_rate",            precision: 13, scale: 2
    t.decimal  "selling_vat_10",          precision: 13, scale: 2
    t.decimal  "selling_vat_1",           precision: 13, scale: 2
    t.decimal  "selling_pph_23",          precision: 13, scale: 2
    t.decimal  "buying_other",            precision: 13, scale: 2
    t.decimal  "buying_rate",             precision: 13, scale: 2
    t.decimal  "buying_vat_10",           precision: 13, scale: 2
    t.decimal  "buying_vat_1",            precision: 13, scale: 2
    t.decimal  "buying_pph_23",           precision: 13, scale: 2
    t.decimal  "adda",                    precision: 13, scale: 2
    t.decimal  "addb",                    precision: 13, scale: 2
    t.decimal  "addc",                    precision: 13, scale: 2
    t.decimal  "selling_total_after_tax", precision: 13, scale: 2
    t.decimal  "buying_total_after_tax",  precision: 13, scale: 2
    t.string   "ibl_ref"
    t.integer  "carrier_id"
    t.integer  "owner_id"
  end

  add_index "cost_revenues", ["consignee_id"], name: "index_cost_revenues_on_consignee_id", using: :btree
  add_index "cost_revenues", ["owner_id"], name: "index_cost_revenues_on_owner_id", using: :btree
  add_index "cost_revenues", ["shipper_id"], name: "index_cost_revenues_on_shipper_id", using: :btree
  add_index "cost_revenues", ["shipping_instruction_id"], name: "index_cost_revenues_on_shipping_instruction_id", using: :btree

  create_table "countries", force: true do |t|
    t.string  "code"
    t.string  "name"
    t.integer "region_id"
    t.string  "currency_code"
    t.string  "currency_name"
  end

  create_table "cr_containers", force: true do |t|
    t.integer "cost_revenue_id"
    t.integer "container_id"
    t.string  "volum"
  end

  add_index "cr_containers", ["container_id"], name: "index_cr_containers_on_container_id", using: :btree
  add_index "cr_containers", ["cost_revenue_id"], name: "index_cr_containers_on_cost_revenue_id", using: :btree

  create_table "cr_monitorings", force: true do |t|
    t.integer  "cost_revenue_id"
    t.string   "hbl_no"
    t.string   "mbl_no"
    t.boolean  "hidden",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "shipment_date"
    t.integer  "shipping_instruction_id"
    t.string   "name"
    t.string   "ibl_ref"
    t.date     "etd_date"
  end

  add_index "cr_monitorings", ["cost_revenue_id"], name: "index_cr_monitorings_on_cost_revenue_id", using: :btree
  add_index "cr_monitorings", ["shipping_instruction_id"], name: "index_cr_monitorings_on_shipping_instruction_id", using: :btree

  create_table "custom_fields", force: true do |t|
    t.string  "field_key"
    t.string  "field_name"
    t.text    "field_value"
    t.integer "field_id"
    t.string  "field_type"
  end

  create_table "debit_note_details", force: true do |t|
    t.integer  "debit_note_id"
    t.text     "description"
    t.decimal  "amount",         precision: 13, scale: 2
    t.decimal  "volume",         precision: 13, scale: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_type",                               default: 1, null: false
    t.decimal  "default_amount", precision: 13, scale: 2
  end

  create_table "debit_note_payments", force: true do |t|
    t.integer "debit_note_id"
    t.date    "payment_date"
    t.decimal "amount_paid",   precision: 13, scale: 2
    t.decimal "rounding",      precision: 13, scale: 2
    t.decimal "bank_charge",   precision: 13, scale: 2
    t.decimal "discount",      precision: 13, scale: 2
    t.decimal "short_paid",    precision: 13, scale: 2
    t.decimal "deposit",       precision: 13, scale: 2
    t.text    "note"
  end

  add_index "debit_note_payments", ["debit_note_id"], name: "index_debit_note_payments_on_debit_note_id", using: :btree

  create_table "debit_notes", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.string   "no_dbn"
    t.date     "dbn_date"
    t.date     "due_date"
    t.string   "currency_code"
    t.decimal  "rate",                       precision: 13, scale: 2
    t.integer  "status",                                              default: 0
    t.text     "notes"
    t.text     "to_shipper"
    t.string   "vessel"
    t.string   "destination"
    t.string   "bl_ibl_no"
    t.string   "shipper_ref"
    t.date     "etd"
    t.date     "eta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_of_payment"
    t.text     "notes_payment"
    t.integer  "is_cancel",                                           default: 0,            null: false
    t.string   "head_letter",                                         default: "DEBIT NOTE", null: false
    t.string   "customer"
    t.string   "bl_no"
    t.string   "ibl_no"
    t.string   "customer_ori"
    t.integer  "status_payment",                                      default: 0
    t.string   "volume"
    t.date     "tax_issued"
    t.string   "vat_10_no"
    t.string   "vat_1_no"
    t.string   "pph_23_no"
    t.integer  "status_tax",                                          default: 0,            null: false
    t.string   "port_of_loading"
    t.boolean  "add_vat_10",                                          default: false,        null: false
    t.boolean  "add_vat_1",                                           default: false,        null: false
    t.boolean  "add_total_include_vat",                               default: false,        null: false
    t.boolean  "add_pph_23",                                          default: false,        null: false
    t.boolean  "add_total_after_pph_23",                              default: false,        null: false
    t.boolean  "add_rate",                                            default: false,        null: false
    t.decimal  "other",                      precision: 13, scale: 2
    t.decimal  "vat_10",                     precision: 13, scale: 2
    t.decimal  "vat_1",                      precision: 13, scale: 2
    t.decimal  "pph_23",                     precision: 13, scale: 2
    t.decimal  "default_total_amount",       precision: 13, scale: 2
    t.decimal  "default_vat_10",             precision: 13, scale: 2
    t.decimal  "default_vat_1",              precision: 13, scale: 2
    t.decimal  "default_total_include_vat",  precision: 13, scale: 2
    t.decimal  "default_pph_23",             precision: 13, scale: 2
    t.decimal  "default_total_after_pph_23", precision: 13, scale: 2
    t.decimal  "default_rate",               precision: 13, scale: 2
    t.decimal  "vat_10_2",                   precision: 13, scale: 2
    t.decimal  "vat_1_2",                    precision: 13, scale: 2
    t.decimal  "pph_23_2",                   precision: 13, scale: 2
  end

  create_table "document_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.integer  "bill_of_lading_id"
    t.string   "ibl_ref"
    t.string   "shipper_company_name"
    t.date     "etd_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "document_monitorings", ["bill_of_lading_id"], name: "index_document_monitorings_on_bill_of_lading_id", using: :btree
  add_index "document_monitorings", ["shipping_instruction_id"], name: "index_document_monitorings_on_shipping_instruction_id", using: :btree

  create_table "invoice_close_deposits", force: true do |t|
    t.string   "invoice_no"
    t.date     "payment_date"
    t.decimal  "amount",       precision: 13, scale: 2
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_deposits", force: true do |t|
    t.integer  "invoice_id"
    t.integer  "close_payment_id"
    t.string   "ibl_deposit"
    t.string   "invoice_deposit"
    t.decimal  "amount",           precision: 13, scale: 2
    t.string   "invoice_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_deposits", ["close_payment_id"], name: "index_invoice_deposits_on_close_payment_id", using: :btree
  add_index "invoice_deposits", ["invoice_id"], name: "index_invoice_deposits_on_invoice_id", using: :btree

  create_table "invoice_details", force: true do |t|
    t.integer "invoice_id"
    t.text    "description"
    t.decimal "amount",         precision: 13, scale: 2
    t.decimal "volume",         precision: 13, scale: 5
    t.integer "item_type",                               default: 1, null: false
    t.decimal "default_amount", precision: 13, scale: 2
  end

  create_table "invoice_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.integer  "invoice_id"
    t.integer  "debit_note_id"
    t.integer  "note_id"
    t.string   "ibl_ref"
    t.string   "invoice_no"
    t.string   "shipper_company_name"
    t.date     "etd_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "invoice_monitorings", ["debit_note_id"], name: "index_invoice_monitorings_on_debit_note_id", using: :btree
  add_index "invoice_monitorings", ["invoice_id"], name: "index_invoice_monitorings_on_invoice_id", using: :btree
  add_index "invoice_monitorings", ["note_id"], name: "index_invoice_monitorings_on_note_id", using: :btree
  add_index "invoice_monitorings", ["shipping_instruction_id"], name: "index_invoice_monitorings_on_shipping_instruction_id", using: :btree

  create_table "invoice_payments", force: true do |t|
    t.integer  "invoice_id"
    t.date     "payment_date"
    t.decimal  "amount_paid",             precision: 13, scale: 2
    t.decimal  "rounding",                precision: 13, scale: 2
    t.decimal  "bank_charge",             precision: 13, scale: 2
    t.decimal  "discount",                precision: 13, scale: 2
    t.decimal  "short_paid",              precision: 13, scale: 2
    t.decimal  "deposit",                 precision: 13, scale: 2
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ibl_ref"
    t.string   "invoice_no"
    t.decimal  "pph_23",                  precision: 13, scale: 2
    t.decimal  "other",                   precision: 13, scale: 2
    t.integer  "close_payment_id"
    t.date     "short_paid_closing_date"
    t.text     "short_paid_note"
    t.integer  "short_paid_status",                                default: 0, null: false
    t.date     "deposit_closing_date"
    t.text     "deposit_note"
    t.integer  "deposit_status",                                   default: 0, null: false
  end

  add_index "invoice_payments", ["close_payment_id"], name: "index_invoice_payments_on_close_payment_id", using: :btree
  add_index "invoice_payments", ["invoice_id"], name: "index_invoice_payments_on_invoice_id", using: :btree

  create_table "invoices", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.string   "no_invoice"
    t.date     "invoice_date"
    t.date     "due_date"
    t.string   "currency_code"
    t.decimal  "rate",                       precision: 13, scale: 2
    t.integer  "status",                                              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.text     "to_shipper"
    t.string   "vessel"
    t.string   "destination"
    t.string   "bl_ibl_no"
    t.string   "shipper_ref"
    t.date     "etd"
    t.date     "eta"
    t.date     "date_of_payment"
    t.text     "notes_payment"
    t.integer  "is_cancel",                                           default: 0,         null: false
    t.string   "head_letter",                                         default: "INVOICE", null: false
    t.string   "customer"
    t.string   "bl_no"
    t.string   "ibl_no"
    t.string   "customer_ori"
    t.integer  "status_payment",                                      default: 0
    t.string   "volume"
    t.date     "tax_issued"
    t.string   "vat_10_no"
    t.string   "vat_1_no"
    t.string   "pph_23_no"
    t.integer  "status_tax",                                          default: 0,         null: false
    t.string   "port_of_loading"
    t.boolean  "add_vat_10",                                          default: false,     null: false
    t.boolean  "add_vat_1",                                           default: false,     null: false
    t.boolean  "add_total_include_vat",                               default: false,     null: false
    t.boolean  "add_pph_23",                                          default: false,     null: false
    t.boolean  "add_total_after_pph_23",                              default: false,     null: false
    t.boolean  "add_rate",                                            default: false,     null: false
    t.decimal  "other",                      precision: 13, scale: 2
    t.decimal  "vat_10",                     precision: 13, scale: 2
    t.decimal  "vat_1",                      precision: 13, scale: 2
    t.decimal  "pph_23",                     precision: 13, scale: 2
    t.decimal  "default_total_amount",       precision: 13, scale: 2
    t.decimal  "default_vat_10",             precision: 13, scale: 2
    t.decimal  "default_vat_1",              precision: 13, scale: 2
    t.decimal  "default_total_include_vat",  precision: 13, scale: 2
    t.decimal  "default_pph_23",             precision: 13, scale: 2
    t.decimal  "default_total_after_pph_23", precision: 13, scale: 2
    t.decimal  "default_rate",               precision: 13, scale: 2
    t.decimal  "vat_10_2",                   precision: 13, scale: 2
    t.decimal  "vat_1_2",                    precision: 13, scale: 2
    t.decimal  "pph_23_2",                   precision: 13, scale: 2
  end

  create_table "note_details", force: true do |t|
    t.integer "note_id"
    t.text    "description"
    t.decimal "amount",         precision: 13, scale: 2
    t.decimal "volume",         precision: 13, scale: 5
    t.integer "item_type",                               default: 1, null: false
    t.decimal "default_amount", precision: 13, scale: 2
  end

  add_index "note_details", ["note_id"], name: "index_note_details_on_note_id", using: :btree

  create_table "note_payments", force: true do |t|
    t.integer "note_id"
    t.date    "payment_date"
    t.decimal "amount_paid",  precision: 13, scale: 2
    t.decimal "rounding",     precision: 13, scale: 2
    t.decimal "bank_charge",  precision: 13, scale: 2
    t.decimal "discount",     precision: 13, scale: 2
    t.decimal "short_paid",   precision: 13, scale: 2
    t.decimal "deposit",      precision: 13, scale: 2
    t.text    "note"
  end

  add_index "note_payments", ["note_id"], name: "index_note_payments_on_note_id", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.string   "no_note"
    t.date     "note_date"
    t.date     "due_date"
    t.string   "currency_code"
    t.decimal  "rate",                       precision: 13, scale: 2
    t.integer  "status",                                              default: 0
    t.text     "notes"
    t.text     "to_shipper"
    t.string   "vessel"
    t.string   "destination"
    t.string   "bl_ibl_no"
    t.string   "shipper_ref"
    t.date     "etd"
    t.date     "eta"
    t.date     "date_of_payment"
    t.text     "notes_payment"
    t.integer  "is_cancel",                                           default: 0
    t.string   "head_letter",                                         default: "NOTE"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer"
    t.string   "bl_no"
    t.string   "ibl_no"
    t.string   "customer_ori"
    t.integer  "status_payment",                                      default: 0
    t.string   "volume"
    t.date     "tax_issued"
    t.string   "vat_10_no"
    t.string   "vat_1_no"
    t.string   "pph_23_no"
    t.integer  "status_tax",                                          default: 0,      null: false
    t.string   "port_of_loading"
    t.boolean  "add_vat_10",                                          default: false,  null: false
    t.boolean  "add_vat_1",                                           default: false,  null: false
    t.boolean  "add_total_include_vat",                               default: false,  null: false
    t.boolean  "add_pph_23",                                          default: false,  null: false
    t.boolean  "add_total_after_pph_23",                              default: false,  null: false
    t.boolean  "add_rate",                                            default: false,  null: false
    t.decimal  "other",                      precision: 13, scale: 2
    t.decimal  "vat_10",                     precision: 13, scale: 2
    t.decimal  "vat_1",                      precision: 13, scale: 2
    t.decimal  "pph_23",                     precision: 13, scale: 2
    t.decimal  "default_total_amount",       precision: 13, scale: 2
    t.decimal  "default_vat_10",             precision: 13, scale: 2
    t.decimal  "default_vat_1",              precision: 13, scale: 2
    t.decimal  "default_total_include_vat",  precision: 13, scale: 2
    t.decimal  "default_pph_23",             precision: 13, scale: 2
    t.decimal  "default_total_after_pph_23", precision: 13, scale: 2
    t.decimal  "default_rate",               precision: 13, scale: 2
    t.decimal  "vat_10_2",                   precision: 13, scale: 2
    t.decimal  "vat_1_2",                    precision: 13, scale: 2
    t.decimal  "pph_23_2",                   precision: 13, scale: 2
  end

  add_index "notes", ["bill_of_lading_id"], name: "index_notes_on_bill_of_lading_id", using: :btree

  create_table "owners", force: true do |t|
    t.string   "name"
    t.string   "reference"
    t.text     "notes"
    t.boolean  "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_close_deposits", force: true do |t|
    t.integer  "carrier_id"
    t.string   "ibl_ref"
    t.string   "payment_type",                          default: "", null: false
    t.date     "payment_date"
    t.decimal  "amount",       precision: 13, scale: 2
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_close_deposits", ["carrier_id"], name: "index_payment_close_deposits_on_carrier_id", using: :btree

  create_table "payment_deposits", force: true do |t|
    t.integer  "payment_id"
    t.string   "ibl_deposit"
    t.string   "master_bl_no"
    t.decimal  "amount",       precision: 13, scale: 2
    t.string   "ibl_ref"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_deposits", ["payment_id"], name: "index_payment_deposits_on_payment_id", using: :btree

  create_table "payment_histories", force: true do |t|
    t.integer "payment_id"
    t.integer "invoice_id"
  end

  add_index "payment_histories", ["invoice_id"], name: "index_payment_histories_on_invoice_id", using: :btree
  add_index "payment_histories", ["payment_id"], name: "index_payment_histories_on_payment_id", using: :btree

  create_table "payment_invoices", force: true do |t|
    t.integer  "payment_id"
    t.date     "payment_date"
    t.string   "carrier"
    t.boolean  "is_paid",                                          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_instruction_id"
    t.decimal  "other",                   precision: 13, scale: 2
    t.decimal  "rate",                    precision: 13, scale: 2
    t.decimal  "vat_10",                  precision: 13, scale: 2
    t.decimal  "vat_1",                   precision: 13, scale: 2
    t.decimal  "pph_23",                  precision: 13, scale: 2
    t.integer  "carrier_id"
    t.string   "vat_10_tax_no"
    t.string   "vat_1_tax_no"
    t.string   "pph_23_tax_no"
    t.date     "vat_10_tax_issued"
    t.date     "vat_1_tax_issued"
    t.date     "pph_23_tax_issued"
    t.string   "vat_10_invoice_no"
    t.string   "vat_1_invoice_no"
    t.string   "pph_23_invoice_no"
    t.boolean  "vat_10_status",                                    default: false, null: false
    t.boolean  "vat_1_status",                                     default: false, null: false
    t.boolean  "pph_23_status",                                    default: false, null: false
  end

  add_index "payment_invoices", ["payment_id"], name: "index_payment_invoices_on_payment_id", using: :btree
  add_index "payment_invoices", ["shipping_instruction_id"], name: "index_payment_invoices_on_shipping_instruction_id", using: :btree

  create_table "payment_items", force: true do |t|
    t.integer  "payment_invoice_id"
    t.string   "description"
    t.decimal  "volume",             precision: 13, scale: 5, default: 1.0
    t.decimal  "amount_usd",         precision: 13, scale: 2
    t.decimal  "amount_idr",         precision: 13, scale: 2
    t.boolean  "add_vat_10",                                  default: false
    t.boolean  "add_vat_1",                                   default: false
    t.boolean  "add_pph_23",                                  default: false
    t.boolean  "is_deleted",                                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_type",                                   default: 1,     null: false
    t.integer  "item_order",                                  default: 0,     null: false
  end

  add_index "payment_items", ["payment_invoice_id"], name: "index_payment_items_on_payment_invoice_id", using: :btree

  create_table "payment_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.string   "hbl_no"
    t.string   "carrier"
    t.date     "shipment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "ibl_ref"
    t.date     "etd_date"
  end

  add_index "payment_monitorings", ["shipping_instruction_id"], name: "index_payment_monitorings_on_shipping_instruction_id", using: :btree

  create_table "payment_references", force: true do |t|
    t.integer  "payment_id"
    t.string   "ibl_ref"
    t.string   "booking_no"
    t.string   "amount",                                   default: "0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount_invoice",  precision: 13, scale: 2
    t.decimal  "amount_payment",  precision: 13, scale: 2
    t.string   "master_bl_no"
    t.decimal  "amount_misc",     precision: 13, scale: 2
    t.decimal  "amount_overpaid", precision: 13, scale: 2
  end

  add_index "payment_references", ["payment_id"], name: "index_payment_references_on_payment_id", using: :btree

  create_table "payment_taxes", force: true do |t|
    t.integer  "payment_id"
    t.string   "ibl_ref"
    t.decimal  "amount",     precision: 13, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tax_no"
    t.date     "tax_issued"
    t.boolean  "is_paid",                             default: false
  end

  add_index "payment_taxes", ["payment_id"], name: "index_payment_taxes_on_payment_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "invoice_id"
    t.integer  "carrier_bank_id"
    t.date     "payment_date"
    t.string   "payment_no"
    t.string   "amount",            default: "0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "si_bl_no"
    t.string   "cash_carrier_name"
    t.string   "payment_type",      default: "",  null: false
    t.text     "notes"
    t.integer  "status",            default: 0,   null: false
    t.integer  "is_cancel",         default: 0,   null: false
    t.integer  "carrier_id"
  end

  add_index "payments", ["carrier_id"], name: "index_payments_on_carrier_id", using: :btree

  create_table "regions", force: true do |t|
    t.string "code"
    t.string "name"
  end

  create_table "sell_cost_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.integer  "cost_revenue_id"
    t.string   "ibl_ref"
    t.string   "shipper_company_name"
    t.date     "etd_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "sell_cost_monitorings", ["cost_revenue_id"], name: "index_sell_cost_monitorings_on_cost_revenue_id", using: :btree
  add_index "sell_cost_monitorings", ["shipping_instruction_id"], name: "index_sell_cost_monitorings_on_shipping_instruction_id", using: :btree

  create_table "shipment_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.integer  "shipment_tracking_id"
    t.string   "hbl_no"
    t.string   "mbl_no"
    t.date     "shipment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "ibl_ref"
    t.date     "etd_date"
  end

  create_table "shipment_trackings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.text     "notes"
    t.string   "free_request"
    t.string   "free_approval"
    t.integer  "free_status",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "fu_date"
  end

  add_index "shipment_trackings", ["shipping_instruction_id"], name: "index_shipment_trackings_on_shipping_instruction_id", using: :btree

  create_table "shipper_items", force: true do |t|
    t.integer  "shipper_id"
    t.string   "description"
    t.decimal  "amount_usd",  precision: 13, scale: 2
    t.decimal  "amount_idr",  precision: 13, scale: 2
    t.boolean  "is_deleted",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipper_items", ["shipper_id"], name: "index_shipper_items_on_shipper_id", using: :btree

  create_table "shippers", force: true do |t|
    t.string  "company_name"
    t.string  "reference"
    t.integer "credit_term",  default: 0,     null: false
    t.text    "notes"
    t.text    "bl_address",                   null: false
    t.boolean "is_deleted",   default: false
  end

  create_table "shipping_instruction_histories", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.string   "si_no"
    t.integer  "shipper_id"
    t.integer  "consignee_id"
    t.text     "notify_party"
    t.string   "country_of_origin"
    t.string   "carrier"
    t.string   "pic"
    t.string   "feeder_vessel"
    t.string   "connection_vessel"
    t.date     "etd_jkt"
    t.date     "etd_sin"
    t.date     "eta"
    t.text     "volume"
    t.integer  "container_id"
    t.string   "place_of_receipt"
    t.string   "port_of_loading"
    t.string   "port_of_transhipment"
    t.string   "port_of_discharge"
    t.string   "final_destination"
    t.string   "no_of_obl"
    t.date     "si_date"
    t.text     "marks_no"
    t.text     "description_packages"
    t.string   "gw"
    t.string   "nw"
    t.string   "measurement"
    t.text     "dimension"
    t.text     "freight"
    t.text     "freight_details"
    t.text     "special_instructions"
    t.text     "container_no"
    t.string   "peb_no"
    t.date     "inst_date"
    t.string   "kpbc"
    t.text     "hs_code"
    t.integer  "create_by"
    t.integer  "update_by"
    t.string   "shipper_reference"
    t.integer  "status"
    t.string   "order_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "booking_no",              default: "",    null: false
    t.text     "shipper_name"
    t.text     "consignee_name"
    t.text     "container_no_2"
    t.string   "master_bl_no",            default: ""
    t.string   "trade"
    t.integer  "handle_by"
    t.text     "shipping_schedule"
    t.text     "vessels"
    t.text     "si_containers"
    t.integer  "is_cancel",               default: 0,     null: false
    t.string   "order_details",           default: "",    null: false
    t.boolean  "is_shadow",               default: false
  end

  create_table "shipping_instructions", force: true do |t|
    t.string   "si_no"
    t.integer  "shipper_id"
    t.integer  "consignee_id"
    t.text     "notify_party"
    t.string   "country_of_origin"
    t.string   "carrier"
    t.string   "pic"
    t.string   "feeder_vessel"
    t.string   "connection_vessel"
    t.date     "etd_jkt"
    t.date     "etd_sin"
    t.date     "eta"
    t.text     "volume"
    t.integer  "container_id"
    t.string   "place_of_receipt"
    t.string   "port_of_loading"
    t.string   "port_of_transhipment"
    t.string   "port_of_discharge"
    t.string   "final_destination"
    t.string   "no_of_obl"
    t.date     "si_date"
    t.text     "marks_no"
    t.text     "description_packages"
    t.string   "gw"
    t.string   "nw"
    t.string   "measurement"
    t.text     "dimension"
    t.text     "freight"
    t.text     "freight_details"
    t.text     "special_instructions"
    t.text     "container_no"
    t.string   "peb_no"
    t.date     "inst_date"
    t.string   "kpbc"
    t.text     "hs_code"
    t.integer  "create_by"
    t.integer  "update_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shipper_reference"
    t.integer  "status",                                  default: 0,     null: false
    t.string   "order_type",                              default: "",    null: false
    t.integer  "is_cancel",                               default: 0,     null: false
    t.string   "booking_no",                              default: "",    null: false
    t.text     "shipper_name",         limit: 2147483647
    t.text     "consignee_name"
    t.text     "container_no_2"
    t.string   "master_bl_no",                            default: ""
    t.string   "order_details",                           default: "",    null: false
    t.boolean  "is_shadow",                               default: false
    t.string   "trade"
    t.integer  "handle_by"
    t.text     "shipping_schedule"
    t.integer  "carrier_id"
  end

  create_table "si_containers", force: true do |t|
    t.integer "shipping_instruction_id"
    t.integer "container_id"
    t.string  "volum"
  end

  create_table "si_monitorings", force: true do |t|
    t.integer  "shipping_instruction_id"
    t.string   "si_no"
    t.boolean  "hidden",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "shipment_date"
    t.string   "name"
    t.string   "ibl_ref"
    t.date     "etd_date"
  end

  add_index "si_monitorings", ["shipping_instruction_id"], name: "index_si_monitorings_on_shipping_instruction_id", using: :btree

  create_table "trackings", force: true do |t|
    t.integer  "bill_of_lading_id"
    t.string   "vessel"
    t.string   "etd_no"
    t.date     "etd_date"
    t.string   "eta_no"
    t.date     "eta_date"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "etd_actual_date"
    t.text     "etd_desc"
    t.date     "eta_actual_date"
    t.text     "eta_desc"
    t.integer  "status_eta",        default: 0, null: false
  end

  add_index "trackings", ["bill_of_lading_id"], name: "index_trackings_on_bill_of_lading_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "register_at"
    t.datetime "login_at"
    t.datetime "logout_at"
    t.boolean  "status",                    default: false
    t.integer  "role",            limit: 1, default: 2
    t.boolean  "is_deleted",                default: false
  end

  create_table "vessels", force: true do |t|
    t.integer "shipping_instruction_id"
    t.string  "vessel_name"
    t.string  "etd_no"
    t.date    "etd_date"
    t.string  "eta_no"
    t.date    "eta_date"
  end

end
