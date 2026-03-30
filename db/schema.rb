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

ActiveRecord::Schema[8.1].define(version: 2026_03_30_160652) do
  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip", null: false
    t.datetime "last_activity_at", null: false
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.integer "visitor_id"
    t.index ["last_activity_at"], name: "index_conversations_on_last_activity_at"
    t.index ["visitor_id"], name: "index_conversations_on_visitor_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
  end

  create_table "now_entries", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_views", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "path", null: false
    t.string "referer"
    t.string "session_id"
    t.string "trace_id"
    t.string "user_agent"
    t.integer "visitor_id"
    t.index ["created_at"], name: "index_page_views_on_created_at"
    t.index ["path"], name: "index_page_views_on_path"
    t.index ["visitor_id"], name: "index_page_views_on_visitor_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.boolean "published"
    t.datetime "published_at"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured"
    t.string "name"
    t.string "tech_tags"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "site_configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.datetime "updated_at", null: false
    t.text "value"
  end

  create_table "visitors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "first_seen_at", null: false
    t.string "flag_reason"
    t.datetime "flagged_at"
    t.string "flagged_by"
    t.string "ip"
    t.datetime "last_seen_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["ip"], name: "index_visitors_on_ip", unique: true
  end

  add_foreign_key "conversations", "visitors"
  add_foreign_key "messages", "conversations"
  add_foreign_key "page_views", "visitors"
end
