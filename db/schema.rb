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

ActiveRecord::Schema[7.0].define(version: 2023_06_03_094812) do
  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_players_on_email", unique: true
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  create_table "turns", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "number", default: 1, null: false
    t.text "board"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "number"], name: "index_turns_on_game_id_and_number", unique: true
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  add_foreign_key "players", "games"
  add_foreign_key "turns", "games"
end
