class TimelineEntry < ApplicationRecord
  belongs_to :coronavirus_page
  validates :content, :heading, presence: true
end
