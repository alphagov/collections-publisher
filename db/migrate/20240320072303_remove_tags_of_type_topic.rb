class RemoveTagsOfTypeTopic < ActiveRecord::Migration[7.1]
  def change
    Tag.where(type: "Topic").destroy_all
  end
end
