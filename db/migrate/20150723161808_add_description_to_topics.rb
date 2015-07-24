class AddDescriptionToTopics < ActiveRecord::Migration
  def up
    Topic.find_each do |topic|
      next if topic.description.present?

      topic.update!(description: "List of information about #{topic.title}.")
    end
  end

  def down
  end
end
