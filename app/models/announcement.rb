class Announcement < ApplicationRecord
  belongs_to :coronavirus_page
  validates :text, :href, :published_at, presence: true
  validates :coronavirus_page, presence: true
  after_create :set_position
  after_destroy :set_parent_positions

private

  def set_position
    update!(position: coronavirus_page.announcements.count)
  end

  def set_parent_positions
    coronavirus_page.make_announcement_positions_sequential
  end
end
