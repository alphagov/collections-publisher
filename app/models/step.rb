class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  has_many :link_check_report

  def batch_link_report
    Services.link_checker_api.get_batch(find_batch_id)
  end

    # gets the most recent batch id for a step
  def batch_link_report_id
    LinkCheckReport.where(step_id: self.id).last.id
  end
end
