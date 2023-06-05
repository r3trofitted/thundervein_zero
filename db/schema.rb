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

ActiveRecord::Schema[7.0].define(version: 2023_06_03_165434) do
  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "type"
    t.integer "turn_id", null: false
    t.integer "player_id", null: false
    t.string "origin", null: false
    t.string "target", null: false
    t.integer "units", null: false
    t.integer "engagement"
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_orders_on_player_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["turn_id"], name: "index_orders_on_turn_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "email"], name: "index_players_on_game_id_and_email", unique: true
    t.index ["game_id", "name"], name: "index_players_on_game_id_and_name", unique: true
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  create_table "turns", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "number", default: 1, null: false
    t.text "board"
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "number"], name: "index_turns_on_game_id_and_number", unique: true
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  add_foreign_key "orders", "players"
  add_foreign_key "orders", "turns"
  add_foreign_key "players", "games"
  add_foreign_key "turns", "games"
end
