class Coronavirus::TimelineEntry < ApplicationRecord
  belongs_to :page, foreign_key: "coronavirus_page_id"
  validates :heading, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  before_create :set_position
  after_destroy :set_parent_positions

  def set_position
    page.timeline_entries.update_all("position = position + 1")
    self.position = 1
  end

  def set_parent_positions
    page.make_timeline_entry_positions_sequential
  end
end
