class AddTitleToContent < ActiveRecord::Migration
  def change
    add_column :contents, :title, :string
  end
end
