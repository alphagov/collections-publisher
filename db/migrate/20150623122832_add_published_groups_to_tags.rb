class AddPublishedGroupsToTags < ActiveRecord::Migration
  def change
    add_column :tags, :published_groups, :text
  end
end
