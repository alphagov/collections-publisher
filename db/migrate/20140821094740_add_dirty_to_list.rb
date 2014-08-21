class AddDirtyToList < ActiveRecord::Migration
  def change
    add_column :lists, :dirty, :boolean, null: false, default: true
  end
end
