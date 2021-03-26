class ChangeCoronavirusAnnouncementsPathToUrl < ActiveRecord::Migration[6.0]
  def change
    rename_column :coronavirus_announcements, :path, :url
  end
end
