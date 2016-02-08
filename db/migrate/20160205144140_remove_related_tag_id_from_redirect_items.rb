class RemoveRelatedTagIdFromRedirectItems < ActiveRecord::Migration
  def change
    remove_column :redirect_items, :related_tag_id
  end
end
