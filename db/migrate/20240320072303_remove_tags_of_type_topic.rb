class RemoveTagsOfTypeTopic < ActiveRecord::Migration[7.1]
  def change
    Tag.where(type: "Topic").delete_all
  end
end
