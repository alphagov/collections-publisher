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

ActiveRecord::Schema.define(version: 20151110220915) do

  create_table "list_items", force: :cascade do |t|
    t.string   "base_path",  limit: 255
    t.integer  "index",      limit: 4,   default: 0, null: false
    t.integer  "list_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 255
  end

  add_index "list_items", ["list_id", "index"], name: "index_list_items_on_list_id_and_index", using: :btree

  create_table "lists", force: :cascade do |t|
    t.string  "name",   limit: 255
    t.integer "index",  limit: 4,   default: 0, null: false
    t.integer "tag_id", limit: 4,               null: false
  end

  add_index "lists", ["tag_id"], name: "index_lists_on_tag_id", using: :btree

  create_table "newest_redirects", force: :cascade do |t|
    t.integer  "tag_id",                 limit: 4,   null: false
    t.string   "original_tag_base_path", limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "content_id",             limit: 255, null: false
  end

  add_index "newest_redirects", ["content_id"], name: "index_newest_redirects_on_content_id", unique: true, using: :btree
  add_index "newest_redirects", ["original_tag_base_path"], name: "index_newest_redirects_on_original_tag_base_path", unique: true, using: :btree
  add_index "newest_redirects", ["tag_id"], name: "index_newest_redirects_on_tag_id", using: :btree

  create_table "redirect_routes", force: :cascade do |t|
    t.integer  "redirect_id",    limit: 4
    t.string   "from_base_path", limit: 255
    t.string   "to_base_path",   limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "redirect_routes", ["from_base_path"], name: "index_redirect_routes_on_from_base_path", unique: true, using: :btree
  add_index "redirect_routes", ["redirect_id"], name: "index_redirect_routes_on_redirect_id", using: :btree

  create_table "redirects", force: :cascade do |t|
    t.integer  "tag_id",                 limit: 4
    t.string   "original_tag_base_path", limit: 255, null: false
    t.string   "from_base_path",         limit: 255, null: false
    t.string   "to_base_path",           limit: 255, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "redirects", ["from_base_path"], name: "index_redirects_on_from_base_path", unique: true, using: :btree
  add_index "redirects", ["tag_id"], name: "index_redirects_on_tag_id", using: :btree

  create_table "tag_associations", force: :cascade do |t|
    t.integer  "from_tag_id", limit: 4, null: false
    t.integer  "to_tag_id",   limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_associations", ["from_tag_id", "to_tag_id"], name: "index_tag_associations_on_from_tag_id_and_to_tag_id", unique: true, using: :btree
  add_index "tag_associations", ["to_tag_id"], name: "index_tag_associations_on_to_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "type",             limit: 255
    t.string   "slug",             limit: 255,                               null: false
    t.string   "title",            limit: 255,                               null: false
    t.string   "description",      limit: 255
    t.integer  "parent_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_id",       limit: 255,                               null: false
    t.string   "state",            limit: 255,                               null: false
    t.boolean  "dirty",                             default: false,          null: false
    t.boolean  "beta",                              default: false
    t.text     "published_groups", limit: 16777215
    t.string   "child_ordering",   limit: 255,      default: "alphabetical", null: false
    t.integer  "index",            limit: 4,        default: 0,              null: false
  end

  add_index "tags", ["content_id"], name: "index_tags_on_content_id", unique: true, using: :btree
  add_index "tags", ["parent_id"], name: "tags_parent_id_fk", using: :btree
  add_index "tags", ["slug", "parent_id"], name: "index_tags_on_slug_and_parent_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string  "name",                    limit: 255
    t.string  "email",                   limit: 255
    t.string  "uid",                     limit: 255,                 null: false
    t.string  "organisation_slug",       limit: 255
    t.string  "permissions",             limit: 255
    t.boolean "remotely_signed_out",                 default: false
    t.boolean "disabled",                            default: false
    t.string  "organisation_content_id", limit: 255
  end

  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

  add_foreign_key "list_items", "lists", name: "list_items_list_id_fk", on_delete: :cascade
  add_foreign_key "lists", "tags", name: "lists_tag_id_fk", on_delete: :cascade
  add_foreign_key "newest_redirects", "tags"
  add_foreign_key "redirects", "tags", on_delete: :cascade
  add_foreign_key "tag_associations", "tags", column: "from_tag_id", name: "tag_associations_from_tag_id_fk", on_delete: :cascade
  add_foreign_key "tag_associations", "tags", column: "to_tag_id", name: "tag_associations_to_tag_id_fk", on_delete: :cascade
  add_foreign_key "tags", "tags", column: "parent_id", name: "tags_parent_id_fk"
end
