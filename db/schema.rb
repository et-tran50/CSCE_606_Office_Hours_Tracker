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

ActiveRecord::Schema[7.2].define(version: 2024_11_13_035515) do
  create_table "attendances", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "sign_in_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "course_number"
    t.string "course_name"
    t.string "instructor_name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ta_attendances", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "sign_in_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "checked_in_names"
    t.index ["user_id"], name: "index_ta_attendances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "provider"
    t.string "role"
    t.string "profile_picture"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "ta_attendances", "users"
end
