class RenameStepByStepBasePathToSlug < ActiveRecord::Migration[5.1]
  def change
    rename_column :step_by_step_pages, :base_path, :slug

    add_index :step_by_step_pages, :slug, unique: true
  end
end
