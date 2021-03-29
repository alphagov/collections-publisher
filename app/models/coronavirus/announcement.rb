class Coronavirus::Announcement < ApplicationRecord
  self.table_name = "coronavirus_announcements"

  belongs_to :page, foreign_key: "coronavirus_page_id", optional: false
  validates :title, presence: true
  validates :url, presence: true, absolute_path_or_https_url: { allow_blank: true }
  validate :valid_published_on
  before_create :set_position
  after_destroy :set_parent_positions

  def published_on=(published_on)
    unless published_on.is_a?(Hash)
      @published_on_hash = nil
      super
      return
    end

    @published_on_hash = published_on.reject { |_, value| value.blank? }
                                     .presence

    value = published_on_hash ? parsed_published_on_hash : nil
    super(value)
  end

private

  attr_reader :published_on_hash

  def set_position
    self.position = page.announcements.count + 1
  end

  def set_parent_positions
    page.make_announcement_positions_sequential
  end

  def parsed_published_on_hash
    day, month, year = published_on_hash.values_at("day", "month", "year").map(&:to_i)
    Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
  rescue ArgumentError
    nil
  end

  def valid_published_on
    if published_on_hash && !published_on
      errors.add(:published_on, "must be a valid date")
    elsif published_on && published_on.year < 2000
      errors.add(:published_on, "must be this century")
    elsif published_on&.future?
      errors.add(:published_on, "must not be in the future")
    end
  end
end
