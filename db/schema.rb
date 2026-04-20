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

ActiveRecord::Schema[8.0].define(version: 2026_04_19_010000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_type", null: false
    t.text "item_name", null: false
    t.index ["content_type"], name: "index_activity_logs_on_content_type"
    t.index ["created_at"], name: "index_activity_logs_on_created_at", order: :desc
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "faqs", force: :cascade do |t|
    t.text "question", null: false
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.index ["ideathon_year_id"], name: "index_faqs_on_ideathon_year_id"
  end

  create_table "ideathon_events", force: :cascade do |t|
    t.bigint "ideathon_year_id", null: false
    t.string "event_name"
    t.text "event_description"
    t.date "event_date"
    t.time "event_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_ideathon_events_on_ideathon_year_id"
  end

  create_table "ideathon_years", force: :cascade do |t|
    t.integer "year", null: false
    t.string "theme"
    t.string "name"
    t.text "description"
    t.string "location"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_ideathon_years_single_active", unique: true, where: "(is_active = true)"
    t.index ["year"], name: "index_ideathon_years_on_year", unique: true
  end

  create_table "manager_action_logs", force: :cascade do |t|
    t.string "action", null: false
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "metadata", default: {}, null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["action"], name: "index_manager_action_logs_on_action"
    t.index ["created_at"], name: "index_manager_action_logs_on_created_at"
    t.index ["record_type", "record_id"], name: "index_manager_action_logs_on_record_type_and_record_id"
    t.index ["user_id"], name: "index_manager_action_logs_on_user_id"
  end

  create_table "mentors_judges", force: :cascade do |t|
    t.string "name", null: false
    t.string "photo_url"
    t.text "bio"
    t.boolean "is_judge", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_title"
    t.bigint "ideathon_year_id", null: false
    t.index ["ideathon_year_id"], name: "index_mentors_judges_on_ideathon_year_id"
  end

  create_table "registered_attendees", force: :cascade do |t|
    t.bigint "ideathon_year_id", null: false
    t.bigint "team_id", null: false
    t.string "attendee_name"
    t.string "attendee_phone"
    t.string "attendee_email"
    t.string "attendee_major"
    t.string "attendee_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ideathon_year_id"], name: "index_registered_attendees_on_ideathon_year_id"
    t.index ["team_id"], name: "index_registered_attendees_on_team_id"
  end

  create_table "rules", force: :cascade do |t|
    t.text "rule_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ideathon_year_id", null: false
    t.index ["ideathon_year_id"], name: "index_rules_on_ideathon_year_id"
  end

  create_table "sponsors_partners", force: :cascade do |t|
    t.string "name", null: false
    t.string "logo_url"
    t.text "blurb"
    t.boolean "is_sponsor", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_title"
    t.bigint "ideathon_year_id", null: false
    t.index ["ideathon_year_id"], name: "index_sponsors_partners_on_ideathon_year_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "ideathon_year_id", null: false
    t.string "team_name"
    t.boolean "unassigned", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "ideathon_year_id, lower(btrim((team_name)::text))", name: "index_teams_unique_name_per_year", unique: true, where: "(unassigned = false)"
    t.index ["ideathon_year_id"], name: "index_teams_on_ideathon_year_id"
    t.index ["ideathon_year_id"], name: "index_teams_one_unassigned_per_year", unique: true, where: "(unassigned = true)"
    t.check_constraint "unassigned = true OR char_length(btrim(coalesce(team_name::text, ''::text))) > 0", name: "teams_named_when_not_unassigned"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name"
    t.string "uid"
    t.string "provider"
    t.string "role", default: "unauthorized", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "faqs", "ideathon_years"
  add_foreign_key "ideathon_events", "ideathon_years"
  add_foreign_key "manager_action_logs", "users"
  add_foreign_key "mentors_judges", "ideathon_years"
  add_foreign_key "registered_attendees", "ideathon_years"
  add_foreign_key "registered_attendees", "teams"
  add_foreign_key "rules", "ideathon_years"
  add_foreign_key "sponsors_partners", "ideathon_years"
  add_foreign_key "teams", "ideathon_years"
end
