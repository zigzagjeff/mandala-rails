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

ActiveRecord::Schema[8.1].define(version: 2026_05_13_211151) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "charts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "mode"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
  end

  create_table "grids", force: :cascade do |t|
    t.bigint "chart_id", null: false
    t.datetime "created_at", null: false
    t.uuid "parent_tile_id"
    t.datetime "updated_at", null: false
    t.index ["chart_id"], name: "index_grids_on_chart_id"
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
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "grid_id", null: false
    t.jsonb "metadata"
    t.integer "position"
    t.string "tile_type"
    t.datetime "updated_at", null: false
    t.index ["grid_id"], name: "index_tiles_on_grid_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "grids", "charts"
  add_foreign_key "sessions", "users"
  add_foreign_key "tiles", "grids"
end
