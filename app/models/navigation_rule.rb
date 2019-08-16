class NavigationRule < ActiveRecord::Base
  belongs_to :step_by_step_page

  validates :title, :base_path, :content_id, :step_by_step_page_id, :publishing_app, :schema_name, presence: true

  scope :part_of_content_ids, -> { where(include_in_links: 'always').pluck(:content_id) }
  scope :related_content_ids, -> { where(include_in_links: 'conditionally').pluck(:content_id) }

  def smartanswer?
    schema_name == "transaction" && publishing_app == "smartanswers"
  end

  def options_with_selected
    options.each { |item| item[:selected] = item[:value] == include_in_links }
  end

private

  def options
    [always, conditionally, never]
  end

  def always
    {
      text: "Always show navigation",
      value: "always",
      selected: true
    }
  end

  def conditionally
    {
      text: "Show navigation if user comes from a step-by-step",
      value: "conditionally",
    }
  end

  def never
    {
      text: "Never show navigation",
      value: "never"
    }
  end
end
