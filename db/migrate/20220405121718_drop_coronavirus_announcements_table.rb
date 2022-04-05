class DropCoronavirusAnnouncementsTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :coronavirus_announcements
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
