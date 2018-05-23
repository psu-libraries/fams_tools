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

ActiveRecord::Schema.define(version: 20180523194425) do

  create_table "publication_listings", force: :cascade do |t|
    t.string "path"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "works", force: :cascade do |t|
    t.integer "publication_listing_id"
    t.string "author"
    t.string "title"
    t.string "journal"
    t.string "volume"
    t.string "edition"
    t.string "pages"
    t.string "date"
    t.string "item"
    t.string "booktitle"
    t.string "container"
    t.string "doi"
    t.string "editor"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_listing_id"], name: "index_works_on_publication_listing_id"
  end

end
