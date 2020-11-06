class AddPositionToAnnouncements < ActiveRecord::Migration[6.0]
  def change
    add_column :announcements, :position, :integer
  end
end
