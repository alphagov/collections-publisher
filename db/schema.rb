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

ActiveRecord::Schema.define(version: 2019_09_02_134939) do

  create_table "internal_change_notes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "author"
    t.text "description"
    t.bigint "step_by_step_page_id"
    t.datetime "created_at"
    t.integer "edition_number"
    t.index ["step_by_step_page_id"], name: "index_internal_change_notes_on_step_by_step_page_id"
  end

  create_table "link_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "batch_id"
    t.datetime "completed"
    t.bigint "step_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_link_reports_on_step_id"
  end

  create_table "list_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "base_path"
    t.integer "index", default: 0, null: false
    t.integer "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.index ["list_id", "index"], name: "index_list_items_on_list_id_and_index"
  end

  create_table "lists", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "index", default: 0, null: false
    t.integer "tag_id", null: false
    t.index ["tag_id"], name: "index_lists_on_tag_id"
  end

  create_table "navigation_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", null: false
    t.string "base_path", null: false
    t.string "content_id", null: false
    t.bigint "step_by_step_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "publishing_app"
    t.string "schema_name"
    t.string "include_in_links", default: "always", null: false
    t.index ["step_by_step_page_id", "base_path"], name: "index_navigation_rules_on_step_by_step_page_id_and_base_path", unique: true
    t.index ["step_by_step_page_id", "content_id"], name: "index_navigation_rules_on_step_by_step_page_id_and_content_id", unique: true
    t.index ["step_by_step_page_id"], name: "index_navigation_rules_on_step_by_step_page_id"
  end

  create_table "redirect_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "from_base_path", null: false
    t.string "to_base_path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_redirect_items_on_content_id", unique: true
    t.index ["from_base_path"], name: "index_redirect_items_on_from_base_path", unique: true
  end

  create_table "redirect_routes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "redirect_id"
    t.string "from_base_path"
    t.string "to_base_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tag_id"
    t.index ["from_base_path"], name: "index_redirect_routes_on_from_base_path", unique: true
    t.index ["redirect_id"], name: "index_redirect_routes_on_redirect_id"
    t.index ["tag_id"], name: "index_redirect_routes_on_tag_id"
  end

  create_table "secondary_content_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "base_path"
    t.string "title"
    t.string "content_id"
    t.string "publishing_app"
    t.string "schema_name"
    t.bigint "step_by_step_page_id"
    t.index ["step_by_step_page_id"], name: "index_secondary_content_links_on_step_by_step_page_id"
  end

  create_table "step_by_step_pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "introduction"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_id", null: false
    t.datetime "published_at"
    t.datetime "draft_updated_at"
    t.string "assigned_to"
    t.datetime "scheduled_at"
    t.string "status", null: false
    t.index ["content_id"], name: "index_step_by_step_pages_on_content_id", unique: true
    t.index ["slug"], name: "index_step_by_step_pages_on_slug", unique: true
  end

  create_table "steps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "logic"
    t.boolean "optional"
    t.text "contents"
    t.integer "position"
    t.bigint "step_by_step_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_by_step_page_id"], name: "index_steps_on_step_by_step_page_id"
  end

  create_table "tag_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "from_tag_id", null: false
    t.integer "to_tag_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["from_tag_id", "to_tag_id"], name: "index_tag_associations_on_from_tag_id_and_to_tag_id", unique: true
    t.index ["to_tag_id"], name: "index_tag_associations_on_to_tag_id"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type"
    t.string "slug", null: false
    t.string "title", null: false
    t.string "description"
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "content_id", null: false
    t.string "state", null: false
    t.boolean "dirty", default: false, null: false
    t.text "published_groups", limit: 16777215
    t.string "child_ordering", default: "alphabetical", null: false
    t.integer "index", default: 0, null: false
    t.index ["content_id"], name: "index_tags_on_content_id", unique: true
    t.index ["parent_id"], name: "tags_parent_id_fk"
    t.index ["slug", "parent_id"], name: "index_tags_on_slug_and_parent_id", unique: true
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid", null: false
    t.string "organisation_slug"
    t.string "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.string "organisation_content_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "internal_change_notes", "step_by_step_pages"
  add_foreign_key "link_reports", "steps"
  add_foreign_key "list_items", "lists", name: "list_items_list_id_fk", on_delete: :cascade
  add_foreign_key "lists", "tags", name: "lists_tag_id_fk", on_delete: :cascade
  add_foreign_key "navigation_rules", "step_by_step_pages"
  add_foreign_key "redirect_routes", "tags"
  add_foreign_key "secondary_content_links", "step_by_step_pages"
  add_foreign_key "steps", "step_by_step_pages"
  add_foreign_key "tag_associations", "tags", column: "from_tag_id", name: "tag_associations_from_tag_id_fk", on_delete: :cascade
  add_foreign_key "tag_associations", "tags", column: "to_tag_id", name: "tag_associations_to_tag_id_fk", on_delete: :cascade
  add_foreign_key "tags", "tags", column: "parent_id", name: "tags_parent_id_fk"
end
