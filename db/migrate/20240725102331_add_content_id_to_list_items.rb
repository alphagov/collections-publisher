class AddContentIdToListItems < ActiveRecord::Migration[7.1]
  def change
    change_table :list_items, bulk: true do |t|
      t.column :content_id, :string
      t.index :content_id
    end
  end
end
