class ImproveCoronavirusAnnouncementsSchema < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        # Change from string to allow URL's longer than 255 characters
        change_column :coronavirus_announcements, :url, :text, null: false
      end

      dir.down do
        change_column :coronavirus_announcements, :url, :string
      end
    end

    # These fields are all required so shouldn't allow null
    change_column_null :coronavirus_announcements, :coronavirus_page_id, false
    change_column_null :coronavirus_announcements, :title, false
    change_column_null :coronavirus_announcements, :url, false
  end
end
