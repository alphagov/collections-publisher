class RenameCoronavirusTables < ActiveRecord::Migration[6.0]
  def change
    rename_table :announcements, :coronavirus_announcements
    rename_table :live_streams, :coronavirus_live_streams
    rename_table :sub_sections, :coronavirus_sub_sections
    rename_table :timeline_entries, :coronavirus_timeline_entries
  end
end
