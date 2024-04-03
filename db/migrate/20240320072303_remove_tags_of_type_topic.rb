class RemoveTagsOfTypeTopic < ActiveRecord::Migration[7.1]
  def change
    Tag.inheritance_column = :_type_disabled
    Tag.where(type: "Topic").destroy_all
  end
end
