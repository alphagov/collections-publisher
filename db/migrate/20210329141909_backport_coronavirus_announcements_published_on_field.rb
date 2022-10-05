class BackportCoronavirusAnnouncementsPublishedOnField < ActiveRecord::Migration[6.0]
  class CoronavirusAnnouncement < ApplicationRecord; end

  def change
    add_column :coronavirus_announcements, :published_on, :date

    CoronavirusAnnouncement.pluck(:id, :published_at).each do |id, time|
      CoronavirusAnnouncement.where(id:).update_all(published_on: time&.to_date)
    end
  end
end
