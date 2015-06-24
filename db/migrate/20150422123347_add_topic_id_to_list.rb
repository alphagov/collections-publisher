class AddTopicIdToList < ActiveRecord::Migration
  def up
    add_column :lists, :topic_id, :integer
    add_index :lists, :topic_id
  end

  def down
    remove_column :lists, :topic_id
  end
end
