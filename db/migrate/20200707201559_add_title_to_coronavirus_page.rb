class AddTitleToCoronavirusPage < ActiveRecord::Migration[6.0]
  def change
    add_column :coronavirus_pages, :title, :string
  end
end
