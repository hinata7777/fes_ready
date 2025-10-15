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

ActiveRecord::Schema[8.0].define(version: 2025_10_15_033024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "spotify_artist_id"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_artists_on_name"
    t.index ["spotify_artist_id"], name: "index_artists_on_spotify_artist_id_unique_when_present", unique: true, where: "(spotify_artist_id IS NOT NULL)"
  end

  create_table "festival_days", force: :cascade do |t|
    t.bigint "festival_id", null: false
    t.date "date", null: false
    t.datetime "doors_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["festival_id", "date"], name: "index_festival_days_on_festival_id_and_date", unique: true
    t.index ["festival_id"], name: "index_festival_days_on_festival_id"
  end

  create_table "festivals", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "venue_name"
    t.string "city"
    t.string "prefecture"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "timezone", default: "Asia/Tokyo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "official_url"
    t.index ["slug"], name: "index_festivals_on_slug", unique: true
    t.index ["start_date"], name: "index_festivals_on_start_date"
  end

  create_table "stages", force: :cascade do |t|
    t.bigint "festival_id", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.integer "environment"
    t.string "note"
    t.string "color_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["festival_id", "sort_order"], name: "index_stages_on_festival_id_and_sort_order"
    t.index ["festival_id"], name: "index_stages_on_festival_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname", null: false
    t.integer "role", default: 0, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "festival_days", "festivals"
  add_foreign_key "stages", "festivals"
end
