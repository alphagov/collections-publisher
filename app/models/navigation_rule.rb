class NavigationRule < ActiveRecord::Base
  belongs_to :step_by_step_page

  validates :title, :base_path, :content_id, :step_by_step_page_id, :publishing_app, :schema_name, presence: true

  scope :part_of_content_ids, -> { where(include_in_links: true).pluck(:content_id) }
  scope :related_content_ids, -> { where(include_in_links: false).pluck(:content_id) }
end
