class RemovePublishedAtFromCoronavirusAnnouncements < ActiveRecord::Migration[6.0]
  def change
    remove_column :coronavirus_announcements, :published_at, :datetime
  end
end
