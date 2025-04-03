# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_02_17_205946) do
  create_table "authors", charset: "utf8mb4", force: :cascade do |t|
    t.string "f_name"
    t.string "m_name"
    t.string "l_name"
    t.bigint "work_id"
    t.index ["work_id"], name: "fk_rails_ef7807179c"
  end

  create_table "com_efforts", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "com_id"
    t.string "course_year"
    t.string "course"
    t.string "event_type"
    t.string "faculty_name"
    t.string "event"
    t.decimal "hours", precision: 10, scale: 2
    t.bigint "faculty_id"
    t.string "event_date"
    t.index ["com_id", "course", "event", "event_date"], name: "index_com_efforts_on_com_id_and_course_and_event_and_event_date", unique: true, length: { course: 50, event: 50 }
    t.index ["faculty_id"], name: "fk_rails_c1c0816923"
  end

  create_table "com_qualities", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "com_id"
    t.string "course_year"
    t.string "course"
    t.string "event_type"
    t.string "faculty_name"
    t.string "evaluation_type"
    t.float "average_rating"
    t.integer "num_evaluations"
    t.bigint "faculty_id"
    t.index ["com_id", "course", "course_year"], name: "index_com_qualities_on_com_id_and_course_and_course_year", unique: true
    t.index ["faculty_id"], name: "fk_rails_5da34f5b2e"
  end

  create_table "contract_faculty_links", charset: "utf8mb4", force: :cascade do |t|
    t.string "role"
    t.integer "pct_credit"
    t.bigint "contract_id"
    t.bigint "faculty_id"
    t.index ["contract_id", "faculty_id"], name: "index_contract_faculty_links_on_contract_id_and_faculty_id", unique: true
    t.index ["faculty_id"], name: "fk_rails_7f7c136a9d"
  end

  create_table "contracts", charset: "utf8mb4", force: :cascade do |t|
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
    t.date "notfunded"
    t.float "effort_academic"
    t.float "effort_summer"
    t.float "effort_calendar"
    t.index ["osp_key"], name: "index_contracts_on_osp_key", unique: true
    t.index ["sponsor_id"], name: "fk_rails_918599a14c"
  end

  create_table "courses", charset: "utf8mb4", force: :cascade do |t|
    t.integer "academic_course_id"
    t.string "term"
    t.integer "calendar_year"
    t.string "course_short_description"
    t.text "course_long_description"
    t.index ["academic_course_id", "term", "calendar_year"], name: "index_courses_on_academic_course_id_and_term_and_calendar_year", unique: true
  end

  create_table "editors", charset: "utf8mb4", force: :cascade do |t|
    t.string "f_name"
    t.string "m_name"
    t.string "l_name"
    t.bigint "work_id"
    t.index ["work_id"], name: "fk_rails_6c877ed7df"
  end

  create_table "external_authors", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "publication_id"
    t.string "f_name"
    t.string "m_name"
    t.string "l_name"
    t.string "role"
    t.string "extOrg"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publication_id"], name: "fk_rails_eb03e1acd5"
  end

  create_table "faculties", charset: "utf8mb4", force: :cascade do |t|
    t.string "access_id"
    t.bigint "user_id"
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.string "college"
    t.string "campus"
    t.string "com_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["access_id"], name: "index_faculties_on_access_id", unique: true
  end

  create_table "integrations", charset: "utf8mb4", force: :cascade do |t|
    t.string "process_type"
    t.boolean "is_active"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "personal_contacts", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "faculty_id", null: false
    t.string "telephone_number"
    t.string "postal_address"
    t.string "department"
    t.string "title"
    t.text "ps_research"
    t.text "ps_teaching"
    t.string "ps_office_address"
    t.string "facsimile_telephone_number"
    t.string "cn"
    t.string "mail"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uid", null: false
    t.string "personal_web"
    t.index ["faculty_id"], name: "index_personal_contacts_on_faculty_id", unique: true
  end

  create_table "presentation_contributors", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "presentation_id", null: false
    t.string "f_name"
    t.string "m_name"
    t.string "l_name"
    t.index ["presentation_id"], name: "index_presentation_contributors_on_presentation_id"
  end

  create_table "presentations", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "faculty_id", null: false
    t.string "title"
    t.string "dty_date"
    t.string "name"
    t.string "org"
    t.string "location"
    t.index ["faculty_id"], name: "index_presentations_on_faculty_id"
  end

  create_table "publication_faculty_links", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "faculty_id"
    t.bigint "publication_id"
    t.string "category"
    t.string "dtm"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["faculty_id"], name: "fk_rails_6b4e572ec8"
    t.index ["publication_id"], name: "fk_rails_7abcf28acb"
  end

  create_table "publication_listings", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "publications", charset: "utf8mb4", force: :cascade do |t|
    t.text "title"
    t.integer "volume"
    t.integer "dty"
    t.integer "dtd"
    t.string "journal_title"
    t.string "journal_issn"
    t.integer "issue"
    t.string "journal_uuid"
    t.string "page_range"
    t.integer "articleNumber"
    t.string "publisher"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "edition"
    t.text "abstract"
    t.text "secondary_title"
    t.integer "citation_count"
    t.boolean "authors_et_al"
    t.string "web_address"
    t.text "editors"
    t.string "institution"
    t.string "isbnissn"
    t.string "pubctyst"
    t.bigint "rmd_id"
  end

  create_table "sections", charset: "utf8mb4", force: :cascade do |t|
    t.string "class_campus_code"
    t.string "cross_listed_flag"
    t.string "course_number"
    t.string "course_suffix"
    t.string "subject_code"
    t.string "class_section_code"
    t.string "course_credits"
    t.integer "current_enrollment"
    t.integer "instructor_load_factor"
    t.string "instruction_mode"
    t.string "instructor_role"
    t.string "course_component"
    t.string "xcourse_course_pre"
    t.integer "xcourse_course_num"
    t.string "xcourse_course_suf"
    t.bigint "course_id"
    t.bigint "faculty_id"
    t.index ["course_id"], name: "fk_rails_20b1e5de46"
    t.index ["faculty_id", "course_id", "class_campus_code", "subject_code", "course_number", "course_suffix", "class_section_code", "course_component"], name: "pkey", unique: true, length: { class_campus_code: 50, subject_code: 50, course_suffix: 50, class_section_code: 50, course_component: 50 }
  end

  create_table "sponsors", charset: "utf8mb4", force: :cascade do |t|
    t.string "sponsor_name"
    t.string "sponsor_type"
    t.index ["sponsor_name"], name: "index_sponsors_on_sponsor_name", unique: true
  end

  create_table "works", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "publication_listing_id"
    t.text "title"
    t.string "journal"
    t.string "volume"
    t.string "edition"
    t.string "pages"
    t.string "item"
    t.string "booktitle"
    t.string "container"
    t.string "contype"
    t.string "genre"
    t.string "doi"
    t.string "institution"
    t.string "isbn"
    t.string "location"
    t.string "note"
    t.string "publisher"
    t.string "retrieved"
    t.string "tech"
    t.string "translator"
    t.string "unknown"
    t.string "url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.string "date"
    t.text "citation"
    t.index ["publication_listing_id"], name: "index_works_on_publication_listing_id"
  end

  create_table "yearlies", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "faculty_id"
    t.string "academic_year"
    t.string "campus"
    t.string "campus_name"
    t.string "college"
    t.string "college_name"
    t.string "school"
    t.string "division"
    t.string "institute"
    t.string "title"
    t.string "rank"
    t.string "tenure"
    t.string "endowed_position"
    t.string "graduate"
    t.string "time_status"
    t.string "hr_code"
    t.text "departments", size: :long, collation: "utf8mb4_bin"
    t.index ["faculty_id"], name: "index_yearlies_on_faculty_id", unique: true
  end

  add_foreign_key "authors", "works", on_delete: :cascade
  add_foreign_key "com_efforts", "faculties"
  add_foreign_key "com_qualities", "faculties"
  add_foreign_key "contract_faculty_links", "contracts"
  add_foreign_key "contract_faculty_links", "faculties"
  add_foreign_key "contracts", "sponsors"
  add_foreign_key "editors", "works", on_delete: :cascade
  add_foreign_key "external_authors", "publications"
  add_foreign_key "personal_contacts", "faculties"
  add_foreign_key "presentation_contributors", "presentations", on_delete: :cascade
  add_foreign_key "presentations", "faculties", on_delete: :cascade
  add_foreign_key "publication_faculty_links", "faculties"
  add_foreign_key "publication_faculty_links", "publications"
  add_foreign_key "sections", "courses"
  add_foreign_key "sections", "faculties"
  add_foreign_key "works", "publication_listings", on_delete: :cascade
  add_foreign_key "yearlies", "faculties"
end
