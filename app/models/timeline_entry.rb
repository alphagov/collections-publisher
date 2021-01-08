class TimelineEntry < ApplicationRecord
  belongs_to :coronavirus_page
  validates :heading, presence: true, length: { maximum: 255 }
  validates :content, presence: true
end
