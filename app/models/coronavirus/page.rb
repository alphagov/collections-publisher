class Coronavirus::Page < ApplicationRecord
  self.table_name = "coronavirus_pages"

  STATUSES = %w[draft published].freeze
  has_many :sub_sections, dependent: :destroy, foreign_key: "coronavirus_page_id"
  has_many :announcements, dependent: :destroy, foreign_key: "coronavirus_page_id"
  has_many :timeline_entries, dependent: :destroy, foreign_key: "coronavirus_page_id"
  has_many :coronavirus_yamls, dependent: :destroy, foreign_key: "coronavirus_page_id"

  scope :topic_page, -> { where(slug: "landing") }
  scope :subtopic_pages, -> { where.not(slug: "landing") }
  validates :state, inclusion: { in: STATUSES }, presence: true

  def topic_page?
    slug == "landing"
  end

  def make_announcement_positions_sequential
    make_positions_sequential(announcements)
  end

  def make_timeline_entry_positions_sequential
    make_positions_sequential(timeline_entries)
  end

private

  def make_positions_sequential(collection)
    collection.sort_by(&:position).each.with_index(1) do |object, index|
      object.update_column(:position, index)
    end
  end
end
