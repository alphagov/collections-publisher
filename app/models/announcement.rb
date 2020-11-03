class Announcement < ApplicationRecord
  belongs_to :coronavirus_page
  validates :text, :href, :published_at, presence: true
  validates :coronavirus_page, presence: true
  after_create :set_position

private

  def set_position
    update!(position: coronavirus_page.announcements.count)
  end
end
