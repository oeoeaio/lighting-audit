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

ActiveRecord::Schema.define(version: 20160502042031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "houses", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "house_type",   null: false
    t.integer  "storey_count", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "auditor",      null: false
    t.date     "audit_date",   null: false
    t.string   "postcode",     null: false
  end

  create_table "lights", force: :cascade do |t|
    t.integer  "house_id",                                                    null: false
    t.integer  "room_id",                                                     null: false
    t.integer  "switch_id",                                                   null: false
    t.string   "name",                                                        null: false
    t.string   "connection_type",                                             null: false
    t.boolean  "dimmer",                                    default: false,   null: false
    t.boolean  "motion",                                    default: false,   null: false
    t.string   "fitting",                                                     null: false
    t.string   "colour",                                                      null: false
    t.string   "technology",                                                  null: false
    t.string   "shape",                                                       null: false
    t.string   "cap"
    t.string   "transformer"
    t.decimal  "wattage",          precision: 5,  scale: 2,                   null: false
    t.string   "wattage_source",                            default: "label", null: false
    t.decimal  "usage",            precision: 4,  scale: 1,                   null: false
    t.text     "notes"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "tech_mod",                                                    null: false
    t.decimal  "mains_reflector",  precision: 2,  scale: 1,                   null: false
    t.integer  "row",                                                         null: false
    t.decimal  "power_multiplier", precision: 10, scale: 6,                   null: false
    t.integer  "power_add",                                                   null: false
    t.decimal  "log_multiplier",   precision: 10, scale: 6,                   null: false
    t.decimal  "log_add",          precision: 10, scale: 6,                   null: false
    t.decimal  "power_adj",        precision: 10, scale: 6,                   null: false
    t.decimal  "efficacy",         precision: 10, scale: 6,                   null: false
    t.decimal  "lumens",           precision: 10, scale: 6,                   null: false
    t.integer  "lumens_round",                                                null: false
  end

  add_index "lights", ["house_id"], name: "index_lights_on_house_id", using: :btree
  add_index "lights", ["room_id"], name: "index_lights_on_room_id", using: :btree
  add_index "lights", ["switch_id"], name: "index_lights_on_switch_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.integer  "house_id",                                                null: false
    t.integer  "number",                                                  null: false
    t.string   "room_type",                                               null: false
    t.boolean  "indoors",                                                 null: false
    t.decimal  "area",                precision: 5, scale: 2
    t.decimal  "height",              precision: 5, scale: 2
    t.text     "notes"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "missing_light_count",                         default: 0
  end

  add_index "rooms", ["house_id"], name: "index_rooms_on_house_id", using: :btree

  create_table "switches", force: :cascade do |t|
    t.integer  "house_id",   null: false
    t.integer  "room_id",    null: false
    t.string   "number",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "switches", ["house_id"], name: "index_switches_on_house_id", using: :btree
  add_index "switches", ["number"], name: "index_switches_on_number", using: :btree
  add_index "switches", ["room_id"], name: "index_switches_on_room_id", using: :btree

  add_foreign_key "lights", "houses"
  add_foreign_key "lights", "rooms"
  add_foreign_key "lights", "switches"
  add_foreign_key "rooms", "houses"
  add_foreign_key "switches", "houses"
  add_foreign_key "switches", "rooms"
end
