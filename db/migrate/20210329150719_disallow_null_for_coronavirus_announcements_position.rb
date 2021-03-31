class DisallowNullForCoronavirusAnnouncementsPosition < ActiveRecord::Migration[6.0]
  def change
    change_column_null :coronavirus_announcements, :position, false
  end
end
