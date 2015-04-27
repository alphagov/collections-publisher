class AddIndexToTagContentId < ActiveRecord::Migration
  def change
    add_index :tags, :content_id, :unique => true
  end
end
