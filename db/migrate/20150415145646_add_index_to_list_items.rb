class AddIndexToListItems < ActiveRecord::Migration
  def change
    add_index :list_items, [:list_id, :index]
  end
end
