class AddChildOrderingAndIndexToTags < ActiveRecord::Migration
  def change
    add_column :tags, :child_ordering, :string, default: "alphabetical", null: false
    add_column :tags, :index, :integer, default: 0, null: false
  end
end
