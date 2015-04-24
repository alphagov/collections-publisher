class AddTopicIdToList < ActiveRecord::Migration
  def up
    add_column :lists, :topic_id, :integer

    topics_by_base_path = Topic.all.includes(:parent).each_with_object({}) { |topic, result| result[topic.base_path] = topic }
    List.find_each do |list|
      list.update_columns(:topic_id => topics_by_base_path["/#{list.sector_id}"].id)
    end

    add_index :lists, :topic_id
  end

  def down
    remove_column :lists, :topic_id
  end
end
