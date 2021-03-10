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

  validate :all_content_groups_valid?
  after_create :save_validated_content_groups

  def featured_link_must_be_in_content
    if featured_link.present? && !content.include?(featured_link)
      errors.add(:featured_link, "does not exist in accordion content")
    end
  end

  def is_header?(text)
    HEADER_PATTERN =~ text
  end

  def content_group_array
    content.lines.each_with_object([]) do |line, sections|
      sections << [] if sections.empty? || is_header?(line)
      line.strip!
      sections.last << line
    end
  end

  def content_super_group
    @content_super_group ||= content_group_array.each_with_index.map do |group, index|
      content_group = {}
      content_group[:header] = group.shift if is_header?(group[0])
      content_group[:links] = group
      content_group[:position] = index
      Coronavirus::ContentGroup.new(content_group)
    end
  end

  def all_content_groups_valid?
    invalid_entries = content_super_group.select(&:invalid?)
    unless invalid_entries.empty?
      invalid_entries.each { |group| add_error_messages_to_sub_section(group) }
      false
    end
    true
  end

  def add_error_messages_to_sub_section(group)
    group.errors.full_messages.each do |message|
      errors[:base] << "Content Error: #{message}"
    end
  end

  def save_validated_content_groups
    content_super_group.each do |group|
      group.coronavirus_sub_section_id = id
      group.save!
    end
  end

  def reload_content_groups
    existing_content_groups = content_groups.map(&:id)
    if all_content_groups_valid?
      save_validated_content_groups
      existing_content_groups.each { |x| Coronavirus::ContentGroup.find(x).destroy! }
    end
  end
end
