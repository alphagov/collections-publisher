class RemoveGitHubFieldsFromCoronavirusPages < ActiveRecord::Migration[6.1]
  # rubocop:disable Rails/BulkChangeTable
  def change
    remove_column :coronavirus_pages, :github_url, :string
    remove_column :coronavirus_pages, :raw_content_url, :string
  end
  # rubocop:enable Rails/BulkChangeTable
end
