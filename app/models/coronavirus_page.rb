class CoronavirusPage < ApplicationRecord
  STATUSES = %w[draft published].freeze
  has_many :sub_sections, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :timeline_entries, dependent: :destroy
  scope :topic_page, -> { where(slug: "landing") }
  scope :subtopic_pages, -> { where.not(slug: "landing") }
  validates :state, inclusion: { in: STATUSES }, presence: true

  def topic_page?
    slug == "landing"
  end

  def make_announcement_positions_sequential
    announcements.sort_by(&:position).each.with_index(1) do |announcement, index|
      announcement.update!(position: index)
    end
  end
end
