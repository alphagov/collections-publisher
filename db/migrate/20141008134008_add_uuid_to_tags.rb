class AddUuidToTags < ActiveRecord::Migration
  def change
    add_column :tags, :content_id, :string, null: false
  end
end
