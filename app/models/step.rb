class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  has_many :link_check_report

  def batch_link_report
    @base_api_url = Plek.find("link-checker-api")
    @api = GdsApi::LinkCheckerApi.new(@base_api_url)
    @api.get_batch(find_batch_id)
  end

    # gets the most recent batch id for a step
  def batch_link_report_id
    LinkCheckReport.where(step_id: self.id).last.id
  end
end
