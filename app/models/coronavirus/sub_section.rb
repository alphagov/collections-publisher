class Coronavirus::SubSection < ApplicationRecord
  HEADER_PATTERN = PatternMaker.call(
    "starts_with hashes then perhaps_spaces then capture(title) and nothing_else",
    hashes: "#+",
    title: '\w.+',
  )

  self.table_name = "coronavirus_sub_sections"

  belongs_to :page, foreign_key: "coronavirus_page_id"
  has_many :content_groups, dependent: :destroy, foreign_key: "coronavirus_sub_section_id"

  validates :title, :content, presence: true
  validates :page, presence: true
  validate :featured_link_must_be_in_content
  after_create :create_content_groups

  def featured_link_must_be_in_content
    if featured_link.present? && !content.include?(featured_link)
      errors.add(:featured_link, "does not exist in accordion content")
    end
  end

  def is_header?(text)
    HEADER_PATTERN =~ text
  end

  def content_groups
    content.lines.each_with_object([]) do |line, sections|
      sections << [] if sections.empty? || is_header?(line)
      line.strip!
      sections.last << line
    end
  end

  def create_content_groups
    content_groups.each_with_index do |group, index|
      content_group = {}
      content_group[:header] = group.shift if is_header?(group[0])
      content_group[:links] = group
      content_group[:position] = index
      # content_group[:coronavirus_sub_section_id] = id
      a = Coronavirus::ContentGroup.new(content_group)
      a.coronavirus_sub_section_id = id
      a.save!
    end
  end
end
