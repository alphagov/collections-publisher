class AddUniqueIndexToSlugAndParentId < ActiveRecord::Migration
  def change
    add_index :tags, [:slug, :parent_id], unique: true
  end
end
