class SecondaryContentLink < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page

  validates :title, :base_path, :content_id, :publishing_app, :schema_name, :step_by_step_page_id, presence: true
  validates_uniqueness_of :base_path, scope: :step_by_step_page_id

  def smartanswer?
    schema_name == "transaction" && publishing_app == "smartanswers"
  end
end
