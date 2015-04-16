class RenameContentsToListItems < ActiveRecord::Migration
  def change
    rename_table :contents, :list_items
  end
end
