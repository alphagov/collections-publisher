class Coronavirus::Announcement < ApplicationRecord
  belongs_to :coronavirus_page
  validates :title, :path, presence: true
  validates :coronavirus_page, presence: true
  validate :published_at_format
  validate :path_format
  after_create :set_position
  after_destroy :set_parent_positions

private

  def set_position
    update_column(:position, coronavirus_page.announcements.count)
  end

  def set_parent_positions
    coronavirus_page.make_announcement_positions_sequential
  end

  def published_at_format
    unless published_at.is_a?(Time) && valid_year?
      errors.add(:published_at, "must be a valid date")
    end
  end

  def valid_year?
    published_at.past? && published_at.year > 1950
  end

  def path_format
    return if path.blank?

    if path.nil? || !path.start_with?("/")
      errors.add(:path, "must be a valid path starting with a /")
    end
  end
end
