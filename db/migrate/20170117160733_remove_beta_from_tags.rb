class RemoveBetaFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :beta
  end

  def down
    add_column :tags, :beta, :boolean, default: false
  end
end
