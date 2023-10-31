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

ActiveRecord::Schema.define(version: 2023_10_31_072018) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower((name)::text)", name: "brands_name_unique_idx", unique: true
  end

  create_table "car_suggestions", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.bigint "user_id", null: false
    t.float "rank_score"
    t.integer "label"
    t.index ["car_id"], name: "index_car_suggestions_on_car_id"
    t.index ["label"], name: "index_car_suggestions_on_label"
    t.index ["rank_score"], name: "index_car_suggestions_on_rank_score"
    t.index ["user_id", "car_id"], name: "car_suggestions_unique_idx", unique: true
  end

  create_table "cars", force: :cascade do |t|
    t.string "model"
    t.bigint "brand_id", null: false
    t.decimal "price", precision: 9, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_cars_on_brand_id"
    t.index ["price"], name: "index_cars_on_price"
    t.check_constraint "price > (0)::numeric", name: "cars_positive_price"
  end

  create_table "user_preferred_brands", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "brand_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_user_preferred_brands_on_brand_id"
    t.index ["user_id", "brand_id"], name: "index_user_preferred_brands_on_user_id_and_brand_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.int8range "preferred_price_range"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "TRIM(BOTH FROM lower((email)::text))", name: "users_email_unique_idx", unique: true
  end

  add_foreign_key "car_suggestions", "cars", on_delete: :cascade
  add_foreign_key "car_suggestions", "users", on_delete: :cascade
  add_foreign_key "cars", "brands"
  add_foreign_key "user_preferred_brands", "brands"
  add_foreign_key "user_preferred_brands", "users"
end
