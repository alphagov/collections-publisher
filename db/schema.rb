# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150423132818) do

  create_table "list_items", force: true do |t|
    t.string   "api_url"
    t.integer  "index",      default: 0, null: false
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "list_items", ["list_id", "index"], name: "index_list_items_on_list_id_and_index", using: :btree

  create_table "lists", force: true do |t|
    t.string  "name"
    t.integer "index",    default: 0,    null: false
    t.boolean "dirty",    default: true, null: false
    t.integer "topic_id"
  end

  add_index "lists", ["topic_id"], name: "index_lists_on_topic_id", using: :btree

  create_table "tag_associations", force: true do |t|
    t.integer  "from_tag_id", null: false
    t.integer  "to_tag_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_associations", ["from_tag_id", "to_tag_id"], name: "index_tag_associations_on_from_tag_id_and_to_tag_id", unique: true, using: :btree
  add_index "tag_associations", ["to_tag_id"], name: "index_tag_associations_on_to_tag_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "type"
    t.string   "slug",        null: false
    t.string   "title",       null: false
    t.string   "description"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_id",  null: false
    t.string   "state",       null: false
  end

  add_index "tags", ["slug", "parent_id"], name: "index_tags_on_slug_and_parent_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "uid",                                 null: false
    t.string  "organisation_slug"
    t.string  "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled",            default: false
  end

  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

end
