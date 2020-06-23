class CoronavirusPage < ApplicationRecord
  has_many :sub_sections
  scope :topic_page, -> { where(slug: "landing") }
  scope :subtopic_pages, -> { where.not(slug: "landing") }
end
