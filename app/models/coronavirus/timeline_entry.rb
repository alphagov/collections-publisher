class Coronavirus::TimelineEntry < ApplicationRecord
  self.table_name = "coronavirus_timeline_entries"
  serialize :national_applicability, Array

  belongs_to :page, foreign_key: "coronavirus_page_id"
  validates :heading, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :national_applicability, presence: true

  validate :applies_to_uk_nations

  before_create :set_position
  after_destroy :set_parent_positions

  UK_NATIONS = %w[england northern_ireland scotland wales].freeze

  def set_position
    page.timeline_entries.update_all("position = position + 1")
    self.position = 1
  end

  def set_parent_positions
    page.make_timeline_entry_positions_sequential
  end

  def national_applicability_text
    if national_applicability.uniq.sort == UK_NATIONS
      "UK Wide"
    else
      national_applicability.join(", ").titleize
    end
  end

private

  def applies_to_uk_nations
    national_applicability.each do |nation|
      unless UK_NATIONS.include?(nation)
        errors.add(:national_applicability, "has an invalid nation selected")
      end
    end
  end
end
