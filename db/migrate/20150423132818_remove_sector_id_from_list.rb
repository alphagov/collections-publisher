class RemoveSectorIdFromList < ActiveRecord::Migration
  def change
    remove_column :lists, :sector_id
  end
end
