class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true

  def batch_link_report
    @base_api_url = Plek.find("link-checker-api")
    @api = GdsApi::LinkCheckerApi.new(@base_api_url)
    @api.get_batch(find_batch_id)
    # params
  end

    # gets the most recent batch id for the step by step the user is on
  def batch_link_report_id
      
  end
end
