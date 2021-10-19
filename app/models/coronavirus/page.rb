class Coronavirus::Page < ApplicationRecord
  self.table_name = "coronavirus_pages"

  STATUSES = %w[draft published].freeze
  has_many :sub_sections, dependent: :destroy, foreign_key: "coronavirus_page_id"
  has_many :announcements, dependent: :destroy, foreign_key: "coronavirus_page_id"
  has_many :timeline_entries, dependent: :destroy, foreign_key: "coronavirus_page_id"

  validates :state, inclusion: { in: STATUSES }, presence: true

  validates :header_title, length: { maximum: 255 }
  validates :header_link_url, absolute_path_or_https_url: { allow_blank: true }

  validate :valid_header_link_post_wrap_text

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

  def valid_header_link_post_wrap_text
    if header_link_post_wrap_text.present? && header_link_pre_wrap_text.blank?
      errors.add(:header_link_post_wrap_text, "cannot be used because header link pre wrap text is blank")
    end
  end
end
