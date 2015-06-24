class CreateRedirects < ActiveRecord::Migration
  def change
    create_table :redirects do |t|
      t.integer :tag_id, index: true
      t.string :original_topic_base_path, null: false
      t.string :from_base_path, null: false
      t.string :to_base_path, null: false
      t.timestamps null: false
    end

    add_foreign_key :redirects, :tags, on_delete: :cascade
  end
end
