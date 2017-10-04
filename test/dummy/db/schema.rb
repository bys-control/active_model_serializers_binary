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

ActiveRecord::Schema.define(version: 20170830125642) do

  create_table "productos", force: :cascade do |t|
    t.integer  "uid"
    t.integer  "silo"
    t.string   "nombre"
    t.integer  "total_acumulado"
    t.boolean  "bits1"
    t.boolean  "bits2"
    t.float    "ffloat"
    t.string   "variable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "silos", force: :cascade do |t|
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
