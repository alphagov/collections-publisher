class AddForeignKeysForListsAndListItems < ActiveRecord::Migration
  def change
    # When a `List` is deleted, this :cascade causes the respective
    # `ListItem` records to be deleted.
    add_foreign_key "list_items", "lists",
                    name: "list_items_list_id_fk",
                    on_delete: :cascade

    add_foreign_key "lists", "tags",
                    column: "topic_id",
                    name: "lists_topic_id_fk",
                    on_delete: :cascade
  end
end
