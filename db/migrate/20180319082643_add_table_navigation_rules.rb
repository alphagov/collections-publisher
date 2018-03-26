class AddTableNavigationRules < ActiveRecord::Migration[5.1]
  def change
    create_table :navigation_rules do |t|
      t.string "title",                null: false
      t.string "base_path",            null: false
      t.string "content_id",           null: false
      t.boolean "include_in_links",    null: false, default: true
      t.references :step_by_step_page, foreign_key: true

      t.timestamps
    end

    add_index :navigation_rules, [:step_by_step_page_id, :content_id], unique: true
    add_index :navigation_rules, [:step_by_step_page_id, :base_path], unique: true
  end
end
