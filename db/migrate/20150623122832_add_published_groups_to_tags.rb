class AddPublishedGroupsToTags < ActiveRecord::Migration
  def change
    # 65536+1 forces the text column to be `mediumtext` / 16MB
    add_column :tags, :published_groups, :text, limit: 65536 + 1
  end
end
