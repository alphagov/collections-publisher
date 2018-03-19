class NavigationRule < ActiveRecord::Base
  belongs_to :step_by_step_page

  validates :title, :base_path, :content_id, :step_by_step_page_id, presence: true
end
