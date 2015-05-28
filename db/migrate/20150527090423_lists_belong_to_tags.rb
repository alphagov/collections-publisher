class ListsBelongToTags < ActiveRecord::Migration
  def up
    remove_foreign_key :lists, :topics
    rename_column :lists, :topic_id, :tag_id

    add_foreign_key "lists", "tags",
                    column: "tag_id",
                    name: "lists_tag_id_fk",
                    on_delete: :cascade
  end

  def down
    remove_foreign_key :lists, :tags
    rename_column :lists, :tag_id, :topic_id
    add_foreign_key "lists", "tags",
                    column: "topic_id",
                    name: "lists_topic_id_fk",
                    on_delete: :cascade
  end
end
