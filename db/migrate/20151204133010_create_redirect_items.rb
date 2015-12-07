class CreateRedirectItems < ActiveRecord::Migration
  def change
    create_table :redirect_items do |t|
      t.string :content_id, null: false
      t.string :from_base_path, null: false
      t.string :to_base_path, null: false
      t.references :related_tag
      t.timestamps null: false
    end

    add_index :redirect_items, :content_id, unique: true
    add_index :redirect_items, :from_base_path, unique: true
  end
end
