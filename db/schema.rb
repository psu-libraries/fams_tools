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

ActiveRecord::Schema.define(version: 20180316184731) do

  create_table "contract_faculty_links", force: :cascade do |t|
    t.integer "contract_id"
    t.integer "faculty_id"
    t.string "role"
    t.integer "pct_credit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_pub_fac_links_on_contract_id"
    t.index ["faculty_id"], name: "index_pub_fac_links_on_faculty_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "osp_key"
    t.string "title"
    t.integer "sponsor_id"
    t.string "status"
    t.date "submitted"
    t.date "awarded"
    t.integer "requested"
    t.integer "funded"
    t.integer "total_anticipated"
    t.date "start_date"
    t.date "end_date"
    t.string "grant_contract"
    t.string "base_agreement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sponsor_id"], name: "index_contracts_on_sponsor_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.string "access_id"
    t.string "f_name"
    t.string "l_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "sponsor_name"
    t.string "sponsor_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
