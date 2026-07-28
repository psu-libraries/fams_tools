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

ActiveRecord::Schema[8.1].define(version: 2026_04_28_120000) do
  create_table "authors", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.bigint "work_id"
    t.index ["work_id"], name: "fk_rails_ef7807179c"
  end

  create_table "com_efforts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "com_id"
    t.string "course"
    t.string "course_year"
    t.datetime "created_at", null: false
    t.string "event"
    t.string "event_date"
    t.string "event_type"
    t.bigint "faculty_id"
    t.string "faculty_name"
    t.decimal "hours", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["com_id", "course", "event", "event_date"], name: "index_com_efforts_on_com_id_and_course_and_event_and_event_date", unique: true, length: { course: 50, event: 50 }
    t.index ["faculty_id"], name: "fk_rails_c1c0816923"
  end

  create_table "com_qualities", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.float "average_rating"
    t.string "com_id"
    t.string "course"
    t.string "course_year"
    t.datetime "created_at", null: false
    t.string "evaluation_type"
    t.string "event_type"
    t.bigint "faculty_id"
    t.string "faculty_name"
    t.integer "num_evaluations"
    t.datetime "updated_at", null: false
    t.index ["com_id", "course", "course_year"], name: "index_com_qualities_on_com_id_and_course_and_course_year", unique: true
    t.index ["faculty_id"], name: "fk_rails_5da34f5b2e"
  end

  create_table "committees", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "completion_month"
    t.integer "completion_year"
    t.datetime "created_at", null: false
    t.string "degree_name"
    t.bigint "faculty_id", null: false
    t.string "role"
    t.string "role_other"
    t.string "stage_of_completion"
    t.integer "start_month"
    t.integer "start_year"
    t.string "student_fname"
    t.string "student_lname"
    t.string "student_mname"
    t.string "thesis_title"
    t.string "type_of_work"
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_committees_on_faculty_id"
  end

  create_table "contract_faculty_links", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "contract_id"
    t.bigint "faculty_id"
    t.integer "pct_credit"
    t.string "role"
    t.index ["contract_id", "faculty_id"], name: "index_contract_faculty_links_on_contract_id_and_faculty_id", unique: true
    t.index ["faculty_id"], name: "fk_rails_7f7c136a9d"
  end

  create_table "contracts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.date "awarded"
    t.string "base_agreement"
    t.float "effort_academic"
    t.float "effort_calendar"
    t.float "effort_summer"
    t.date "end_date"
    t.integer "funded"
    t.string "grant_contract"
    t.date "notfunded"
    t.integer "osp_key"
    t.integer "requested"
    t.bigint "sponsor_id"
    t.date "start_date"
    t.string "status"
    t.date "submitted"
    t.string "title"
    t.integer "total_anticipated"
    t.index ["osp_key"], name: "index_contracts_on_osp_key", unique: true
    t.index ["sponsor_id"], name: "fk_rails_918599a14c"
  end

  create_table "courses", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "academic_course_id"
    t.integer "calendar_year"
    t.text "course_long_description"
    t.string "course_short_description"
    t.string "term"
    t.index ["academic_course_id", "term", "calendar_year"], name: "index_courses_on_academic_course_id_and_term_and_calendar_year", unique: true
  end

  create_table "editors", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.bigint "work_id"
    t.index ["work_id"], name: "fk_rails_6c877ed7df"
  end

  create_table "external_authors", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "extOrg"
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.bigint "publication_id"
    t.string "role"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publication_id"], name: "fk_rails_eb03e1acd5"
  end

  create_table "faculties", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "access_id"
    t.string "campus"
    t.string "college"
    t.string "com_id"
    t.datetime "created_at", precision: nil
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["access_id"], name: "index_faculties_on_access_id", unique: true
  end

  create_table "integrations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "is_active"
    t.string "process_type"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "personal_contacts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "cn"
    t.datetime "created_at", precision: nil, null: false
    t.string "department"
    t.string "facsimile_telephone_number"
    t.bigint "faculty_id", null: false
    t.string "mail"
    t.string "personal_web"
    t.string "postal_address"
    t.string "ps_office_address"
    t.text "ps_research"
    t.text "ps_teaching"
    t.string "telephone_number"
    t.string "title"
    t.string "uid", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["faculty_id"], name: "index_personal_contacts_on_faculty_id", unique: true
  end

  create_table "presentation_contributors", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "f_name"
    t.string "l_name"
    t.string "m_name"
    t.bigint "presentation_id", null: false
    t.index ["presentation_id"], name: "index_presentation_contributors_on_presentation_id"
  end

  create_table "presentations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "dty_date"
    t.bigint "faculty_id", null: false
    t.string "location"
    t.string "name"
    t.string "org"
    t.string "title"
    t.index ["faculty_id"], name: "index_presentations_on_faculty_id"
  end

  create_table "publication_faculty_links", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", precision: nil, null: false
    t.string "dtm"
    t.bigint "faculty_id"
    t.bigint "publication_id"
    t.string "status"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["faculty_id"], name: "fk_rails_6b4e572ec8"
    t.index ["publication_id"], name: "fk_rails_7abcf28acb"
  end

  create_table "publication_listings", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "publications", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.text "abstract"
    t.integer "articleNumber"
    t.boolean "authors_et_al"
    t.integer "citation_count"
    t.datetime "created_at", precision: nil, null: false
    t.integer "dtd"
    t.integer "dty"
    t.integer "edition"
    t.text "editors"
    t.string "institution"
    t.string "isbnissn"
    t.integer "issue"
    t.string "journal_issn"
    t.string "journal_title"
    t.string "journal_uuid"
    t.string "page_range"
    t.string "pubctyst"
    t.string "publisher"
    t.bigint "rmd_id"
    t.text "secondary_title"
    t.text "title"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "volume"
    t.string "web_address"
  end

  create_table "sections", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "class_campus_code"
    t.string "class_section_code"
    t.string "course_component"
    t.string "course_credits"
    t.bigint "course_id"
    t.string "course_number"
    t.string "course_suffix"
    t.string "cross_listed_flag"
    t.integer "current_enrollment"
    t.bigint "faculty_id"
    t.string "instruction_mode"
    t.integer "instructor_load_factor"
    t.string "instructor_role"
    t.string "subject_code"
    t.integer "xcourse_course_num"
    t.string "xcourse_course_pre"
    t.string "xcourse_course_suf"
    t.index ["course_id"], name: "fk_rails_20b1e5de46"
    t.index ["faculty_id", "course_id", "class_campus_code", "subject_code", "course_number", "course_suffix", "class_section_code", "course_component"], name: "pkey", unique: true, length: { class_campus_code: 50, subject_code: 50, course_suffix: 50, class_section_code: 50, course_component: 50 }
  end

  create_table "sponsors", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sponsor_name"
    t.string "sponsor_type"
    t.index ["sponsor_name"], name: "index_sponsors_on_sponsor_name", unique: true
  end

  create_table "works", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "booktitle"
    t.text "citation"
    t.string "container"
    t.string "contype"
    t.datetime "created_at", precision: nil, null: false
    t.string "date"
    t.string "doi"
    t.string "edition"
    t.string "genre"
    t.string "institution"
    t.string "isbn"
    t.string "item"
    t.string "journal"
    t.string "location"
    t.string "note"
    t.string "pages"
    t.bigint "publication_listing_id"
    t.string "publisher"
    t.string "retrieved"
    t.string "tech"
    t.text "title"
    t.string "translator"
    t.string "unknown"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.string "username"
    t.string "volume"
    t.index ["publication_listing_id"], name: "index_works_on_publication_listing_id"
  end

  create_table "yearlies", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "academic_year"
    t.string "campus"
    t.string "campus_name"
    t.string "college"
    t.string "college_name"
    t.text "departments", size: :long, collation: "utf8mb4_bin"
    t.string "division"
    t.string "endowed_position"
    t.bigint "faculty_id"
    t.string "graduate"
    t.string "hr_code"
    t.string "institute"
    t.string "rank"
    t.string "school"
    t.string "tenure"
    t.string "time_status"
    t.string "title"
    t.index ["faculty_id"], name: "index_yearlies_on_faculty_id", unique: true
    t.check_constraint "json_valid(`departments`)", name: "departments"
  end

  add_foreign_key "authors", "works", on_delete: :cascade
  add_foreign_key "com_efforts", "faculties"
  add_foreign_key "com_qualities", "faculties"
  add_foreign_key "committees", "faculties"
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
