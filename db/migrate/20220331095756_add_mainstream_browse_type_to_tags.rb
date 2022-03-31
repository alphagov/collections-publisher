class AddMainstreamBrowseTypeToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :mainstream_browse_type, :boolean, default: false
  end
end
