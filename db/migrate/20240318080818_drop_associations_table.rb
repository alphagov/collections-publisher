class DropAssociationsTable < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key "tag_associations", "tags",
                       column: "to_tag_id",
                       name: "tag_associations_to_tag_id_fk",
                       on_delete: :cascade

    remove_foreign_key "tag_associations", "tags",
                       column: "from_tag_id",
                       name: "tag_associations_from_tag_id_fk",
                       on_delete: :cascade

    drop_table :tag_associations do |t|
      t.integer :from_tag_id, null: false
      t.integer :to_tag_id, null: false
      t.datetime :created_at, precision: nil
      t.datetime :updated_at, precision: nil
      t.index %i[from_tag_id to_tag_id], unique: true
      t.index [:to_tag_id]
    end
  end
end
