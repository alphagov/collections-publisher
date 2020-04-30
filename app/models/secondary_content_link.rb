class SecondaryContentLink < ApplicationRecord
  belongs_to :step_by_step_page
  validates :step_by_step_page, presence: true

  validates :title, :base_path, :content_id, :publishing_app, :schema_name, :step_by_step_page_id, presence: true
  validates :base_path, uniqueness: { scope: :step_by_step_page_id, case_sensitive: false }

  def smartanswer?
    schema_name == "transaction" && publishing_app == "smartanswers"
  end
end
