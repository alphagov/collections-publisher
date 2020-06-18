class AddContentUrlsToCoronavirusPages < ActiveRecord::Migration[6.0]
  # rubocop:disable Rails/BulkChangeTable
  def change
    add_column :coronavirus_pages, :github_url, :string
    add_column :coronavirus_pages, :raw_content_url, :string
  end
  # rubocop:enable Rails/BulkChangeTable
end
