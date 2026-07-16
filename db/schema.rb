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

ActiveRecord::Schema[8.1].define(version: 2026_07_15_190349) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.integer "eventable_id", null: false
    t.string "eventable_type", null: false
    t.integer "mandala_id", null: false
    t.json "particulars", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_events_on_creator_id"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable"
    t.index ["mandala_id", "created_at"], name: "index_events_on_mandala_id_and_created_at"
  end

  create_table "grids", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.bigint "mandala_id", null: false
    t.bigint "parent_tile_id"
    t.datetime "updated_at", null: false
    t.index ["mandala_id"], name: "index_grids_on_mandala_id"
    t.index ["parent_tile_id"], name: "index_grids_on_parent_tile_id", unique: true, where: "parent_tile_id IS NOT NULL"
  end

  create_table "mandalas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tiles", force: :cascade do |t|
    t.text "agentic_summary"
    t.datetime "created_at", null: false
    t.bigint "grid_id", null: false
    t.text "metadata"
    t.integer "position"
    t.string "subtitle"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["grid_id"], name: "index_tiles_on_grid_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events", "mandalas"
  add_foreign_key "events", "users", column: "creator_id"
  add_foreign_key "grids", "mandalas"
  add_foreign_key "sessions", "users"
  add_foreign_key "tiles", "grids"
end
