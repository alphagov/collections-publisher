class RemoveCoronavirusTimelineEntriesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :coronavirus_timeline_entries
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
