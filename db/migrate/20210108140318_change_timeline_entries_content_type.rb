class ChangeTimelineEntriesContentType < ActiveRecord::Migration[6.0]
  def change
    change_column :timeline_entries, :content, :text
  end
end
