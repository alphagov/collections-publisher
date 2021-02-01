class Coronavirus::SubSection < ApplicationRecord
  belongs_to :coronavirus_page
  validates :title, :content, presence: true
  validates :coronavirus_page, presence: true

  validate :featured_link_must_be_in_content

  def featured_link_must_be_in_content
    if featured_link.present? && !content.include?(featured_link)
      errors.add(:featured_link, "does not exist in accordion content")
    end
  end
end
