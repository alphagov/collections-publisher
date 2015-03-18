class AddStateToTags < ActiveRecord::Migration
  def change
    add_column :tags, :state, :string, null: false
  end
end
