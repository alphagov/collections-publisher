class NavigationRule < ActiveRecord::Base
  belongs_to :step_by_step_page

  validates :title, :base_path, :content_id, :step_by_step_page_id, presence: true

  scope :base_paths_part_of_step_nav, -> { where(include_in_links: true).pluck(:base_path) }
  scope :base_paths_related_to_step_nav, -> { where(include_in_links: false).pluck(:base_path) }
end
