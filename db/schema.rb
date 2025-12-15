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

ActiveRecord::Schema[8.0].define(version: 2025_12_15_105936) do
  create_table "fields", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "label"
    t.string "field_type"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_fields_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "options", force: :cascade do |t|
    t.integer "field_id", null: false
    t.string "label"
    t.string "value"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_options_on_field_id"
  end

  create_table "responses", force: :cascade do |t|
    t.integer "submission_id", null: false
    t.integer "field_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_responses_on_field_id"
    t.index ["submission_id"], name: "index_responses_on_submission_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "form_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_submissions_on_form_id"
  end

  add_foreign_key "fields", "forms"
  add_foreign_key "options", "fields"
  add_foreign_key "responses", "fields"
  add_foreign_key "responses", "submissions"
  add_foreign_key "submissions", "forms"
end
