class AddNamesAndContentIdsToCoronavirusPages < ActiveRecord::Migration[6.0]
  def change
    add_column :coronavirus_pages, :name, :string
    add_column :coronavirus_pages, :slug, :string
    add_column :coronavirus_pages, :content_id, :string
  end
end
