class SecondaryContentLink < ActiveRecord::Base
  belongs_to :step_by_step_page

  validates :title, :base_path, :content_id, :publishing_app, :schema_name, :step_by_step_page_id, presence: true
end
