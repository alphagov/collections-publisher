class MoveDirtyFieldToTag < ActiveRecord::Migration
  def up
    add_column :tags, :dirty, :boolean, :default => false, :null => false

    Topic.includes(:lists).find_each do |topic|
      if topic.lists.any?(&:dirty?)
        topic.update_columns(:dirty => true)
      end
    end

    remove_column :lists, :dirty
  end
end
