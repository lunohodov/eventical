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

ActiveRecord::Schema.define(version: 2022_10_25_190658) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.bigint "issuer_id"
    t.string "grantee_type"
    t.bigint "grantee_id"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_owner_categories", array: true
    t.text "character_owner_hash"
    t.index ["character_owner_hash"], name: "index_access_tokens_on_character_owner_hash"
    t.index ["grantee_type", "grantee_id"], name: "index_access_tokens_on_grantee"
    t.index ["issuer_id"], name: "index_access_tokens_on_issuer_id"
    t.index ["token"], name: "index_access_tokens_on_token"
  end

  create_table "analytics_counters", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "topic", null: false
    t.bigint "value", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_id", "owner_type", "topic"], name: "analytics_counters_owner_and_topic", unique: true
    t.index ["owner_type", "owner_id"], name: "index_analytics_counters_on_owner"
    t.index ["topic"], name: "index_analytics_counters_on_topic"
  end

  create_table "characters", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "name", null: false
    t.string "token"
    t.string "refresh_token"
    t.datetime "token_expires_at"
    t.string "owner_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "refresh_token_voided_at"
    t.string "time_zone"
    t.datetime "last_event_pull_at"
    t.index ["refresh_token_voided_at"], name: "index_characters_on_refresh_token_voided_at"
    t.index ["uid"], name: "index_characters_on_uid", unique: true
  end

  create_table "data_migration_records", force: :cascade do |t|
    t.string "version", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["version"], name: "index_data_migration_records_on_version", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "uid", null: false
    t.string "title", null: false
    t.datetime "starts_at", null: false
    t.string "importance"
    t.string "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_uid"
    t.string "owner_category"
    t.string "owner_name"
    t.datetime "details_updated_at"
    t.text "character_owner_hash"
    t.index ["character_id", "uid"], name: "index_events_on_character_id_and_uid", unique: true
    t.index ["character_id"], name: "index_events_on_character_id"
    t.index ["character_owner_hash"], name: "index_events_on_character_owner_hash"
    t.index ["details_updated_at"], name: "index_events_on_details_updated_at"
    t.index ["uid", "character_owner_hash"], name: "index_events_on_uid_and_character_owner_hash", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "owner_hash", null: false
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_hash"], name: "index_settings_on_owner_hash", unique: true
  end

end
