class Coronavirus::Page < ApplicationRecord
  self.table_name = "coronavirus_pages"

  STATUSES = %w[draft published].freeze
  has_many :sub_sections, dependent: :destroy, foreign_key: "coronavirus_page_id"

  validates :state, inclusion: { in: STATUSES }, presence: true

  validates :header_title, length: { maximum: 255 }
  validates :header_link_pre_wrap_text, length: { maximum: 255 }
  validates :header_link_post_wrap_text, length: { maximum: 255 }
  validates :header_link_url, absolute_path_or_https_url: { allow_blank: true }

  validate :valid_header_link_post_wrap_text
  validate :validate_header_link

private

  def valid_header_link_post_wrap_text
    if header_link_post_wrap_text.present? && header_link_pre_wrap_text.blank?
      errors.add(:header_link_post_wrap_text, "cannot be used because header link pre wrap text is blank")
    end
  end

  def validate_header_link
    return unless header_link_url.present? ^ header_link_pre_wrap_text.present?

    if header_link_pre_wrap_text.blank?
      errors.add(:header_link_pre_wrap_text, "must have a value if link URL is populated")
    end

    if header_link_url.blank?
      errors.add(:header_link_url, "must have a value if link text is populated")
    end
  end
end
