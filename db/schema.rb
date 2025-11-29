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

ActiveRecord::Schema[8.0].define(version: 2025_11_29_080000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "spotify_artist_id"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", null: false
    t.boolean "published", default: true, null: false
    t.index ["name"], name: "index_artists_on_name", unique: true
    t.index ["published"], name: "index_artists_on_published"
    t.index ["spotify_artist_id"], name: "index_artists_on_spotify_artist_id_unique_when_present", unique: true, where: "(spotify_artist_id IS NOT NULL)"
    t.index ["uuid"], name: "index_artists_on_uuid", unique: true
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
    t.boolean "timetable_published", default: false, null: false
    t.index ["slug"], name: "index_festivals_on_slug", unique: true
    t.index ["start_date"], name: "index_festivals_on_start_date"
    t.index ["timetable_published"], name: "index_festivals_on_timetable_published"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.text "description"
    t.string "category"
    t.boolean "template", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template"], name: "index_items_on_template"
    t.index ["user_id", "name"], name: "index_items_on_user_and_name_when_owned", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "packing_list_items", force: :cascade do |t|
    t.bigint "packing_list_id", null: false
    t.bigint "item_id", null: false
    t.boolean "checked", default: false, null: false
    t.integer "position", default: 0, null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_packing_list_items_on_item_id"
    t.index ["packing_list_id", "item_id"], name: "index_packing_list_items_on_list_and_item", unique: true
    t.index ["packing_list_id", "position"], name: "index_packing_list_items_on_packing_list_id_and_position"
    t.index ["packing_list_id"], name: "index_packing_list_items_on_packing_list_id"
  end

  create_table "packing_lists", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.boolean "template", default: false, null: false
    t.string "template_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["template"], name: "index_packing_lists_on_template"
    t.index ["user_id", "title"], name: "index_packing_lists_on_user_and_title_when_owned", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_packing_lists_on_user_id"
    t.index ["uuid"], name: "index_packing_lists_on_uuid", unique: true
  end

  create_table "stage_performances", force: :cascade do |t|
    t.bigint "festival_day_id", null: false
    t.bigint "stage_id"
    t.bigint "artist_id", null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id", "starts_at"], name: "index_stage_performances_on_artist_id_and_starts_at"
    t.index ["artist_id"], name: "index_stage_performances_on_artist_id"
    t.index ["festival_day_id", "artist_id"], name: "index_stage_performances_on_festival_day_id_and_artist_id", unique: true
    t.index ["festival_day_id", "stage_id", "artist_id", "starts_at"], name: "uniq_sp_slot_when_scheduled", unique: true, where: "((status = 1) AND (stage_id IS NOT NULL) AND (starts_at IS NOT NULL))"
    t.index ["festival_day_id", "stage_id", "starts_at"], name: "idx_on_festival_day_id_stage_id_starts_at_49921a49b2"
    t.index ["festival_day_id"], name: "index_stage_performances_on_festival_day_id"
    t.index ["stage_id"], name: "index_stage_performances_on_stage_id"
    t.exclusion_constraint "stage_id WITH =, tsrange(starts_at, ends_at, '[)'::text) WITH &&", where: "(status = 1) AND (stage_id IS NOT NULL) AND (starts_at IS NOT NULL) AND (ends_at IS NOT NULL)", using: :gist, name: "no_overlap_on_same_stage_when_scheduled"
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

  create_table "user_artist_favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_user_artist_favorites_on_artist_id"
    t.index ["user_id", "artist_id"], name: "index_user_artist_favorites_on_user_id_and_artist_id", unique: true
    t.index ["user_id"], name: "index_user_artist_favorites_on_user_id"
  end

  create_table "user_festival_favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "festival_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["festival_id"], name: "index_user_festival_favorites_on_festival_id"
    t.index ["user_id", "festival_id"], name: "index_user_festival_favorites_on_user_id_and_festival_id", unique: true
    t.index ["user_id"], name: "index_user_festival_favorites_on_user_id"
  end

  create_table "user_timetable_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stage_performance_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stage_performance_id"], name: "index_user_timetable_entries_on_stage_performance_id"
    t.index ["user_id", "stage_performance_id"], name: "idx_user_timetable_entries_uniqueness", unique: true
    t.index ["user_id"], name: "index_user_timetable_entries_on_user_id"
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
    t.uuid "uuid", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  add_foreign_key "festival_days", "festivals"
  add_foreign_key "items", "users"
  add_foreign_key "packing_list_items", "items"
  add_foreign_key "packing_list_items", "packing_lists"
  add_foreign_key "packing_lists", "users"
  add_foreign_key "stage_performances", "artists"
  add_foreign_key "stage_performances", "festival_days"
  add_foreign_key "stage_performances", "stages"
  add_foreign_key "stages", "festivals"
  add_foreign_key "user_artist_favorites", "artists"
  add_foreign_key "user_artist_favorites", "users"
  add_foreign_key "user_festival_favorites", "festivals"
  add_foreign_key "user_festival_favorites", "users"
  add_foreign_key "user_timetable_entries", "stage_performances"
  add_foreign_key "user_timetable_entries", "users"
end
