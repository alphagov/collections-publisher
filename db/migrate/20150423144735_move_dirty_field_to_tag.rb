class MoveDirtyFieldToTag < ActiveRecord::Migration
  def up
    add_column :tags, :dirty, :boolean, :default => false, :null => false
    remove_column :lists, :dirty
  end
end
