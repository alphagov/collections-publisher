class Coronavirus::Announcement < ApplicationRecord
  self.table_name = "coronavirus_announcements"

  belongs_to :page, foreign_key: "coronavirus_page_id"
  validates :title, :url, presence: true
  validates :page, presence: true
  validate :published_at_format
  validate :url_format
  after_create :set_position
  after_destroy :set_parent_positions

private

  def set_position
    update_column(:position, page.announcements.count)
  end

  def set_parent_positions
    page.make_announcement_positions_sequential
  end

  def published_at_format
    unless published_at.is_a?(Time) && valid_year?
      errors.add(:published_at, "must be a valid date")
    end
  end

  def valid_year?
    published_at.past? && published_at.year > 1950
  end

  def url_format
    return if url.blank?

    errors.add(:url, "must be a valid path starting with a /") unless url.start_with?("/")
  end
end
