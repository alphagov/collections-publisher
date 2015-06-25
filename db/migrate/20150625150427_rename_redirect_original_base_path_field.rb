class RenameRedirectOriginalBasePathField < ActiveRecord::Migration
  def change
    rename_column :redirects, :original_topic_base_path, :original_tag_base_path
  end
end
