class AddForeignKeysForTagsAndTagAssociations < ActiveRecord::Migration
  def change
    add_foreign_key "tag_associations", "tags",
                    column: "from_tag_id",
                    name: "tag_associations_from_tag_id_fk",
                    on_delete: :cascade

    add_foreign_key "tag_associations", "tags",
                    column: "to_tag_id",
                    name: "tag_associations_to_tag_id_fk",
                    on_delete: :cascade

    add_foreign_key "tags", "tags",
                    column: "parent_id",
                    name: "tags_parent_id_fk",
                    on_delete: :restrict
  end
end
