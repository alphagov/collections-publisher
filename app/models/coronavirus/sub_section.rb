class Coronavirus::SubSection < ApplicationRecord
  self.table_name = "coronavirus_sub_sections"

  belongs_to :page, foreign_key: "coronavirus_page_id"
  validates :title, :content, presence: true
  validates :page, presence: true
  validates :action_link_url,
            :action_link_content,
            :action_link_summary,
            presence: true,
            if: -> { [action_link_url, action_link_content, action_link_summary].any?(&:present?) }
  validates :action_link_url, allow_blank: true, absolute_path_or_https_url: true
  validate :all_structured_content_valid
  after_initialize :populate_structured_content
  attr_reader :structured_content

  def content=(content)
    super.tap { populate_structured_content }
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
