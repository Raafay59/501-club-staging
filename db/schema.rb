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

ActiveRecord::Schema[8.1].define(version: 2026_04_21_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor_email"
    t.string "actor_name"
    t.bigint "admin_id"
    t.string "content_type", null: false
    t.datetime "created_at", null: false
    t.text "item_name", null: false
    t.text "message", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_activity_logs_on_admin_id"
    t.index ["content_type"], name: "index_activity_logs_on_content_type"
    t.index ["created_at"], name: "index_activity_logs_on_created_at", order: :desc
  end

  create_table "admins", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name"
    t.string "role", default: "admin", null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["role"], name: "index_admins_on_role"
  end

  create_table "faqs", force: :cascade do |t|
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.text "question", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_faqs_on_ideathon_year_id"
  end

  create_table "ideathon_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "event_date"
    t.text "event_description"
    t.string "event_name"
    t.time "event_time"
    t.bigint "ideathon_year_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_ideathon_events_on_ideathon_year_id"
  end

  create_table "ideathon_years", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.boolean "is_active"
    t.string "location"
    t.string "name"
    t.date "start_date"
    t.string "theme"
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["year"], name: "index_ideathon_years_on_year", unique: true
  end

  create_table "manager_action_logs", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor_email"
    t.string "actor_name"
    t.bigint "admin_id"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "record_id"
    t.string "record_type"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["action"], name: "index_manager_action_logs_on_action"
    t.index ["admin_id"], name: "index_manager_action_logs_on_admin_id"
    t.index ["created_at"], name: "index_manager_action_logs_on_created_at"
    t.index ["record_type", "record_id"], name: "index_manager_action_logs_on_record_type_and_record_id"
  end

  create_table "mentors_judges", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.boolean "is_judge", default: false, null: false
    t.string "job_title"
    t.string "name", null: false
    t.string "photo_url"
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id", "name"], name: "index_mentors_judges_on_ideathon_year_id_and_name"
    t.index ["ideathon_year_id"], name: "index_mentors_judges_on_ideathon_year_id"
  end

  create_table "registered_attendees", force: :cascade do |t|
    t.string "attendee_class"
    t.string "attendee_email"
    t.string "attendee_major"
    t.string "attendee_name"
    t.string "attendee_phone"
    t.datetime "created_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.bigint "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_registered_attendees_on_ideathon_year_id"
    t.index ["team_id"], name: "index_registered_attendees_on_team_id"
  end

  create_table "rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.text "rule_text", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_rules_on_ideathon_year_id"
  end

  create_table "sponsors_partners", force: :cascade do |t|
    t.text "blurb"
    t.datetime "created_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.boolean "is_sponsor", default: false, null: false
    t.string "job_title"
    t.string "logo_url"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id", "name"], name: "index_sponsors_partners_on_ideathon_year_id_and_name"
    t.index ["ideathon_year_id"], name: "index_sponsors_partners_on_ideathon_year_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.string "team_name"
    t.boolean "unassigned", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_teams_on_ideathon_year_id"
    t.index ["ideathon_year_id"], name: "index_teams_one_unassigned_per_ideathon_year", unique: true, where: "(unassigned = true)"
  end

  add_foreign_key "activity_logs", "admins"
  add_foreign_key "faqs", "ideathon_years"
  add_foreign_key "ideathon_events", "ideathon_years"
  add_foreign_key "manager_action_logs", "admins"
  add_foreign_key "mentors_judges", "ideathon_years"
  add_foreign_key "registered_attendees", "ideathon_years"
  add_foreign_key "registered_attendees", "teams"
  add_foreign_key "rules", "ideathon_years"
  add_foreign_key "sponsors_partners", "ideathon_years"
  add_foreign_key "teams", "ideathon_years"
end
