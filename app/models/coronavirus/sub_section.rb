class Coronavirus::SubSection < ApplicationRecord
  self.table_name = "coronavirus_sub_sections"

  belongs_to :page, foreign_key: "coronavirus_page_id"
  validates :title, :content, presence: true
  validates :page, presence: true
  validate :action_link_url_must_be_in_content
  validate :all_structured_content_valid
  after_initialize :populate_structured_content
  attr_reader :structured_content

  def content=(content)
    super.tap { populate_structured_content }
  end

  def action_link_url_must_be_in_content
    return if action_link_url.blank? || !structured_content

    unless structured_content.links.any? { |l| l.url == action_link_url }
      errors.add(:action_link_url, "does not exist in accordion content")
    end
  end

private

  def populate_structured_content
    @structured_content = if StructuredContent.parseable?(content)
                            StructuredContent.parse(content)
                          end
  end

  def all_structured_content_valid
    StructuredContent.error_lines(content).each do |line|
      errors.add(:content, "unable to parse markdown: #{line}")
    end
    errors.present?
  end
end
