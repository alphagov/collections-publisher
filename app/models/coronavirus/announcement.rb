class Coronavirus::Announcement < ApplicationRecord
  self.table_name = "coronavirus_announcements"

  belongs_to :page, foreign_key: "coronavirus_page_id", optional: false
  validates :title, presence: true
  validates :url, presence: true, absolute_path_or_https_url: { allow_blank: true }
  validate :valid_published_at
  after_create :set_position
  after_destroy :set_parent_positions

  def published_at=(published_at)
    unless published_at.is_a?(Hash)
      @published_at_hash = nil
      super
      return
    end

    @published_at_hash = published_at.reject { |_, value| value.blank? }
                                     .presence

    value = published_at_hash ? parsed_published_at_hash : nil
    super(value)
  end

private

  attr_reader :published_at_hash

  def set_position
    update_column(:position, page.announcements.count)
  end

  def set_parent_positions
    page.make_announcement_positions_sequential
  end

  def parsed_published_at_hash
    day, month, year = published_at_hash.values_at("day", "month", "year").map(&:to_i)
    Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
  rescue ArgumentError
    nil
  end

  def valid_published_at
    if published_at_hash && !published_at
      errors.add(:published_at, "must be a valid date")
    elsif published_at && published_at.year < 2000
      errors.add(:published_at, "must be this century")
    elsif published_at&.future?
      errors.add(:published_at, "must not be in the future")
    end
  end
end
