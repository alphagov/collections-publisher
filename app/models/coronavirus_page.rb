class CoronavirusPage < ApplicationRecord
  STATUSES = %w[draft published].freeze
  has_many :sub_sections, dependent: :destroy
  scope :topic_page, -> { where(slug: "landing") }
  scope :subtopic_pages, -> { where.not(slug: "landing") }
  validates :state, inclusion: { in: STATUSES }, presence: true

  def topic_page?
    slug == "landing"
  end
end
