class ChangeTimelineEntriesContentType < ActiveRecord::Migration[6.0]
  def up
    change_column :timeline_entries, :content, :text
  end

  def down
    change_column :timeline_entries, :content, :string
  end
end
