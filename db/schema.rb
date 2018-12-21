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

ActiveRecord::Schema.define(version: 2018_12_25_070754) do

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
    t.index ["grantee_type", "grantee_id"], name: "index_access_tokens_on_grantee_type_and_grantee_id"
    t.index ["issuer_id"], name: "index_access_tokens_on_issuer_id"
    t.index ["token"], name: "index_access_tokens_on_token"
  end

  create_table "characters", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "name", null: false
    t.string "token"
    t.string "refresh_token"
    t.datetime "token_expires_at"
    t.string "scopes"
    t.string "token_type"
    t.string "owner_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_characters_on_uid", unique: true
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
    t.index ["character_id"], name: "index_events_on_character_id"
    t.index ["uid"], name: "index_events_on_uid", unique: true
  end

end
