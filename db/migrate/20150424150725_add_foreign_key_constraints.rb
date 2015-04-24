class AddForeignKeyConstraints < ActiveRecord::Migration
  def change
    add_foreign_key "list_items", "lists", name: "list_items_list_id_fk"
    add_foreign_key "lists", "tags", column: "topic_id", name: "lists_topic_id_fk"
    add_foreign_key "tags", "tags", column: "parent_id", name: "tags_parent_id_fk"

    add_foreign_key "tag_associations", "tags",
                    column: "from_tag_id",
                    name: "tag_associations_from_tag_id_fk",
                    dependent: :delete
    add_foreign_key "tag_associations", "tags",
                    column: "to_tag_id",
                    name: "tag_associations_to_tag_id_fk",
                    dependent: :delete
  end
end
