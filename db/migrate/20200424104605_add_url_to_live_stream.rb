class AddUrlToLiveStream < ActiveRecord::Migration[6.0]
  def change
    add_column :live_streams, :url, :string, null: false
  end
end
