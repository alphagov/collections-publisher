class AddIndexesForLists < ActiveRecord::Migration
  def change
    add_index(:lists, :sector_id)
  end
end
