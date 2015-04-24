class CreateTagAssociations < ActiveRecord::Migration
  def change
    create_table :tag_associations do |t|
      t.integer :from_tag_id, null: false
      t.integer :to_tag_id, null: false

      t.timestamps
    end

    add_index :tag_associations, [:from_tag_id, :to_tag_id], :unique => true
    add_index :tag_associations, [:to_tag_id]
  end
end
