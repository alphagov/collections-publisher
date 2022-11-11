class RemoveMainstreamBrowseTypeFromTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :tags, :mainstream_browse_type, :boolean
  end
end
