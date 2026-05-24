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

ActiveRecord::Schema[7.1].define(version: 2026_05_24_000006) do
  create_table "approval_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "superior_id", null: false
    t.date "target_month", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["superior_id"], name: "index_approval_requests_on_superior_id"
    t.index ["user_id"], name: "index_approval_requests_on_user_id"
  end

  create_table "attendance_change_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "superior_id", null: false
    t.date "worked_on", null: false
    t.datetime "before_started_at"
    t.datetime "after_started_at"
    t.string "note"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["superior_id"], name: "index_attendance_change_requests_on_superior_id"
    t.index ["user_id"], name: "index_attendance_change_requests_on_user_id"
  end

  create_table "attendance_correction_logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "worked_on", null: false
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.datetime "after_started_at"
    t.datetime "after_finished_at"
    t.bigint "approver_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_attendance_correction_logs_on_approver_id"
    t.index ["user_id"], name: "index_attendance_correction_logs_on_user_id"
  end

  create_table "attendances", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "base_number", null: false
    t.string "name", null: false
    t.integer "attendance_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "overtime_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "superior_id", null: false
    t.date "worked_on", null: false
    t.datetime "scheduled_end_time", null: false
    t.boolean "next_day", default: false, null: false
    t.text "work_content"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["superior_id"], name: "index_overtime_requests_on_superior_id"
    t.index ["user_id"], name: "index_overtime_requests_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin"
    t.string "department"
    t.datetime "basic_time", default: "2026-05-22 23:00:00"
    t.datetime "work_time", default: "2026-05-22 22:30:00"
    t.boolean "superior", default: false, null: false
    t.string "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "approval_requests", "users"
  add_foreign_key "approval_requests", "users", column: "superior_id"
  add_foreign_key "attendance_change_requests", "users"
  add_foreign_key "attendance_change_requests", "users", column: "superior_id"
  add_foreign_key "attendance_correction_logs", "users"
  add_foreign_key "attendance_correction_logs", "users", column: "approver_id"
  add_foreign_key "attendances", "users"
  add_foreign_key "overtime_requests", "users"
  add_foreign_key "overtime_requests", "users", column: "superior_id"
end
