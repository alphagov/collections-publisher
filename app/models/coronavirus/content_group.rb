class Coronavirus::ContentGroup < ApplicationRecord
  LINK_PATTERN = PatternMaker.call(
    "starts_with perhaps_spaces within(sq_brackets,capture(label)) then perhaps_spaces and within(brackets,capture(url))",
    label: '\s*\w.+',
    url: '\s*(\b(https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\s*',
  )

  belongs_to :sub_section, foreign_key: "coronavirus_sub_section_id"
  validates :links, presence: true
  # validates :coronavirus_sub_section_id, presence: true
  validate :links_in_correct_format

  serialize :links, Array

  def links_in_correct_format
    links.each do |link|
      errors.add(:links, "Unable to parse markdown: '#{link}'") unless is_link?(link)
    end
  end

  def is_link?(text)
    LINK_PATTERN =~ text
  end
end
