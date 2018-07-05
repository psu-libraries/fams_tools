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

ActiveRecord::Schema.define(version: 2018050314201234) do

  create_table "contract_faculty_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "role"
    t.integer "pct_credit"
    t.bigint "contract_id"
    t.bigint "faculty_id"
    t.index ["contract_id"], name: "fk_rails_5e66e5d7a9"
    t.index ["faculty_id"], name: "fk_rails_7f7c136a9d"
  end

  create_table "contracts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "osp_key"
    t.string "title"
    t.bigint "sponsor_id"
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
    t.index ["osp_key"], name: "index_contracts_on_osp_key", unique: true
    t.index ["sponsor_id"], name: "fk_rails_918599a14c"
  end

  create_table "courses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "academic_course_id"
    t.string "term"
    t.integer "calendar_year"
    t.string "course_short_description"
    t.text "course_long_description"
    t.index ["academic_course_id"], name: "index_courses_on_academic_course_id", unique: true
  end

  create_table "external_authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "publication_id"
    t.string "f_name"
    t.string "m_name"
    t.string "l_name"
    t.string "role"
    t.string "extOrg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "fk_rails_eb03e1acd5"
  end

  create_table "faculties", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "access_id"
    t.bigint "user_id"
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.index ["access_id"], name: "index_faculties_on_access_id", unique: true
  end

  create_table "publications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "faculty_id"
    t.text "title"
    t.string "category"
    t.integer "volume"
    t.integer "dty"
    t.string "dtm"
    t.integer "dtd"
    t.string "journal_title"
    t.string "journal_issn"
    t.integer "journal_num"
    t.string "pages"
    t.integer "articleNumber"
    t.boolean "peerReview"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "fk_rails_8c9222b60f"
  end

  create_table "pure_ids", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "pure_id"
    t.bigint "faculty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "fk_rails_340ab8b4e7"
  end

  create_table "sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "class_campus_code"
    t.string "cross_listed_flag"
    t.integer "course_number"
    t.string "course_suffix"
    t.string "subject_code"
    t.string "class_section_code"
    t.string "course_credits"
    t.integer "current_enrollment"
    t.integer "instructor_load_factor"
    t.string "instruction_mode"
    t.string "course_component"
    t.string "xcourse_course_pre"
    t.integer "xcourse_course_num"
    t.string "xcourse_course_suf"
    t.bigint "course_id"
    t.bigint "faculty_id"
    t.index ["course_id"], name: "fk_rails_20b1e5de46"
    t.index ["faculty_id"], name: "fk_rails_756b5a76ef"
  end

  create_table "sponsors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "sponsor_name"
    t.string "sponsor_type"
    t.index ["sponsor_name"], name: "index_sponsors_on_sponsor_name", unique: true
  end

  add_foreign_key "contract_faculty_links", "contracts"
  add_foreign_key "contract_faculty_links", "faculties"
  add_foreign_key "contracts", "sponsors"
  add_foreign_key "external_authors", "publications"
  add_foreign_key "publications", "faculties"
  add_foreign_key "pure_ids", "faculties"
  add_foreign_key "sections", "courses"
  add_foreign_key "sections", "faculties"
end
