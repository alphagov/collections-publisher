class AddIndexToList < ActiveRecord::Migration
  def change
    add_column :lists, :index, :integer, null: false, default: 0
  end
end
