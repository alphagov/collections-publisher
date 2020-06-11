class AddContentUrlsToCoronavirusPages < ActiveRecord::Migration[6.0]
  def change
    add_column :coronavirus_pages, :github_url, :string
    add_column :coronavirus_pages, :raw_content_url, :string
  end
end
